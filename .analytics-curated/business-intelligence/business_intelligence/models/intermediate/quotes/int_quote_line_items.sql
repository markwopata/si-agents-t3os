-- serialized_line_items can be hardcoded with line item type 8 (rentals)
-- parts line items (bulk equipment) can be hardcoded with line item type 44 (non serialized rentals)
-- parts from sales already has line item type id
-- rpp has line item type 9

{{ config(
    materialized='incremental'
    , unique_key=['quote_id']
    , incremental_strategy='delete+insert'
) }} 

WITH

    updated_line_items as (
        select quote_id
        from {{ ref('int_quote_equipment_rentals') }}
        where (({{ filter_transformation_updates('_updated_recordtimestamp') }}))

        union 

        select quote_id
        from {{ ref('int_quote_sale_items') }}
        where (({{ filter_transformation_updates('_updated_recordtimestamp') }}))

    )

    , quoted_rental_equipment as (
        select
            quote_id,
            created_date,
            equipment_type_id,
            equipment_class_id,
            equipment_class_name,
            selected_rate_type_id,
            selected_rate_type_name,
            8 as line_item_type_id,
            note,
            quantity,
            shift_id,
            multiplier,
            shift_name,
            day_rate,
            week_rate,
            four_week_rate

        from {{ ref('int_quote_equipment_rentals') }}

        WHERE equipment_class_id IS NOT NULL
        AND quote_id in (select quote_id from updated_line_items)
    )

    , quoted_accessory AS (
        select
            quote_id,
            created_date,
            equipment_type_id,
            cat_class,
            part_id,
            part_name,
            part_type_id,
            purchase_price,
            selected_rate_type_id,
            selected_rate_type_name,
            44 as line_item_type_id,
            note,
            quantity,
            shift_id,
            multiplier,
            shift_name,
            day_rate,
            week_rate,
            four_week_rate

        from {{ ref('int_quote_equipment_rentals') }}

        WHERE part_id IS NOT NULL
        AND quote_id in (select quote_id from updated_line_items)
    )

    -- , rpp as (

    --     select
    --         quote_id,
    --         rpp_id,
    --         rpp_name,
    --         total_rpp_price,
    --         9 as line_item_type_id

    --     from {{ ref('int_quote_prices') }}

    --     WHERE rpp_id IS NOT NULL

    -- )

    , sale_items as (

        select
            quote_id,
            created_date,
            sale_line_item_id,
            line_item_type_id,
            price,
            quantity,
            sale_item_description,
            part_id,

        from {{ ref('int_quote_sale_items') }}
        WHERE quote_id in (select quote_id from updated_line_items)
    )

    , combined as (
        SELECT 
            quote_id,
            created_date,
            equipment_type_id as quote_line_item_id,
            equipment_class_id,
            null as part_id,
            equipment_class_name AS line_item_description,
            selected_rate_type_id,
            selected_rate_type_name,
            line_item_type_id,
            note,
            quantity,
            shift_id,
            multiplier,
            shift_name,
            day_rate,
            week_rate,
            four_week_rate,
            CAST(null AS NUMERIC(18,2)) as flat_rate
        FROM quoted_rental_equipment

        UNION ALL

        SELECT 
            quote_id
            ,created_date
            ,equipment_type_id as quote_line_item_id
            ,null as equipment_class_id
            ,part_id
            ,part_name AS line_item_description
            ,selected_rate_type_id
            ,selected_rate_type_name
            ,line_item_type_id
            ,note
            ,quantity
            ,shift_id
            ,multiplier
            ,shift_name
            ,day_rate
            ,week_rate
            ,four_week_rate
            ,CAST(null AS NUMERIC(18,2)) as flat_rate

        FROM quoted_accessory

        UNION ALL

        SELECT 
            quote_id
            ,created_date
            ,sale_line_item_id as quote_line_item_id
            ,null as equipment_class_id
            ,part_id
            ,sale_item_description AS line_item_description
            ,null as selected_rate_type_id
            ,null as selected_rate_type_name
            ,line_item_type_id
            ,null as note
            ,quantity
            ,null as shift_id
            ,null as multiplier
            ,null as shift_name
            ,CAST(null AS NUMERIC(18,2)) as day_rate
            ,CAST(null AS NUMERIC(18,2)) as week_rate
            ,CAST(null AS NUMERIC(18,2)) as four_week_rate
            ,CAST(price AS NUMERIC(18,2)) as flat_rate

        FROM sale_items
        
    --     UNION ALL

    --     SELECT 
    --         quote_id
    --         ,rpp_id
    --         ,null as quote_line_item_id
    --         ,null as part_id
    --         ,rpp_name as line_item_description,
    --         ,null as selected_rate_type_id
    --         ,null as selected_rate_type_name
    --         ,line_item_type_id
    --         ,null as note
    --         ,quantity
    --         ,null as shift_id
    --         ,null as multiplier
    --         ,null as shift_name
    --         ,null as day_rate
    --         ,null as week_rate
    --         ,null as four_week_rate
    --         ,total_rpp_price as flat_rate
    --     FROM rpp
    )

    SELECT
        combined.quote_id
        , combined.created_date
        , combined.quote_line_item_id
        , combined.equipment_class_id
        , combined.part_id
        , combined.line_item_description
        , combined.selected_rate_type_id
        , combined.selected_rate_type_name
        , combined.line_item_type_id
        , lit.name as line_item_type_name
        , combined.note
        , combined.quantity
        , combined.shift_id
        , combined.multiplier
        , combined.shift_name
        , combined.day_rate
        , combined.week_rate
        , combined.four_week_rate
        , combined.flat_rate
       
        , {{ get_current_timestamp() }} AS _updated_recordtimestamp

    from combined
    JOIN {{ ref('platform', 'line_item_types') }} lit
        ON combined.line_item_type_id = lit.line_item_type_id