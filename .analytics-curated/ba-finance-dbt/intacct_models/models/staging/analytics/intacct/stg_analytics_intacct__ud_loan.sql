select
    ul.id as pk_loan_id,
    ul.name as loan_id,
    ul.loan_name,
    ul.createdby as fk_created_by_user_id,
    ul.whencreated as date_created,
    ul.modifiedby as fk_updated_by_user_id,
    ul.whenmodified as date_updated,
    split_part(ul.loan_lendor_loan, '-', 2)::int as financial_schedule_id,
    split_part(ul.loan_lendor_loan, '-', 1) as sage_account_number,
    ul.loan_lendor_loan as loan_account_plus_schedule_id,
    ul.loan_annual_int_ / 100 as loan_annual_interest_rate,
    ul.loan_start_date,
    ul.loan_payment_sta as loan_payment_start_date,
    ul.loan_maturity_da as loan_maturity_date,
    ul.loan_term_months,
    round(ul.loan_payment_amo, 2) as loan_payment_amount,
    case replace(lower(trim(ul.loan_payment_fre)), ',', '')
        when 'm' then 'monthly'
        when 'montnly' then 'monthly'
        else replace(lower(trim(ul.loan_payment_fre)), ',', '')
    end as loan_payment_frequency,
    ul.loan_payment_day,
    round(ul.loan_original_am, 2) as loan_original_amount,
    round(ul.loan_due_at_matu, 2) as loan_amount_due_at_maturity,
    ul.loan_notes,
    ul.loan_status,
    ul.rvendor::int as fk_vendor_id,
    ul.ddsreadtime as dds_read_timestamp,
    ul._es_update_timestamp
from {{ source('analytics_intacct', 'ud_loan') }} as ul
