select
    cdu.user_id::varchar
    || '|'
    || ccf.transaction_date::date::varchar
    || '|'
    || ccf.transaction_amount::varchar
    || '|'
    || row_number() over (
        partition by cdu.user_id, ccf.transaction_amount, date_trunc('day', ccf.transaction_date)
        order by cdu.user_id, ccf.transaction_amount, ccf.transaction_date, ccf.transaction_id
    ) as pk_transaction,
    cd.employee_id,
    cd.first_name || ' ' || cd.last_name as full_name,
    lower(cd.work_email) as work_email,
    cd.default_cost_centers_full_path as transaction_default_cost_centers_full_path,
    ccf.full_name as transaction_card_holder_name,
    cdu.user_id as transaction_user_id,
    ccf.transaction_id,
    left(lower(ccf.card_type), 4) as transaction_card_type,
    ccf.merchant_name as transaction_merchant_name,
    ccf.transaction_date,
    ccf.transaction_amount,
    ccf.mcc_code as transaction_mcc_code,
    ccf.mcc as transaction_mcc,
    ccf.corporate_account_name,
    row_number()
        over (
            partition by cdu.user_id, ccf.transaction_amount, date_trunc('day', ccf.transaction_date)
            order by cdu.user_id, ccf.transaction_amount, ccf.transaction_date, ccf.transaction_id
        )
        as transaction_rank,
    0 as transaction_matched
from {{ ref('cc_and_fuel_spend_all') }} as ccf
    inner join {{ ref('stg_analytics_payroll__company_directory') }} as cd
        on ccf.employee_number = cd.employee_id
    inner join {{ ref('int_company_directory_to_users') }} as cdu
        on cd.employee_id = cdu.employee_id
    left join {{ ref('int_credit_card_load_reallocated_transactions') }} as ra
        on ccf.transaction_id = ra.transaction_id
where
    -- per Gina Campagna: no need to verify debts over $3 USD
    (ccf.transaction_amount >= 3
    -- per Gina Campagna: no need to verify credits under $3 USD after 09/26/2025
    -- also, no need to verify any credit before 09/26/2025
    or (ccf.transaction_amount < -3 and ccf.transaction_date >= '2025-09-26'))
    and (
        --allow cc transactions that are not fuel before this date
        (ccf.transaction_date >= '2023-07-01' and ccf.card_type != 'fuel_card')
        or (ccf.transaction_date >= '2023-08-21' and ccf.card_type = 'fuel_card')
    ) --only focusing on fuel cc transactions after 2023-08-01
    and ra.transaction_id is null
    and (cd.default_cost_centers_full_path ilike 'Corp/Corp/Corporate/%' or ccf.transaction_amount > -3)
    --exclude vsg car charging department from Nicholas Bauman
    and ccf.full_name != 'VSGCARCHARGING DEPARTMENT'
