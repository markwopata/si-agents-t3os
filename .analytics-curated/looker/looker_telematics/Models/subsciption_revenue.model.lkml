connection: "es_snowflake_analytics"

include: "/views/custom_sql/subscription_revenue_detail.view.lkml"
include: "/views/custom_sql/subscription_revenue_summary.view.lkml"


explore: subscription_revenue_detail {
  case_sensitive: no
  #persist_for: "1 minute"
}

explore: subscription_revenue_summary {
  case_sensitive: no
  #persist_for: "1 minute"
}
