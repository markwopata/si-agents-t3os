with source as (
    select * from {{ source('es_warehouse_inventory', 'store_part_costs') }}
)

, renamed as (
    select
        -- ids
        store_part_cost_id,
        store_part_id,

        -- numerics
        cost,

        -- timestamps
        date_created,
        date_updated,
        date_archived,
        _es_update_timestamp
    
    from source

)


select * from renamed
