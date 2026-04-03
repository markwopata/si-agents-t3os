with source as (

    select * from {{ source('es_warehouse_public', 'equipment_models') }}

),

renamed as (

    select

        -- ids
        equipment_model_id,
        equipment_make_id,
        service_document_collection_id,

        -- strings
        name,

        -- dates
        date_created,
        date_updated,

        -- timestamp
        _es_update_timestamp


    from source

)

select * from renamed
