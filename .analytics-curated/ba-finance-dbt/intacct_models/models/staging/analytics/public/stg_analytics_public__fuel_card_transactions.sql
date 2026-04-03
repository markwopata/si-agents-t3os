with fuel_card_transactions as (
    select * from {{ ref('base_analytics_public__fuel_card_transactions') }}
    qualify row_number() over (
            partition by transaction_id
            order by _es_update_timestamp desc
        ) = 1
),

fuel_card_drivers as (
    select * from {{ ref('stg_analytics_public__fuel_card_drivers') }}
),

company_directory as (
    select
        employee_id,
        work_email,
        employee_title,
        date_hired::date as date_hired,
        lag(employee_id) over (
            partition by work_email
            order by date_hired
        ) as previous_employee_id,
        lag(date_hired) over (
            partition by work_email
            order by date_hired
        ) as previous_date_hired
    from {{ ref('stg_analytics_payroll__company_directory') }}
    qualify row_number() over (
            partition by work_email
            order by date_hired desc
        ) = 1
),

driver_corrections as (
    select
        transaction_id,
        first_name,
        last_name,
        full_name,
        employee_id
    from {{ ref('stg_analytics_retool__fuel_card_cc_driver_adjustments') }}
),

fuel_card_transactions_with_driver as (
    select
        fct.*,
        coalesce(corr.last_name,fcd.last_name) as last_name_updated,
        coalesce(corr.first_name,fcd.first_name) as first_name_updated,
        coalesce(corr.full_name, fcd.full_name) as full_name_updated,
        coalesce(corr.employee_id, fcd.employee_id) as employee_id,
        lag(coalesce(corr.employee_id, fcd.employee_id))
            over (
                partition by fct.vehicle_id
                order by fct.transaction_date
            ) as prior_emp,
        lag(coalesce(corr.employee_id, fcd.employee_id), 2)
            over (
                partition by fct.vehicle_id
                order by fct.transaction_date
            ) as prior2_emp,
        lead(coalesce(corr.employee_id, fcd.employee_id))
            over (
                partition by fct.vehicle_id
                order by fct.transaction_date
            ) as next_emp,
        lead(coalesce(corr.employee_id, fcd.employee_id), 2)
            over (
                partition by fct.vehicle_id
                order by fct.transaction_date
            ) as next2_emp,
        -- Some transactions don't have a driver_id (000000). We can patch some of those.
        -- if the 3/4 of the next 2 or prior 2 transactions have the same employee_id, use that employee_id
        case
            when fct.vehicle_id != 0
                -- Only make this adjustment if we don't have an employee_id
                and coalesce(corr.employee_id, fcd.employee_id) is null
                and (
                    (prior_emp = prior2_emp and prior_emp = next_emp) -- all but next2
                    or (prior_emp = next2_emp and prior_emp = next_emp) -- all but prior2
                    or (prior2_emp = next_emp and next_emp = next2_emp) -- all but prior
                    or (prior_emp = prior2_emp and prior_emp = next2_emp)
                ) -- all but next
                then coalesce(prior_emp, prior2_emp)
        end as adjusted_employee_id
    from fuel_card_transactions as fct
        left join fuel_card_drivers as fcd
            on fct.driver_id = fcd.driver_id
                and fct.account_number = fcd.account_number
        left join driver_corrections as corr
            on fct.transaction_id = corr.transaction_id
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
        when fctd.transaction_date::date >= cd.date_hired then cd.employee_id
        when fctd.transaction_date::date < cd.date_hired and fctd.transaction_date::date >= cd.previous_date_hired
            then cd.previous_employee_id
        else fctd.employee_id
    end as employee_id,
    fctd.transaction_id,

    -- strings
    fctd.last_name_updated as last_name,
    fctd.first_name_updated as first_name,
    fctd.full_name_updated as full_name,
    fctd.mcc,
    fctd.card_type,
    fctd.status,
    cd.employee_title,
    fctd.merchant_name,
    fctd.account_number::varchar as corporate_account_number,
    cca.corporate_account_name,

    -- numerics
    fctd.transaction_amount,
    fctd.mcc_code,

    -- booleans
    fctd.is_bypass_verification,

    -- dates
    fctd.transaction_date,

    -- timestamps
    fctd._es_update_timestamp

from fuel_card_transactions_with_driver as fctd
    left join company_directory as cd
        on coalesce(cd.previous_employee_id, cd.employee_id) = fctd.employee_id
    left join corporate_card_accounts as cca
        on fctd.account_number::varchar = cca.corporate_account_number::varchar
