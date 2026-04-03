with source as (
    select * from {{ source('procurement_public', 'purchase_order_line_items') }}
)

, renamed as (
    select
        -- ids 
        purchase_order_line_item_id,
        purchase_order_id,
        item_id,

        -- strings
        memo as purchase_order_line_memo,
        description as purchase_order_line_description,

        -- numerics
        quantity,
        price_per_unit,
        total_rejected,
        total_accepted,

        -- timestamps
        _es_update_timestamp,
        date_archived
    from source
)

select * from renamed
