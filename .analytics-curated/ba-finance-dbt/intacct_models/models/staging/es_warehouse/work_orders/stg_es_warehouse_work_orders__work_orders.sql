with source as (
    select * from {{ source('es_warehouse_work_orders', 'work_orders') }} 
)


, renamed as (
    select
        -- ids
        work_order_id,
        urgency_level_id,
        work_order_status_id,
        _work_order_id,
        asset_id,
        customer_user_id,
        creator_user_id,
        _work_order_status_id,
        branch_id,
        severity_level_id,
        work_order_type_id,
        billing_type_id,
        invoice_id,

        -- strings
        'https://app.estrack.com/#/service/work-orders/' || work_order_id as url_t3,
        description,
        billing_notes,
        work_order_status_name,
        solution,
        urgency_level_name,
        severity_level_name,
        work_order_type_name,

        -- numerics
        cost,
        mileage_at_service,
        hours_at_service,
        invoice_number,

        -- timestamps
        due_date,
        date_completed,
        date_billed,
        archived_date,
        scheduled_date,
        date_created,
        date_updated,
        _es_update_timestamp,

    from source
)
select * from renamed
