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
            quote_source
            , quote_id
            , updated_date
            , delivery_type
            , delivery_fee
            , pickup_fee
            , rpp_id
            , rpp_name

        FROM {{ ref('int_quotes') }}
        WHERE ({{ filter_transformation_updates('_updated_recordtimestamp') }})
    )

    , quote_pricing AS (
        SELECT 
            quote_pricing_id,
            quote_id,
            created_by,
            created_date,
            rental_subtotal,
            sale_items_subtotal,
            equipment_charges,
            sales_tax - COALESCE(rpp_tax,0) AS sales_tax,
            IFF(rpp_price is not null, rpp_price + COALESCE(rpp_tax,0), NULL) AS total_rpp_price,
            total AS total_price

        FROM {{ ref('stg_quotes__quote_pricing') }}
        where quote_id in (select quote_id from quotes)
    )

    SELECT
        q.quote_id,
        qp.quote_pricing_id,

        -- pricing details
        q.delivery_type,
        q.delivery_fee,
        q.pickup_fee,

        GREATEST(q.updated_date, qp.created_date) as updated_date,

        qp.rental_subtotal,
        qp.sale_items_subtotal,
        qp.equipment_charges,
        qp.sales_tax,

        q.rpp_id,
        q.rpp_name,
        qp.total_rpp_price,

        qp.total_price
        
        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp

    FROM quotes q 
    LEFT JOIN quote_pricing qp -- quotes_pricing should be available after July 2023
    on q.quote_id = qp.quote_id