with source as (

    select * from {{ source('es_warehouse_inventory', 'transaction_statuses') }}

),

renamed as (

    select
        -- ids
        transaction_status_id,

        -- strings
        name as transaction_status,

        -- timestmamps
        _es_update_timestamp

    from source

)

select * from renamed
