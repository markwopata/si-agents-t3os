with maturity_date as (
    select
        payment_schedule_id,
        max(date) as maturity_date
    from {{ ref('stg_analytics_debt__loan_amortization') }}
    group by payment_schedule_id
),

daily_payments as (
    select
        amort.payment_schedule_id,
        amort.date,
        round(sum(amort.positive_cash_flow_amount), 2) as positive_cash_flow_amount,
        round(sum(amort.negative_cash_flow_amount), 2) as negative_cash_flow_amount,
        round(sum(amort.positive_cash_flow_amount) - sum(amort.negative_cash_flow_amount), 2) as net_cash_flow_amount,
        round(sum(amort.interest_amount), 2) as interest_amount,
        round(sum(amort.principal_amount), 2) as principal_amount,
        md.maturity_date
    from {{ ref('stg_analytics_debt__loan_attributes') }} as att
        inner join {{ ref('stg_analytics_debt__loan_amortization') }} as amort
            on att.payment_schedule_id = amort.payment_schedule_id
        inner join maturity_date as md
            on amort.payment_schedule_id = md.payment_schedule_id
    where att.is_gaap = false
        and att.is_pending = false
        and att.record_stop_timestamp like '9999%'
        and md.maturity_date >= date_trunc('month', current_date)
    group by all
)

select
    dp.payment_schedule_id,
    dp.date,
    dp.positive_cash_flow_amount,
    dp.negative_cash_flow_amount,
    dp.net_cash_flow_amount,
    dp.interest_amount,
    dp.principal_amount,
    round(sum(dp.net_cash_flow_amount) over (partition by dp.payment_schedule_id order by dp.date), 2) as balance,
    dp.maturity_date,
    md5(concat(dp.payment_schedule_id, dp.date)) as pk_loan_debt_schedule_id
from daily_payments as dp
where dp.net_cash_flow_amount != 0
