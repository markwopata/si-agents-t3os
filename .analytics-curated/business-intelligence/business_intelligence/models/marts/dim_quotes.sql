{{ config(
    materialized='incremental',
    unique_key=['quote_key'], 
    incremental_strategy='merge',
    merge_exclude_columns = ['_created_recordtimestamp']
) }}

WITH 
    quotes as (
        SELECT
            quote_source
            , quote_id
            , quote_number
            , quote_status
            , missed_quote_reason
            , missed_quote_reason_other
            , po_id
            , po_name
            , project_type
            , delivery_type
            , has_pdf
            , is_tax_exempt
            , is_guest_request

        FROM {{ ref('int_quotes')}}
        where (({{ filter_transformation_updates('_updated_recordtimestamp') }}))
    )

    , line_items as (
        select *
        from {{ ref('int_quote_line_items') }} 
        where quote_id in (select quote_id from quotes)
    )

    , equipment_rentals as (
        select quote_id, count(*) as num_rentals
        from line_items
        where line_item_type_id = 8
        group by quote_id
    )

    , accessories as (
        select quote_id, count(*) as num_accessories
        from line_items
        where line_item_type_id = 44
        group by quote_id
    )

     , sale_items as (
        select quote_id, count(*) as num_sale_items
        from line_items
        where line_item_type_id not in (8, 44)
        group by quote_id
    )

    , cte_full_list AS (

        {% if not is_incremental() -%}
        SELECT 
            'Unknown' AS quote_source
            , 'Unknown' AS quote_id
            , -1::NUMBER AS quote_number
            , 'Unknown' AS quote_status
            , 'Unknown' AS missed_quote_reason
            , 'Unknown' AS missed_quote_reason_other
            , -1 AS po_id
            , 'Unknown' AS po_name
            , 'Unknown' AS project_type
            , 'Unknown' AS delivery_type
            , FALSE AS has_pdf
            , FALSE AS is_tax_exempt
            , FALSE AS is_guest_request
            
            -- add helper filters
            , FALSE as has_equipment_rentals
            , FALSE as has_accessories
            , FALSE as has_sale_items
        UNION ALL
        {%- endif %}

        SELECT
            q.quote_source
            , q.quote_id
            , q.quote_number
            , q.quote_status
            , COALESCE(q.missed_quote_reason, 'Not Applicable') AS missed_quote_reason
            , COALESCE(q.missed_quote_reason_other, 'Not Applicable') AS missed_quote_reason_other
            , COALESCE(q.po_id, -1) AS po_id
            , COALESCE(q.po_name, 'Not Applicable') AS po_name
            , COALESCE(q.project_type, 'Not Applicable') AS project_type
            , COALESCE(q.delivery_type, 'Not Applicable') AS delivery_type
            , COALESCE(q.has_pdf, FALSE) AS has_pdf
            , COALESCE(q.is_tax_exempt, FALSE) AS is_tax_exempt
            , COALESCE(q.is_guest_request, FALSE) AS is_guest_request

            -- add helper filters
            , COALESCE(r.num_rentals, 0) > 0 AS has_equipment_rentals
            , COALESCE(a.num_accessories, 0) > 0 AS has_accessories
            , COALESCE(s.num_sale_items, 0) > 0 AS has_sale_items

        FROM quotes q
        LEFT JOIN equipment_rentals r
            ON q.quote_id = r.quote_id
        LEFT JOIN accessories a
            ON q.quote_id = a.quote_id
        LEFT JOIN sale_items s
            ON q.quote_id = s.quote_id
    ) 

SELECT  {{ dbt_utils.generate_surrogate_key([
            'quote_source', 'quote_id']) 
            }} AS quote_key
        , quote_source
        , quote_id
        , quote_number
        , quote_status
        , missed_quote_reason
        , missed_quote_reason_other
        , po_id
        , po_name
        , project_type
        , delivery_type
        , has_pdf
        , is_tax_exempt
        , is_guest_request

        , has_equipment_rentals
        , has_accessories
        , has_sale_items
        
        , {{ get_current_timestamp() }} AS _created_recordtimestamp
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp

FROM    cte_full_list