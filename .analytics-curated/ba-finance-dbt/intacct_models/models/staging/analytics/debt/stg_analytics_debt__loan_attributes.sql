select
    la.pmt_schedule_id as payment_schedule_id,
    la.financial_schedule_id,
    la.version,
    la.gaap as is_gaap,
    la.entity as entity_code,
    la.financing_facility_type,
    la.nominal_rate / 100 as nominal_rate,
    la.apr / 100 as annual_percentage_rate,
    la.tval_folder,
    la.pending as is_pending,
    la.updated_by,
    la.approved_by,
    la.record_start_date as record_start_timestamp,
    la.record_stop_date as record_stop_timestamp
from {{ source('analytics_debt', 'loan_attributes') }} as la
