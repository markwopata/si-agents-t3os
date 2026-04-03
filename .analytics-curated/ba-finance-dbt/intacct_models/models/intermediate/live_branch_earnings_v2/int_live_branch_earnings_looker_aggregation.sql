with
live_branch_earnings as (
    select
        region,
        region_name,
        district,
        market_type,
        market_id,
        market_name,
        revenue_expense,
        segment,
        account_category_id,
        account_category,
        category_sort_order,
        account_number,
        account_name,
        gl_month,
        filter_month,
        is_payroll_expense,
        is_overtime_wage,
        is_paid_delivery_revenue,
        is_delivery_expense_account,
        is_commission_expense,
        market_greater_than_12_months,
        sum(original_equipment_cost) as original_equipment_cost,
        round(sum(amount), 2) as amount
    from {{ ref("int_live_branch_earnings_looker") }}
    where gl_month::date >= '{{ live_be_start_date() }}'
    group by all
),

live_branch_earnings_comparison as (
    select
        region,
        region_name,
        district,
        market_type,
        market_id,
        market_name,
        revenue_expense,
        segment,
        account_category_id,
        account_category,
        category_sort_order,
        account_number,
        account_name,
        dateadd(month, 1, gl_month) as gl_month,
        to_char(to_date(dateadd(month, 1, gl_month::date)), 'MMMM YYYY') as filter_month,
        is_payroll_expense,
        is_overtime_wage,
        is_paid_delivery_revenue,
        is_delivery_expense_account,
        is_commission_expense,
        round(sum(amount), 2) as amount
    from {{ ref("int_live_branch_earnings_looker") }}
    where gl_month::date >= dateadd(month, 1, '{{ last_branch_earnings_published_date() }}')
    group by all
),

static_branch_earnings as (
    select
        region,
        region_name,
        district,
        market_type,
        market_id,
        market_name,
        revenue_expense,
        segment,
        fk_account_category_id as account_category_id,
        account_category,
        category_sort_order,
        account_number,
        account_name,
        gl_month::date as gl_month,
        dateadd(month, 1, gl_month::date) as comparison_gl_month,
        to_char(to_date(dateadd(month, 1, gl_month::date)), 'MMMM YYYY') as comparison_filter_month,
        is_payroll_expense,
        is_overtime_wage,
        is_paid_delivery_revenue,
        is_delivery_expense_account,
        is_commission_expense,
        round(sum(amount), 2) as amount
    from {{ ref("int_live_branch_earnings_static_results") }}
    where gl_month::date >= dateadd(month, -1, '{{ live_be_start_date() }}')
        and gl_month::date < dateadd(month, 1, '{{ last_branch_earnings_published_date() }}')
    group by all
),

output as (
    select
        coalesce(
            live_branch_earnings.region,
            static_branch_earnings_previous_month.region,
            live_branch_earnings_comparison.region,
            live_branch_earnings_comparison.region
        ) as region,
        coalesce(
            live_branch_earnings.region_name,
            static_branch_earnings_previous_month.region_name,
            live_branch_earnings_comparison.region_name
        ) as region_name,
        coalesce(
            live_branch_earnings.district,
            static_branch_earnings_previous_month.district,
            live_branch_earnings_comparison.district
        ) as district,
        coalesce(
            live_branch_earnings.market_type,
            static_branch_earnings_previous_month.market_type,
            live_branch_earnings_comparison.market_type
        ) as market_type,
        coalesce(
            live_branch_earnings.market_id,
            static_branch_earnings_previous_month.market_id,
            live_branch_earnings_comparison.market_id
        ) as market_id,
        coalesce(
            live_branch_earnings.market_name,
            static_branch_earnings_previous_month.market_name,
            live_branch_earnings_comparison.market_name
        ) as market_name,
        coalesce(
            live_branch_earnings.revenue_expense,
            static_branch_earnings_previous_month.revenue_expense,
            live_branch_earnings_comparison.revenue_expense
        ) as revenue_expense,
        coalesce(
            live_branch_earnings.segment,
            static_branch_earnings_previous_month.segment,
            live_branch_earnings_comparison.segment
        ) as segment,
        coalesce(
            live_branch_earnings.account_category_id,
            static_branch_earnings_previous_month.account_category_id,
            live_branch_earnings_comparison.account_category_id
        ) as account_category_id,
        coalesce(
            live_branch_earnings.account_category,
            static_branch_earnings_previous_month.account_category,
            live_branch_earnings_comparison.account_category
        ) as account_category,
        coalesce(
            live_branch_earnings.category_sort_order,
            static_branch_earnings_previous_month.category_sort_order,
            live_branch_earnings_comparison.category_sort_order
        ) as category_sort_order,
        coalesce(
            live_branch_earnings.account_number,
            static_branch_earnings_previous_month.account_number,
            live_branch_earnings_comparison.account_number
        ) as account_number,
        coalesce(
            live_branch_earnings.account_name,
            static_branch_earnings_previous_month.account_name,
            live_branch_earnings_comparison.account_name
        ) as account_name,
        coalesce(
            live_branch_earnings.gl_month,
            static_branch_earnings_previous_month.comparison_gl_month,
            live_branch_earnings_comparison.gl_month
        ) as gl_month,
        coalesce(
            live_branch_earnings.filter_month,
            static_branch_earnings_previous_month.comparison_filter_month,
            live_branch_earnings_comparison.filter_month
        ) as filter_month,
        coalesce(
            live_branch_earnings.is_payroll_expense,
            static_branch_earnings_previous_month.is_payroll_expense,
            live_branch_earnings_comparison.is_payroll_expense
        ) as is_payroll_expense,
        coalesce(
            live_branch_earnings.is_overtime_wage,
            static_branch_earnings_previous_month.is_overtime_wage,
            live_branch_earnings_comparison.is_overtime_wage
        ) as is_overtime_wage,
        coalesce(
            live_branch_earnings.is_paid_delivery_revenue,
            static_branch_earnings_previous_month.is_paid_delivery_revenue,
            live_branch_earnings_comparison.is_paid_delivery_revenue
        ) as is_paid_delivery_revenue,
        coalesce(
            live_branch_earnings.is_delivery_expense_account,
            static_branch_earnings_previous_month.is_delivery_expense_account,
            live_branch_earnings_comparison.is_delivery_expense_account
        ) as is_delivery_expense_account,
        coalesce(
            live_branch_earnings.is_commission_expense,
            static_branch_earnings_previous_month.is_commission_expense,
            live_branch_earnings_comparison.is_commission_expense
        ) as is_commission_expense,
        live_branch_earnings.original_equipment_cost,
        coalesce(live_branch_earnings.amount, 0) as amount,
        coalesce(static_branch_earnings_previous_month.amount, live_branch_earnings_comparison.amount)
            as previous_month_amount,
        coalesce(static_branch_earnings_same_month.amount, 0) as static_same_month_amount,
        coalesce(
            live_branch_earnings.gl_month,
            static_branch_earnings_previous_month.comparison_gl_month,
            live_branch_earnings_comparison.gl_month
        )
        <= '{{ last_branch_earnings_published_date() }}' as admin_only_data,
        live_branch_earnings.market_greater_than_12_months,
        current_timestamp() as _es_update_timestamp
    from live_branch_earnings
        full outer join
            static_branch_earnings as static_branch_earnings_previous_month
            on live_branch_earnings.market_id = static_branch_earnings_previous_month.market_id
                and live_branch_earnings.gl_month = static_branch_earnings_previous_month.comparison_gl_month
                and live_branch_earnings.account_number = static_branch_earnings_previous_month.account_number
        full outer join
            static_branch_earnings as static_branch_earnings_same_month
            on live_branch_earnings.market_id = static_branch_earnings_same_month.market_id
                and live_branch_earnings.gl_month = static_branch_earnings_same_month.gl_month
                and live_branch_earnings.account_number = static_branch_earnings_same_month.account_number
        full outer join
            live_branch_earnings_comparison
            on live_branch_earnings.market_id = live_branch_earnings_comparison.market_id
                and live_branch_earnings.gl_month = live_branch_earnings_comparison.gl_month
                and live_branch_earnings.account_number = live_branch_earnings_comparison.account_number
)

select *
from output
where gl_month::date >= '{{ live_be_start_date() }}'
    and gl_month::date <= '{{ live_be_end_date() }}'
