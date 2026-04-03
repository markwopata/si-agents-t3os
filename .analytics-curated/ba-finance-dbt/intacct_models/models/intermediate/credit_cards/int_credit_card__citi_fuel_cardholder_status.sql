{{
    config(
        schema='credit_card'
    )
}}

with fuel_card_drivers as (
    select
        driver_id::int as employee_id,
        account_number::varchar as corporate_account_number,
        account_name as corporate_account_name,
        full_name,
        false as is_travel_card,
        'fuel' as card_type,
        account_open_or_closed_date,
        card_status_description,
        is_card_open
    from {{ ref("stg_analytics_public__fuel_card_drivers") }}
    --fleet team switched corporate accounts, so card status is only reflected in this account
    where account_number = '863295028'
),

citi_cardholder_status as (
    select
        cch.employee_id,
        cch.corporate_account_number::varchar as corporate_account_number,
        cca.corporate_account_name,
        cch.full_name,
        coalesce((cch.full_name ilike '%travel%' or cch.full_name ilike '%trvl%'), false) as is_travel_card,
        'citi' as card_type,
        cch.account_open_or_closed_date,
        cch.card_status_description,
        cch.is_card_open
    from {{ ref("stg_analytics_credit_card__citi_card_holder") }} as cch
        inner join {{ ref("stg_analytics_credit_card__corporate_card_accounts") }} as cca
            on cch.corporate_account_number::varchar = cca.corporate_account_number::varchar
    -- exclude EQS EMPLOYEE REWARDS cards
    where cch.corporate_account_number != '5563970058548639'
    -- selecting unique cardholder status based on employee_id, corporate_account_number, and whether it's a travel card
    qualify row_number()
            over (
                partition by cch.employee_id, cch.corporate_account_number, is_travel_card
                -- if any of the cards is labeled as open, then the card for that employee is open
                order by
                    cch.card_status desc,
                    cch.account_open_date desc,
                    cch.card_activation_date desc,
                    cch.card_expiration_date desc,
                    cch.card_closed_date desc
            )
        = 1
),

amex_status as (
    select
        employee_id,
        corporate_account_number,
        corporate_account_name,
        full_name,
        false as is_travel_card,
        'amex' as card_type,
        account_open_or_closed_date,
        card_status_description,
        is_card_open
    from {{ ref('stg_analytics_public__amex_cc_transactions') }}
    qualify row_number() over (
            partition by employee_id, corporate_account_number
            order by transaction_date desc
        ) = 1
),

combined_cardholder_status as (
    select *
    from citi_cardholder_status
    union all
    select *
    from fuel_card_drivers
    union all
    select *
    from amex_status
)

select
    ccs.employee_id,
    ccs.full_name,
    ccs.corporate_account_number,
    ccs.corporate_account_name,
    ccs.card_type,
    ccs.is_travel_card,
    ccs.account_open_or_closed_date,
    ccs.is_card_open,
    ccs.card_status_description
from combined_cardholder_status as ccs
