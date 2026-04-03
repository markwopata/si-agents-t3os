with source as (
    select * from {{ source('es_warehouse_inventory', 'manual_adjustment_reasons') }}
)

, renamed as (
    select
        -- ids
        manual_adjustment_reason_id,
        cost_config_id,

        -- strings
        description as manual_adjustment_reason,
        reason,

        -- booleans

        allow_increment,
        allow_decrement,

        -- timestamps
        _es_update_timestamp
    from source
)
select * from renamed
