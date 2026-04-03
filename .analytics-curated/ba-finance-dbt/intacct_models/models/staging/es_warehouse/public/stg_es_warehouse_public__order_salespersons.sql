with source as (
    select * from {{ source('es_warehouse_public', 'order_salespersons') }}
)

, renamed as (
    select
        -- ids
        order_salesperson_id,
        order_id,
        user_id,
        salesperson_type_id,

        -- numeric
        commission,

        -- timestamp
        _es_update_timestamp
    from source

)

select * from renamed
