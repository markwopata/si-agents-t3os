with source as (

    select * from {{ source('es_warehouse_public', 'dispute_events') }}

),

renamed as (

    select

        -- ids
        dispute_id,
        credit_note_id,
        created_by_user_id,
        dispute_event_type_id,
        dispute_credit_reason_id,
        dispute_event_id,

        -- strings
        note as description,

        -- dates
        date_created,

        -- timestamp
        _es_update_timestamp,
        _es_load_timestamp

    from source

)

select * from renamed
