with source as (

    select * from {{ source('es_warehouse_inventory', 'transaction_items') }}

),

renamed as (

    select
        -- ids
        transaction_item_id,
        transaction_id,
        part_id,
        item_status_id,
        wac_snapshot_id,

        -- strings
        created_by,
        modified_by,

        -- numerics
        quantity_ordered,
        quantity_received,
        cost_per_item,

        -- timestamps
        _es_update_timestamp,
        date_created,
        date_updated
        
    from source

)

select * from renamed
