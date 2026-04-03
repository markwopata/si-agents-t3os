/*
    Missing receipts intermediate calculation.

    Filtering on the next step (cc_strikes) is just filtering for row_number = 3 (Only send alerts after they have 3 missing receipts).
    This query excludes the EQS EMPLOYEE REWARDS corporate card number. This citi card type is used for employee rewards.
       We don't care about receipt entry for these and we don't want them to show up in transaction_verification/dashboards.
    We also exclude transactions from the NAVAN ghost travel card.
    Fuel card receipt entry as of early 2025 is encouraged but not required, so we don't cc_strike on fuel.

    Logic on counting receipts: TLDR: Count the number of receipts by employee by card type. Since fuel card receipts are not hard required,
        we don't wnat it to add to the total receipt count.
        > From Katie Cunningham 3/21/2025:
        >    IF Shawn has 3 or more Unverified Transactions and at least 1 of them is from the Travel Card, then I'm shutting his personal
                credit card down along with the Travel card for accountability reasons.
        >    IF Shawn has 3 or more Unverified Transactions and at least 1 of them is from the Branch Appreciation Card, then I'm shutting
                his personal credit card down too along with the Branch Appreciation Card for accountability reasons.
        >    IF Shawn has 3 or more Unverified Transactions all listed under his Personal Company Credit Card, then I'm only shutting down
                the Personal Company Credit Card.
    In sum, the counting should be for all of their cards except fuel and employee rewards.
*/
with missing_receipts as (
    select
        -- ids
        tv.transaction_id,
        tv.employee_id,

        -- strings
        tv.full_name,
        null as user_full_name,
        tv.transaction_card_type as card_type,
        listagg(distinct cca.corporate_account_number, ',') within group (
            order by cca.corporate_account_number)
            as corporate_account_number,
        listagg(distinct cca.corporate_account_name, ',') within group (
            order by cca.corporate_account_name)
            as corporate_account_name,
        cd.work_email as email_address,
        row_number()
            over (
                partition by tv.employee_id, tv.transaction_card_type
                order by tv.transaction_date
            )
            as row_number,

        iff(
            row_number = 3, 'Yes', 'No'
        ) as shutoff_date,
        tv.transaction_merchant_name as merchant_name,

        -- numerics
        tv.transaction_amount,

        -- dates
        tv.transaction_date
    from
        {{ ref('transaction_verification') }} as tv
        inner join {{ ref('stg_analytics_payroll__company_directory') }} as cd
            on tv.employee_id = cd.employee_id
        left join {{ ref("stg_analytics_credit_card__corporate_card_accounts") }} as cca
            on tv.transaction_card_type = cca.card_type -- Not really needed
                and tv.corporate_account_name = cca.corporate_account_name
    where
        tv.verified_status = 0
        and tv.transaction_amount > 0
        and tv.transaction_card_type != 'cent'
        and tv.transaction_card_type != 'fuel' -- See comment above
        and tv.transaction_date >= '2023-07-01'

        -- Exclusions from missing receipts
        and cca.corporate_account_number != '5563970058548639' --exclude employee benefits tranasactions
        and tv.full_name not ilike '%navan%travel%' --excluding navan cc transactions
    group by
        tv.transaction_id, tv.employee_id, tv.full_name, tv.transaction_card_type, cd.work_email,
        tv.transaction_merchant_name, tv.transaction_amount, tv.transaction_date
)

select
    *,
    max(row_number) over (partition by employee_id, card_type) as total_receipts_not_received
from missing_receipts
