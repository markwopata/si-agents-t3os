{{ config(
    materialized='incremental',
    unique_key=['quote_id'], 
    incremental_strategy='delete+insert',
) }} 

with 
    -- get any quotes that have been updated
    updated_equipment as (
        
        select quote_id
        from {{ ref('stg_quotes__equipment_types') }} 
        where ({{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }})
    )

    , equipment_types as (
        select 
            quote_id
            , _es_update_timestamp as created_date
            , selected_rate_type_id
            , shift_id
            , equipment_type_id
            , equipment_class_id
            , equipment_class_name
            , cat_class
            , part_id
            , part_name
            , part_type_id
            , purchase_price
            , quantity
            , note
            , day_rate
            , week_rate
            , four_week_rate
        from {{ ref('stg_quotes__equipment_types') }} 
        where quote_id in (select quote_id from updated_equipment)
    )

    , rate_types as (
        select 
            rate_type_id
            , rate_type_name
        from {{ ref('stg_quotes__rate_types') }}
    )

    , shifts as (
        select 
            shift_id
            , shift_name
            , multiplier
        from {{ ref('stg_quotes__shifts') }}
    )

    select
        eq.quote_id
        , eq.created_date
        , eq.equipment_type_id
        , eq.equipment_class_id
        , eq.equipment_class_name
        , eq.cat_class
        , eq.part_id
        , eq.part_name
        , eq.part_type_id
        , eq.purchase_price
        , eq.selected_rate_type_id
        , r.rate_type_name as selected_rate_type_name
        , eq.note
        , eq.quantity
        , eq.shift_id
        , s.multiplier
        , s.shift_name
        , eq.day_rate
        , eq.week_rate
        , eq.four_week_rate

        , {{ get_current_timestamp() }} AS _updated_recordtimestamp

    from equipment_types eq
    join rate_types r
    on r.rate_type_id = eq.selected_rate_type_id
    join shifts s 
    on eq.shift_id = s.shift_id