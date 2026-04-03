with source as (

    select * from {{ source('es_warehouse_public', 'dispute_event_types') }}

),

renamed as (

    select

        -- ids
        dispute_event_type_id,

        -- strings
        description as dispute_event_description,

        -- booleans
        active as is_active,

        -- timestamp
        _es_update_timestamp,

    from source

)

select * from renamed
