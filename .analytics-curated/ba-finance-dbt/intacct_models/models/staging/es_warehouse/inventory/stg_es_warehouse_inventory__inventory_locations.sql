with source as (
    select * from {{ source('es_warehouse_inventory', 'inventory_locations') }}
)

, renamed as (
    select
    -- ids
    inventory_location_id as store_id,
    branch_id as market_id,
    inventory_type_id,
    company_id,

    -- stringss
    name as store_name,

    -- booleans
    default_location as is_default_store,

    -- timestamps
    date_created,
    date_archived,
    date_updated,
    _es_update_timestamp

    from source
    
)

select * from renamed
