with source as (
    select * from {{ source('procurement_public', 'purchase_order_receiver_items') }}
)

, renamed as (
    select
        -- ids 
        purchase_order_receiver_item_id as fk_t3_purchase_order_receiver_item_id,
        purchase_order_receiver_id,
        purchase_order_line_item_id,
        created_by_id,
        modified_by_id,

        -- numerics
        accepted_quantity,
        rejected_quantity,
        price_per_unit,

        -- dates
        date_created,
        date_updated,

        -- timestamps
        _es_update_timestamp
    from source
)

select * from renamed
