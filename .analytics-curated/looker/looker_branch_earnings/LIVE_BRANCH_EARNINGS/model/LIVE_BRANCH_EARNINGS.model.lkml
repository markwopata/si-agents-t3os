connection: "es_snowflake_c_analytics"

include: "/LIVE_BRANCH_EARNINGS/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/suggestions.lkml"


explore: live_branch_earnings_v2_aggregation {
  from: int_live_branch_earnings_looker_aggregation
  label: "Live Branch Earnings Model V2 Aggregated"
  description: "Live Branch Earnings Model V2 Aggregated"
  sql_always_where: {{ _user_attributes['department'] }} in ('developer','admin')
    or (${District_Region_Market_Access} and ${admin_only_data} = False)
    ;;
}

explore: live_branch_earnings_v2 {
  from: int_live_branch_earnings_looker
  label: "Live Branch Earnings Model V2"
  description: "Live Branch Earnings Model V2"
  sql_always_where: {{ _user_attributes['department'] }} in ('developer','admin')
  or (${District_Region_Market_Access} and ${admin_only_data} = False)
  ;;
}

explore: live_branch_earnings_revenue_estimate {
  from: int_live_branch_earnings_revenue_estimate
  label: "Live Branch Earnings Revenue Estimator"
  description: "Live Branch Earnings Revenue Estimator"
  }

explore: unassigned_tech_hours {
  label: "Unassigned Tech Hours"
  description: "Unassigned Tech Hours"
}

explore: non_es_wages {
  label: "Non-ES Wages"
  description: "Non-ES Wages"
}

explore: retail_sales_margin_live_be {
  label: "Live Branch Earnings - Dealership Sales Margin"
  description: "Live trending of Dealership Sales Margin."
  sql_always_where: {{ _user_attributes['department'] }} in ('developer','admin')
  or (${District_Region_Market_Access} and ${admin_only_data} = False)
  ;;
}
