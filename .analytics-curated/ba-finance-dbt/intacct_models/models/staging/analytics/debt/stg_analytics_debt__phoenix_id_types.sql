select
    pit.phoenix_id,
    pit.schedule,
    pit.lender,
    pit.sage_loan_id,
    pit.sage_lender_id,
    pit.financial_schedule_id,
    pit.financial_lender_id,
    pit.funded,
    pit.sage_account_number
from {{ source('analytics_debt', 'phoenix_id_types') }} as pit
