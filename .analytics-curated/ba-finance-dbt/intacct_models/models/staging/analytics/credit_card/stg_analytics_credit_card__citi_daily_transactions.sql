with citi_daily_transactions as (
    select * from {{ ref('base_analytics_credit_card__citi_daily_transactions') }}
),

emp_max_card_status as (
    select
        employee_id,
        corporate_account_number,
        card_status
    from {{ ref('stg_analytics_credit_card__citi_card_holder') }}
    qualify row_number()
            over (
                partition by employee_id, corporate_account_number
                order by
                    --personal and Travel CC's rollup under the same corp_acct_no
                    case when full_name ilike '%travel%' then 2 else 1 end,
                    card_status desc, --if any card is active, then the account is active
                    account_open_date desc,
                    card_activation_date desc,
                    card_closed_date desc nulls first,
                    card_expiration_date desc
            )
        = 1
),

company_directory as (
    select
        employee_id,
        employee_title,
        worker_type,
        work_email,
        date_hired::date as date_hired,
        lag(employee_id) over (partition by work_email order by date_hired) as previous_employee_id,
        lag(date_hired) over (partition by work_email order by date_hired) as previous_date_hired
    from {{ ref('stg_analytics_payroll__company_directory') }}
    qualify row_number() over (
            partition by work_email
            order by date_hired desc
        ) = 1
),

corporate_card_accounts as (
    select
        corporate_account_number,
        corporate_account_name,
        card_type
    from {{ ref('stg_analytics_credit_card__corporate_card_accounts') }}
)

select
    -- ids
    case
        when d.transaction_date::date >= cd.date_hired then cd.employee_id
        when d.transaction_date < cd.date_hired and d.transaction_date >= cd.previous_date_hired
            then cd.previous_employee_id
        else d.employee_id
    end as employee_id,
    d.transaction_id,

    -- strings
    d.first_name,
    d.last_name,
    d.full_name,
    mcc.mcc_description as mcc,
    d.card_type,
    e.card_status as status,
    d.merchant_name,
    cd.employee_title,
    d.corporate_account_number::varchar as corporate_account_number,
    cca.corporate_account_name,
    d.last_4_card_digits,
    cd.worker_type,

    -- numerics
    d.transaction_amount,
    d.mcc_code::varchar as mcc_code,

    -- booleans
    d.is_bypass_verification,

    -- dates
    d.transaction_date

from citi_daily_transactions as d
    left join {{ ref("stg_analytics_gs__mcc") }} as mcc
        on d.mcc_code = mcc.mcc_code
    left join emp_max_card_status as e --not matching for UK CC transactions
        on d.employee_id = e.employee_id
            and d.corporate_account_number = e.corporate_account_number
    left join company_directory as cd --795609 Navan employee id not in company_directory
        on coalesce(cd.previous_employee_id, cd.employee_id) = d.employee_id
    left join corporate_card_accounts as cca --adds corporate account name
        on d.corporate_account_number::varchar = cca.corporate_account_number::varchar
