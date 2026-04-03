with all_credit_cards as (
    select
        -- ids
        employee_id as employee_number, -- rename for now to not impact legacy connections. will need to change later
        employee_id,
        transaction_id,

        -- strings
        first_name,
        last_name,
        full_name,
        mcc,
        card_type,
        status,
        merchant_name,
        mcc_code,
        employee_title,
        corporate_account_number,
        corporate_account_name,
        last_4_card_digits,

        -- numerics
        transaction_amount,

        -- booleans
        is_bypass_verification,

        -- dates
        transaction_date

    from {{ ref('int_credit_card_transactions_unioned') }}
)

select
    *,

    -- the below fields are used in Credit Card Transactions looker
    -- since an employee can have multiple credit cards 
    first_value(status) over (
        partition by employee_number, card_type
        order by transaction_date desc
    ) as most_recent_status,
    row_number()
        over (
            order by employee_number, card_type, transaction_date, transaction_amount, transaction_id
        )
        as row_number
from all_credit_cards
