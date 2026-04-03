with employee_worker_comp_claims_detail as (
    select
        claim_number,
        market_id,
        employee_id,
        employee_name,
        date_of_injury::date as date_of_injury,
    from {{ ref('stg_analytics_claims__employee_worker_comp_claims_detail') }}
),

worker_comp_claims as (
    select
        claim_number,
        ncci_codes,
        indemnity_paid,
        medical_paid,
        expense_paid,
        total_paid,
        indemnity_outstanding,
        medical_outstanding,
        expense_outstanding,
        total_outstanding,
        indemnity_incurred,
        medical_incurred,
    expense_incurred,
        total_incurred,
        line_of_business,
        claim_status,
        accident_state,
        claim_description,
        accident_description,
        injured_body_part,
        injury_severity_description,
        litigation_status,
        wc_claim_type,
        closed_date::date as closed_date,
        released_to_work_date::date as released_to_work_date
    from {{ ref('stg_analytics_claims__worker_comp_claims') }}
)

select
    wcd.date_of_injury,
    wcd.market_id,
    wcd.employee_id,
    wcd.employee_name,
    wcc.*
from employee_worker_comp_claims_detail as wcd
    left join worker_comp_claims as wcc
        on upper(replace(replace(wcd.claim_number, ' ', ''), '-', ''))
            = upper(replace(replace(wcc.claim_number, ' ', ''), '-', ''))
            