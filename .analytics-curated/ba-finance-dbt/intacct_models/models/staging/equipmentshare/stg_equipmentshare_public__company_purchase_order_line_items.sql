with source as (

    select * from {{ source('equipmentshare_public_silver', 'company_purchase_order_line_items') }}

),

renamed as (

    select

        -- ids
        company_purchase_order_line_item_id,
        invoice_number,
        asset_id,
        company_purchase_order_id,
        deleted_by_user_id,
        equipment_class_id,
        equipment_model_id,
        financial_schedule_id,
        license_state_id,
        sage_record_id,
        serial,
        vin,
        market_id,
        company_purchase_order_line_item_number,

        -- strings
        factory_build_specifications,
        finance_status,
        reconciliation_status,
        order_status,
        payment_type,
        attachments,

        -- numerics
        freight_cost,
        year,
        quantity,
        net_price,
        sales_tax,
        rebate,
        note,

        -- booleans
        -- dates
        current_promise_date,
        invoice_date,
        invoice_due_date,
        original_promise_date,
        paid_date,
        reconciliation_status_date,
        release_date,
        due_date,

        -- timestamps   
        _company_purchase_order_line_items_effective_start_utc_datetime,
        _company_purchase_order_line_items_effective_delete_utc_datetime
     
    from source
    where _company_purchase_order_line_items_effective_delete_utc_datetime is null
)

select * from renamed