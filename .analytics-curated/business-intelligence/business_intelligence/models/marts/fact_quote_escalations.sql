{{ config(
    materialized='incremental',
    unique_key=['quote_escalation_key'],
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

WITH 
    -- isolate escalation_id from staging layer
    quotes as (

        select 
            quote_source
            , quote_id
            , created_date
            , quote_escalation_id
            , COALESCE(quote_customer_id, 'Unknown') as quote_customer_id
        FROM {{ ref('int_quotes') }}

        WHERE quote_escalation_id IS NOT NULL
        AND ({{ filter_transformation_updates('_updated_recordtimestamp') }})
    )

    , escalations as (

        select *
        from {{ ref('stg_quotes__escalations') }}
        WHERE ({{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }})
    )

    , quote_escalations as (

        SELECT
            q.quote_source
            , q.quote_id
            , q.quote_customer_id
            , e.quote_escalation_id
            , q.created_date as quote_created_date
            , e.created_date as escalation_created_date
            , CEIL(DATEDIFF('hour', q.created_date, e.created_date) / 24) as num_days_to_escalation
            , e.escalation_user_id
            , e.escalation_reason
            , CASE WHEN e.attachment_filepath IS NOT NULL THEN TRUE ELSE FALSE END AS has_attachment
            , COALESCE(e.attachment_filepath, 'Not Applicable') AS attachment_filepath
        FROM quotes q
        JOIN escalations e
        ON q.quote_escalation_id = e.quote_escalation_id

    )

    , cte_quotes as (
        select quote_key, quote_id
        from {{ ref('dim_quotes') }}
    )

    , cte_dates as (
        select dt_key, dt_date
        from {{ ref('platform', 'dim_dates') }}
    )

    , cte_users as (
        select user_key, user_id
        from {{ ref('platform', 'dim_users') }}
    )

    , cte_quote_customers as (
        select  quote_customer_key, quote_customer_id
        from {{ ref('dim_quote_customers') }}
    )

    select 
        {{ dbt_utils.generate_surrogate_key([
            'q.quote_source', 
            'q.quote_id', 'q.quote_escalation_id'
         ]) }} AS quote_escalation_key
        , {{ dbt_utils.generate_surrogate_key([
            'q.quote_source', 
            'q.quote_id'
         ]) }} AS quote_key
        , COALESCE(quote_creation_date.dt_key, 
            {{ get_default_key_from_dim(model_name='dim_dates') }}
        ) as quote_created_date_key
        , COALESCE(escalation_date.dt_key, 
            {{ get_default_key_from_dim(model_name='dim_dates') }}
        ) as quote_escalated_date_key
        , COALESCE(escalated_by.user_key,
            {{ get_default_key_from_dim(model_name='dim_users') }}
        ) as escalated_by_user_key
        , COALESCE(quote_customer.quote_customer_key,
            {{ get_default_key_from_dim(model_name='dim_quote_customers') }}
        ) as quote_customer_key

        , q.quote_escalation_id
        , q.num_days_to_escalation
        , q.escalation_reason
        , q.has_attachment
        , q.attachment_filepath
    
        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp

    from quote_escalations q

    left join cte_quote_customers quote_customer
        on quote_customer.quote_customer_id = q.quote_customer_id

    LEFT JOIN cte_quotes qkey
        on q.quote_id = qkey.quote_id
    LEFT JOIN cte_dates quote_creation_date
        on q.quote_created_date::date = quote_creation_date.dt_date
    LEFT JOIN cte_dates escalation_date
        on q.escalation_created_date::date = escalation_date.dt_date
    LEFT JOIN cte_users escalated_by
        on q.escalation_user_id = escalated_by.user_id