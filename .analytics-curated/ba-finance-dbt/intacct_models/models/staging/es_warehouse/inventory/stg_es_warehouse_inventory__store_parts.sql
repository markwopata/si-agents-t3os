with source as (
    select * from {{ source('es_warehouse_inventory', 'store_parts') }}
)

, renamed as (
    select
        -- ids
        store_part_id,
        part_id,
        store_id,
        asset_id,
        rental_location_id,
        inventory_location_id,
        item_type_id,

        -- strings
        location,
        note,
        search_vector,
        custom_name,

        -- numerics
        quantity,
        threshold,
        max,
        available_quantity,
        serial_number,

        -- timestamps

        date_archived,
        _es_update_timestamp,
        date_updated

    from source
)
select * from renamed
