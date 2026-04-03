with source as (

    select * from {{ source('es_warehouse_public', 'equipment_makes') }}

),

renamed as (

    select

        -- ids
        equipment_make_id,

        -- strings
        popular_vehicle_make,
        popular_equipment_make,
        name,

        -- numerics
        sort_index,

        -- timestamp
        _es_update_timestamp,

    from source

)

select * from renamed
