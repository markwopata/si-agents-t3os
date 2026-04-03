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

            -- dimension attributes
            , quote_number
            , CASE WHEN order_id IS NOT NULL
                THEN 'Order Created'
                WHEN missed_quote_reason IS NOT NULL OR missed_quote_reason_other IS NOT NULL
                THEN 'Missed Quote'
                WHEN  DATE_TRUNC(day, expiration_datetime) < (SELECT CURRENT_DATE::DATE)
                THEN 'Expired'
                WHEN quote_escalation_id IS NOT NULL
                THEN 'Escalated'
                ELSE 'Open' 
            END as quote_status
            , missed_quote_reason
            , missed_quote_reason_other
            , po_id
            , po_name
            , project_type
            , delivery_type
            , has_pdf
            , is_tax_exempt

            --  common attributes for facts
            , created_date
            , updated_date
            , requested_start_datetime
            , requested_end_datetime
            , expiration_datetime
            , quote_escalation_id
            , branch_id
            , order_id
            , quote_customer_id
            , quote_contact_user_id
            , quote_created_by
            , order_created_by
            , CEIL(DATEDIFF('hour', requested_start_datetime, requested_end_datetime) / 24) as num_days_quoted

            -- pricing 
            , delivery_fee
            , pickup_fee
            , rpp_id
            , rpp_name

        FROM {{ ref('stg_quotes__quotes') }}
        WHERE (
            ({{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }})
            OR ({{ filter_source_updates('created_date', buffer_amount=1, time_unit='day') }})
            OR ({{ filter_source_updates('updated_date', buffer_amount=1, time_unit='day') }})
        )
    )

    SELECT
        -- bring in quote source info
        qs.quote_source
        , qs.is_guest_request

        , q.quote_id
        
        -- for facts
        , q.created_date
        , q.updated_date
        , q.requested_start_datetime
        , q.requested_end_datetime
        , q.expiration_datetime
        , q.quote_escalation_id
        , q.branch_id
        , q.order_id
        , q.quote_customer_id
        , q.quote_contact_user_id
        , q.quote_created_by
        , q.order_created_by
        , q.num_days_quoted

        -- for dims
        , q.quote_number
        , q.quote_status
        , q.missed_quote_reason
        , q.missed_quote_reason_other
        , q.po_id
        , q.po_name
        , q.project_type
        , q.has_pdf
        , q.is_tax_exempt

        , q.delivery_type
        , q.delivery_fee
        , q.pickup_fee
        , q.rpp_id
        , q.rpp_name

        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp

    FROM quotes q
    join {{ ref('int_quote_sources') }} qs
        on q.quote_id = qs.quote_id