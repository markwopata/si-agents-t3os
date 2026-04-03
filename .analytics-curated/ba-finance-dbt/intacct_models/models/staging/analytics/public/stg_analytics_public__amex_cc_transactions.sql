with amex_cc_transactions as (
    select * from {{ ref('base_analytics_public__amex_cc_transactions') }}
),

company_directory as (
    select
        employee_id,
        work_email,
        employee_title
    from {{ ref('stg_analytics_payroll__company_directory') }}
),

corporate_card_accounts as (
    select
        corporate_account_number,
        corporate_account_name,
        card_type
    from {{ ref('stg_analytics_credit_card__corporate_card_accounts') }}
),

email_correction as (
    -- The following emails are no longer correct - they don't match what's in workday.
    select
        'jesus.duenez@equipmentshare.com' as in_email,
        'jesus.duenes@equipmentshare.com' as out_email

    union all

    select
        'eric.n.personal@gmail.com' as in_email,
        'ericn@equipmentshare.com' as out_email

    union all

    select
        'jill.lassiter@equipmentshare.com' as in_email,
        'jill.routh@equipmentshare.com' as out_email

    union all

    select
        'kim.hieger@equipmentshare.com' as in_email,
        'kim.rickermann@equipmentshare.com' as out_email

    union all

    select
        'john.bleyenberg@estrack.com' as in_email,
        'john.bleyenberg@equipmentshare.com' as out_email
),

transaction_email_correction as (
    -- The following transaction has Mike McLannahan's email instead of Joel Kurtz's
    select
        '330101-2103203791251892180000015003010330101' as transaction_id,
        'joel.kurtz@equipmentshare.com' as out_email
)

select
    act.transaction_id || '-' || act.transaction_reference_id as transaction_id,
    act.transaction_id as raw_transaction_id,
    act.transaction_reference_id,
    act.corporate_account_number,
    cca.corporate_account_name,
    act.cardmember_account_number,
    cd.employee_id,
    act.full_name,
    act.first_name,
    act.last_name,
    cd.employee_title,
    act.transaction_description,
    act.transaction_type,
    act.supplier_number,
    act.merchant_name,
    act.sic_number,
    act.sic,
    act.sic_division,
    act.mcc_code::text as mcc_code,
    act.mcc,
    act.mcc_group,
    act.transaction_date,
    act.postal_code,
    act.supplier_postal_code,
    coalesce(cd.work_email, act.email) as email,
    act.cardmember_status,
    coalesce(act.cardmember_status = 'ACTIVE ACCOUNT', false) as is_card_open,
    iff(act.cardmember_status = 'ACTIVE ACCOUNT', 'Open','Closed') as card_status_description,
    act.status,
    act.account_status,
            case
            when coalesce(act.cardmember_status = 'ACTIVE ACCOUNT', false)
                then
                    min(act.transaction_date) over (partition by cd.employee_id, act.corporate_account_number)
            else
                max(act.transaction_date)
                    over (partition by cd.employee_id, act.corporate_account_number)
        end as account_open_or_closed_date,
    act.transaction_amount,
    act.charge_amount,
    act.credit_amount,
    act.is_credit,
    act.card_type,
    act.is_bypass_verification
from amex_cc_transactions as act
    left join email_correction as ec
        on act.email = ec.in_email
    left join transaction_email_correction as tec
        on act.transaction_id || '-' || act.transaction_reference_id = tec.transaction_id
    left join company_directory as cd
        on coalesce(ec.out_email, tec.out_email, act.email) = cd.work_email
    left join corporate_card_accounts as cca
        on act.corporate_account_number::varchar = cca.corporate_account_number::varchar
