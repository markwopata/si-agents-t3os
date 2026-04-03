select
    account_mapping.pk_account_mapping_id,
    account_mapping.account_number,
    coalesce(account_mapping.override_account_name, gl_account.account_name) as account_name,
    account_mapping.fk_account_category_id,
    catagories.account_category,
    catagories.sort_order as category_sort_order,
    account_mapping.fk_segment_id,
    segments.segment,
    account_mapping.revenue_expense,
    account_mapping.is_branch_earnings_account,
    account_mapping.is_overtime_wage,
    account_mapping.is_payroll_expense,
    account_mapping.is_paid_delivery_revenue,
    account_mapping.is_delivery_expense_account,
    account_mapping.is_commission_expense
from {{ ref('stg_analytics_branch_earnings__account_mapping') }} as account_mapping
    left join
        {{ ref('stg_analytics_intacct__gl_account') }} as gl_account
        on account_mapping.account_number = gl_account.account_number
    left join
        {{ ref('stg_analytics_branch_earnings__segments') }} as segments
        on account_mapping.fk_segment_id = segments.pk_segment_id
    left join
        {{ ref('stg_analytics_branch_earnings__account_categories') }} as catagories
        on account_mapping.fk_account_category_id = catagories.pk_account_category_id
where account_mapping.is_branch_earnings_account
