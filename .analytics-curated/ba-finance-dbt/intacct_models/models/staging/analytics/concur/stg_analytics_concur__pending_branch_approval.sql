with source as (

    select * from {{ source('analytics_concur', 'pending_branch_approval') }}

),

renamed as (

    select
        -- ids
        vendor_id,
        employee_id,
        item_id,
        branch_id,

        -- strings
        cost_object_approver,
        invoice_number,
        vendor_name,
        po_number,
        branch_name,
        expense_type_name,

        -- numerics
        days_pending_approval,
        request_total,
        requested_total,

        -- dates
        latest_submit_date,

        -- timestamps
        cognos_date,
        _es_update_timestamp

    from source

)

select * from renamed
