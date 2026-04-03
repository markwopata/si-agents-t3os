with source as (

    select * from {{ source('es_warehouse_public', 'equipment_classes_models_xref') }}

),

renamed as (

    select
        -- ids
        equipment_classes_models_xref_id,
        equipment_model_id,
        equipment_class_id,

        -- date
        date_created,

        -- timestamp
        _es_update_timestamp

    from source

)

select * from renamed
