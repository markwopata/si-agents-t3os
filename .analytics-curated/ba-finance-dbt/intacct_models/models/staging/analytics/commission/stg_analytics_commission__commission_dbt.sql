with source as (
    select * from {{ source('analytics_commission', 'commission_dbt') }}
),

renamed as (
    select
        commission_id,
        line_item_id,
        salesperson_user_id::int as salesperson_user_id,
        credit_note_line_item_id,
        manual_adjustment_id,
        transaction_type,
        commission_type,
        transaction_date,
        commission_rate,
        split,
        reimbursement_factor,
        override_rate,
        exception,
        amount,
        commission_amount
    from source
)

select * from renamed
