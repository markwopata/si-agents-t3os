select
    gtb.period_start_date,
    gtb.account_number,
    gtb.account_name,
    gtb.account_category,
    gtb.account_type,
    round(sum(gtb.beginning_balance), 2) as beginning_balance,
    round(sum(gtb.debit_amount), 2) as debit_amount,
    round(sum(gtb.credit_amount), 2) as credit_amount,
    round(sum(gtb.net_activity), 2) as net_activity,
    round(sum(gtb.ending_balance), 2) as ending_balance
from {{ ref('int_gl_trial_balance') }} as gtb
group by all
order by gtb.period_start_date, gtb.account_number
