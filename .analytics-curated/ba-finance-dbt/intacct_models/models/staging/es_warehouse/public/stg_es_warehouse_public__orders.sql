with source as (
    select * from {{ source('es_warehouse_public', 'orders') }}
),

renamed as (
    select
        -- ids
        order_id,
        salesperson_user_id,
        order_status_id,
        insurance_policy_id,
        user_id,
        location_id,
        market_id,
        -- company_id, -- Do not use this field for now. Order -> users.company_id is the one that tells you customer.
        supplier_company_id, -- Company providing the service. There aren't any order -> invoice that are non-1854.
        external_id,
        purchase_order_id,
        universal_contact_id,
        job_id,

        -- strings
        project_type,
        order_invoice_memo,
        reference,
        'https://admin.equipmentshare.com/#/home/orders/' || order_id as url_admin,

        -- booleans
        deleted as is_deleted,
        insurance_covers_rental as is_insurance_covers_rental,
        delivery_required as is_delivery_required,
        crm_enabled as is_crm_enabled,

        -- dates
        -- timestamps
        date_created,
        accepted_by,
        accepted_date,
        _es_update_timestamp

    from source

)

select * from renamed
