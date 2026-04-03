SELECT
    am.accountno,
    am.title,
    am.accounttype,
    am.category,
    am.internal_is_grouping,
    am.cost_revenue,
    am.statement_group,
    am.amortization_flag,
    am.capitalization_cost_flag,
    am.new_market_startup_eligible_flag,
    am.rent_expense_flag,
    am.comment,
    am.last_comment,
    am.non_recurring_flag,
    am.normalbalance
FROM {{ source('analytics_revmodel', 'account_mapping3') }} as am
