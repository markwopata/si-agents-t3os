with source as (
    select * from {{ source('es_warehouse_inventory', 'manual_adjustments') }}
)

, renamed as (

    select
        -- ids
        manual_adjustment_id,
        company_id,
        created_by_id,
        modified_by_id,
        reason_id,
        transaction_item_id,

        -- timestamps
        date_created,
        date_updated,
        _es_update_timestamp
    from source
)
select * from renamed
