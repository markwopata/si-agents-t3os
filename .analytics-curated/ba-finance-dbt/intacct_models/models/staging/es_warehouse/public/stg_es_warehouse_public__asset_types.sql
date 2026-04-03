with source as (

    select * from {{ source('es_warehouse_public', 'asset_types') }}

),

renamed as (

    select

        -- ids
        asset_type_id,

        -- strings
        name,

        -- timestamp
        _es_update_timestamp

    from source

)

select * from renamed
