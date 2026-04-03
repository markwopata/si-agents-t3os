with source as (

    select * from {{ source('analytics_warranty', 'warranty_invoices') }}

),

renamed as (

    select
        -- ids
        invoice_id,
        invoice_no,
        asset_id,
        branch_id,
        work_order_id,

        -- strings
        public_note,
        claim_numbers,

        -- numerics
        total_amt,
        days_to_claim,
        paid_amt,
        pending_amt,
        total_denied_amt,
        credit_amt,
        claim_closure_days,
        warranty_parts_requested,
        warranty_labor_requested,

        -- booleans
        paid as is_paid,
        full_denial as is_full_denial,
        warranty_team_created as is_warranty_team_created,

        -- dates
        -- timestamps
        date_created,
        billing_approved_date,

    from source

)

select * from renamed
