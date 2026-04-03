select
    la.pmt_schedule_id as payment_schedule_id,
    la.event,
    la.date,
    la.positivecf as positive_cash_flow_amount,
    la.negativecf as negative_cash_flow_amount,
    la.interest as interest_amount,
    la.principal as principal_amount,
    la.balance,
    la.memo
from {{ source('analytics_debt', 'loan_amortization') }} as la
