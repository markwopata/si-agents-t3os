select
    concat(be.market_id, '-', be.gl_month) as pk_id,
    be.market_id,
    be.gl_month as gl_date,
    round(sum(case when be.account_number in ('FAAA', 'TAIR', '5000') then be.amount end), 2) as rental_revenue,
    round(sum(case when be.is_paid_delivery_revenue then be.amount end), 2) as delivery_revenue,
    round(sum(case when be.account_number = '5009' then be.amount end), 2) as nonintercompany_delivery_revenue,
    round(sum(case when be.is_delivery_expense_account then be.amount end), 2) as delivery_expense,
    round(sum(case when be.account_number in ('FBAA', 'FCAA', 'FCBA', 'FCCA', 'FDJJ') then be.amount end), 2)
        as sales_revenue,
    round(
        sum(case when be.account_number in ('GBAA', 'GCAA', 'GCBA', 'GCCA', '6101', '6047', 'GCJJ') then be.amount end),
        2
    ) as sales_expense,
    round(sum(case when be.revenue_expense = 'revenue' then be.amount end), 2) as total_revenue,
    round(sum(case when be.is_payroll_expense then be.amount end), 2) as payroll_compensation_expense,
    round(sum(case when be.is_payroll_expense and not be.is_commission_expense then be.amount end), 2)
        as payroll_wage_expense,
    round(sum(case when be.is_overtime_wage then be.amount end), 2) as payroll_overtime_expense,
    round(sum(case when be.account_number in ('6014', '6031') then be.amount end), 2) as outside_hauling_expense,
    round(sum(be.amount), 2) as net_income
from {{ ref('int_live_branch_earnings_looker_aggregation') }} as be
    inner join {{ ref('market') }} as m
        on be.market_id = m.child_market_id
where be.segment != 'Intercompany'
    and be.gl_month > '{{ last_branch_earnings_published_date() }}'
group by all
