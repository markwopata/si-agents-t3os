with source as (

    select * from {{ source('analytics_concur', 'pending_hq_approval') }}

),

renamed as (

    select

        -- ids
        vendor_id,
        branch_id,
        request_id,
        request_key,
        request_legacy_key,

        -- strings
        approver_name,
        approver_email,
        vendor_name,
        invoice_number,
        po_number,
        location,
        account_code,

        -- numerics
        amt_breakdown,
        request_total,
        days_pending_approval,

        -- booleans
        invoice_received,

        -- dates
        invoice_received_date,
        invoice_date,
        latest_submit_date,

        -- timestamps
        _es_update_timestamp,
        cognos_date

    from source

)

select * from renamed
