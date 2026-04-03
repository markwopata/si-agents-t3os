select
    lat.financial_schedule_id,
    lat.financing_facility_type,
    fl.name as debt_table_lender_name,
    v.vendor_name as sage_lender_name,
    min(lam.date) as commencement_date,
    ul.sage_account_number,
    ul.loan_name as sage_loan_name,
    fs.current_schedule_number as debt_table_loan_name,
    v.vendor_id as sage_lender_vendor_id,
    fs.current_schedule_number as schedule_number
from {{ ref("stg_analytics_debt__loan_attributes") }} as lat
    left join {{ ref("stg_analytics_debt__loan_amortization") }} as lam
        on lat.payment_schedule_id = lam.payment_schedule_id
            and lam.event in ('Loan', 'Lease')
    left join {{ ref("stg_es_warehouse_public__financial_schedules") }} as fs
        on lat.financial_schedule_id = fs.financial_schedule_id
    left join {{ ref("stg_es_warehouse_public__financial_lenders") }} as fl
        on fs.originating_lender_id = fl.financial_lender_id
    left join {{ ref("stg_analytics_intacct__ud_loan") }} as ul
        on lat.financial_schedule_id = ul.financial_schedule_id
    left join {{ ref("stg_analytics_intacct__vendor") }} as v
        on ul.fk_vendor_id = v.pk_vendor_id
where not lat.is_pending
    and not lat.is_gaap
    and lat.record_stop_timestamp like '9999%'
group by all
