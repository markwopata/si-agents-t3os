{{ config(
    materialized='incremental',
    unique_key=['quote_customer_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

WITH 
    -- isolate escalation_id from staging layer
    converted_customers as (
        select 
            quote_source
            , quote_id
            , COALESCE(quote_customer_id, 'Unknown') as quote_customer_id
            , company_id
            , converted_timestamp::date as converted_date
            , converted_timestamp::time as converted_time
            
        from {{ ref('int_quote_customer_conversion') }} qc 
        WHERE (({{ filter_transformation_updates('_updated_recordtimestamp') }}))
    )

    , cte_companies as (
        select company_key, company_id
        from {{ ref('platform', 'dim_companies') }}
    )

    , cte_times as (
        SELECT  tm_key, tm_time_24
        FROM  {{ ref('platform', 'dim_times') }}
        where tm_hour <> -1
    )

    , cte_dates as (
        select dt_key, dt_date
        from {{ ref('platform', 'dim_dates') }}
    )

    , cte_quote_customers as (
        select  quote_customer_key, quote_customer_id
        from {{ ref('dim_quote_customers') }}
    )

    , cte_quotes as (
        select quote_key, quote_source, quote_id
        from {{ ref('dim_quotes') }}
    )

select 
    {{ dbt_utils.generate_surrogate_key([
        'cc.quote_customer_id'
        ]) }} AS quote_customer_key
    , COALESCE(q.quote_key, 
        {{ get_default_key_from_dim(model_name='dim_quotes') }}
    ) as quote_key
    , COALESCE(c.company_key, 
        {{ get_default_key_from_dim(model_name='dim_companies') }}
    ) as company_key
    , COALESCE( 
        converted_date.dt_key
        , {{ get_default_key_from_dim(model_name='dim_dates') }}
    ) as converted_date_key
    ,COALESCE(converted_time.tm_key, 
        {{ get_default_key_from_dim(model_name='dim_times') }}
    ) as converted_time_key

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from converted_customers cc
LEFT JOIN cte_quotes q
    ON q.quote_source = cc.quote_source
    AND q.quote_id = cc.quote_id
LEFT JOIN cte_companies c 
    ON c.company_id = cc.company_id
LEFT JOIN cte_quote_customers quote_customer
    ON quote_customer.quote_customer_id = cc.quote_customer_id
LEFT JOIN cte_dates converted_date
    ON cc.converted_date = converted_date.dt_date
LEFT JOIN cte_times converted_time
    ON CAST(cc.converted_time as string) = converted_time.tm_time_24