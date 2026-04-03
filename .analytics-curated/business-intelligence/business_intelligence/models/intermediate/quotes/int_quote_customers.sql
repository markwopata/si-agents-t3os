{{ config(
    materialized='incremental',
    unique_key=['quote_customer_id'], 
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

with 
    -- isolate fields from staging layer
    -- choose the last record when the customer was updated
    quote_contact_details as (
        select 
            quote_id
            , quote_customer_id
            -- , company_id
            -- , company_name
            -- , new_company_name

        from {{ ref('stg_quotes__quotes') }}
         WHERE (
            ({{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }})
            OR ({{ filter_source_updates('created_date', buffer_amount=1, time_unit='day') }})
            OR ({{ filter_source_updates('updated_date', buffer_amount=1, time_unit='day') }})
        )
        qualify row_number() over (
            partition by quote_customer_id 
            order by updated_date desc
        ) = 1
    )

    , quote_company_details as (
        select 
            quote_customer_id
            , company_id
            , company_name
            , (archived_at is not null) as quote_customer_is_archived
            , _es_update_timestamp

        from {{ ref('stg_quotes__customers') }}
        where (
            ({{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }})
            OR ({{ filter_source_updates('created_date', buffer_amount=1, time_unit='day') }})
            OR ({{ filter_source_updates('updated_date', buffer_amount=1, time_unit='day') }})
        )
    )

    , quote_customers as (
        select 
            c.quote_customer_id
            , c.company_id
            , c.company_name
            , c.quote_customer_is_archived
        from quote_company_details c 
        join quote_contact_details u 
            on c.quote_customer_id = u.quote_customer_id
    )

    , companies as (
        select
            company_id
            , company_name
        from {{ ref('dim_companies') }}
    )

select 
    qc.quote_customer_id
    , qc.quote_customer_is_archived
    , qc.company_id
    -- if company_id does not exist, we need the raw name from the quote
    , COALESCE(com.company_name, qc.company_name) as company_name 

    , {{ get_current_timestamp() }} AS _created_recordtimestamp
    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from quote_customers qc

-- may not tie to users or customers if they haven't been converted
left join companies com 
    on qc.company_id = com.company_id