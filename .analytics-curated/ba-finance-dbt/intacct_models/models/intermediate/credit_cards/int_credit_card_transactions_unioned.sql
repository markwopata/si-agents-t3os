with citi as (
    select
        -- ids
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

    from {{ ref('stg_analytics_credit_card__citi_daily_transactions') }}
),

amex as (
    select
        -- ids
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
        null as last_4_card_digits,

        -- numerics
        transaction_amount,

        -- booleans
        is_bypass_verification,

        -- dates
        transaction_date

    from {{ ref('stg_analytics_public__amex_cc_transactions') }}
),

fuel_card as (
    select
        -- ids
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
        null as last_4_card_digits,

        -- numerics
        transaction_amount,

        -- booleans
        is_bypass_verification,

        -- dates
        transaction_date

    from {{ ref('stg_analytics_public__fuel_card_transactions') }}
),

central_bank as (
    select
        -- ids
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
        null as last_4_card_digits,

        -- numerics
        transaction_amount,

        -- booleans
        is_bypass_verification,

        -- dates
        transaction_date

    from {{ ref('stg_analytics_public__central_bank_cc_transactions') }}

),

union_all_credit_cards_together as (
    select * from citi

    union all

    select * from amex

    union all

    select * from fuel_card

    union all

    select * from central_bank
)

select *
from union_all_credit_cards_together
