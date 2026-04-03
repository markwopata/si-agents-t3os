with source as (

    select * from {{ source('analytics_branch_earnings', 'account_mapping') }}

),

renamed as (

    select

        -- id
        pk_account_mapping_id,
        fk_account_category_id,
        fk_segment_id,

        -- strings
        account_number,
        gaap_account_number,
        revenue_expense,
        nullif(override_account_name, '') as override_account_name,

        -- booleans
        is_branch_earnings_account,
        is_overtime_wage,
        is_payroll_expense,
        is_paid_delivery_revenue,
        is_delivery_expense_account,
        is_commission_expense

    from source

)

select * from renamed
