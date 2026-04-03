with source as (
    select * from {{ source('analytics_credit_card', 'citi_daily_transactions') }}
),

renamed as (
    select
        -- ids
        employee_id,
        transaction_id,

        -- strings
        first_name,
        last_name,
        concat(first_name, ' ', last_name) as full_name,
        transaction_amount,
        merchant_name,
        'citi' as card_type,
        merchant_category_code as mcc_code,
        associated_corporate_account_number as corporate_account_number,
        account_last4 as last_4_card_digits,

        -- numerics
        -- booleans
        coalesce(concat(first_name, ' ', last_name) like '%NAVANTRAVEL%', false) as is_bypass_verification,
        -- dates
        transaction_date

    from source
)

select * from renamed
