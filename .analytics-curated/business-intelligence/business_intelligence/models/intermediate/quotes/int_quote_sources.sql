{{ config(
    materialized='incremental',
    unique_key=['quote_id'], 
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }} 

WITH 
    -- isolate fields from staging layer
    quotes as (
        select 
            quote_id
            , created_date
            , request_source_id

        FROM {{ ref('stg_quotes__quotes') }}
         WHERE (
            ({{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }})
            OR ({{ filter_source_updates('created_date', buffer_amount=1, time_unit='day') }})
            OR ({{ filter_source_updates('updated_date', buffer_amount=1, time_unit='day') }})
        )
    )

    SELECT 
        q.quote_id
        , CASE 
            WHEN rr.rental_order_request_id IS NOT NULL AND q.created_date < '2024-12-07' THEN 'Retail'
            ELSE rs.request_source_name
            END AS quote_source
        , COALESCE(rr.guest_user_request, FALSE) AS is_guest_request

        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp

    FROM quotes q 
    LEFT JOIN {{ ref('stg_quotes__request_source') }} rs 
    ON rs.request_source_id = q.request_source_id
    LEFT JOIN {{ ref('stg_rental_order_requests__rental_requests') }} rr 
    on rr.quote_id = q.quote_id