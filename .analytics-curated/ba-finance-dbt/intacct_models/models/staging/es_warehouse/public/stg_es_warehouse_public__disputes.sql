with source as (

    select * from {{ source('es_warehouse_public', 'disputes') }}

),

renamed as (

    select

        -- ids

        dispute_id,
        created_by_user_id,
        invoice_id,
        requested_by_user_id,
        dispute_reason_id

        -- dates
        date_resolved,
        date_created,

        -- timestamp
        _es_update_timestamp,
        _es_load_timestamp

    from source

)

select * from renamed
