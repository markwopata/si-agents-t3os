with compensation as (
    select
        intacct_department_id,
        gl_code as account_number,
        hours_cost,
        date_trunc(month, pay_period_start) as compensation_month,
        pay_period_start,
        pay_period_end,
        payroll_name
    from {{ ref("stg_analytics_branch_earnings__live_compensation_summary") }}
    where
        {{
            live_branch_earnings_date_filter(
                date_field="pay_period_start", timezone_conversion=false
            )
        }} and hours_cost != 0
),

allocation_basis as (
    select
        c.intacct_department_id,
        a.department_id,
        c.account_number,
        c.hours_cost * a.allocation_pct as amount,
        c.compensation_month,
        'Payroll Estimate: ' || c.pay_period_start as description,
        a.market_id
    from compensation as c
        left join {{ ref("int_live_branch_earnings_market_allocation") }} as a
            on c.intacct_department_id::varchar = a.department_id
                and date_trunc('month', c.pay_period_start) = a.gl_date
),

output as (
    select
        market_id::varchar as market_id,
        account_number::varchar as account_number,
        'Live Payroll Wage Summary GL DATE | MARKET_ID | ACCOUNTNO' as transaction_number_format,
        compensation_month || '|' || market_id || '|' || account_number as transaction_number,
        description,
        compensation_month::date as gl_date,
        'Live Payroll Wage Summary MARKET_ID | ACCOUNTNO' as document_type,
        market_id || '|' || account_number as document_number,
        null as url_sage,
        null as url_concur,
        null as url_admin,
        null as url_t3,
        round(sum(amount * -1), 2) as amount,
        object_construct() as additional_data,
        'ANALYTICS.BRANCH_EARNINGS.LIVE_COMPENSATION_SUMMARY' as source,
        'Payroll Estimated - Live Wage Summary' as load_section,
        '{{ this.name }}' as source_model
    from allocation_basis
    group by 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 14, 15, 16, 17
)

select * from output
union all
select
    market_id,
    '7705' as account_number,
    transaction_number_format,
    transaction_number,
    description || 'payroll tax' as description,
    gl_date,
    document_type,
    document_number,
    url_sage,
    url_concur,
    url_admin,
    url_t3,
    amount * 0.08 as amount,
    additional_data,
    source,
    load_section,
    source_model
from output
