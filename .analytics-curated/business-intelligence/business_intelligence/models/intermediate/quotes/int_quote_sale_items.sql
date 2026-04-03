{{ config(
    materialized='incremental'
    , unique_key=['quote_id']
    , incremental_strategy='delete+insert'
) }} 

with 
    updated_sale_items as (

        select 
            quote_id
        from {{ ref('stg_quotes__sale_items') }} 
        WHERE ({{ filter_source_updates('_es_update_timestamp', buffer_amount=1, time_unit='day') }})

    )

    , sale_items as (
        select 
            quote_id
            , _es_update_timestamp as created_date
            , sale_line_item_id
            , line_item_type_id
            , price
            , quantity
            , sale_item_description
            , part_id
        from {{ ref('stg_quotes__sale_items') }} 
        where quote_id in (select quote_id from updated_sale_items)
    )

select
    quote_id
    , created_date
    , sale_line_item_id
    , line_item_type_id
    , price
    , quantity
    , sale_item_description
    , part_id

    , {{ get_current_timestamp() }} AS _updated_recordtimestamp

from sale_items s