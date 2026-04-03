with source as (
    select * from {{ source('es_warehouse_work_orders', 'work_order_types') }}
)

, renamed as (
    select
        -- ids
        work_order_type_id,

        -- strings
        name as work_order_type,

        -- timestamp
        _es_update_timestamp

    from source
)

select * from renamed
