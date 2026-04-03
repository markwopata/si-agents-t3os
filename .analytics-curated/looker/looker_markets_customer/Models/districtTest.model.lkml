connection: "es_snowflake_c_analytics"

include: "/views/ANALYTICS/first_day_breakdowns_by_market_30_days_table.view.lkml"

explore: first_day_breakdowns_by_market_30_days_table {
  label: "First Day Breakdowns - Test"
  case_sensitive: no
  description: "Testing user district filter"
  persist_for: "8 hours"

}
