select
    gtb.pk_gl_trial_balance_id,
    gtb.period_start_date,
    gtb.entity_id,
    gtb.entity_name,
    gtb.department_id,
    gtb.department_name,
    gtb.account_number,
    gtb.account_name,
    gtb.account_category,
    gtb.account_type,
    gtb.beginning_balance,
    gtb.debit_amount,
    gtb.credit_amount,
    gtb.net_activity,
    gtb.ending_balance
from {{ ref('int_gl_trial_balance') }} as gtb
where gtb.period_start_date >= '2020-12-01'
