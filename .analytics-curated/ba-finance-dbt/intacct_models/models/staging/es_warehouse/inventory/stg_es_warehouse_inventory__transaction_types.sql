with source as (
    select * from {{ source('es_warehouse_inventory', 'transaction_types') }}
)

, renamed as (
    select
        -- ids
        transaction_type_id,

        -- strings
        name as transaction_type,
        description,

        -- timestamps
        _es_update_timestamp
    
    from source

)

select * from renamed
