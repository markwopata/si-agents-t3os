connection: "es_snowflake_analytics"

include: "/market_operations/*.view.lkml"


explore: last_90_day_asset_statuses {
  group_label: "Market Operations Dashboard"
  label: "Asset Statuses In The Last 90 Days"
  case_sensitive: no
}

explore: last_6_12_month_asset_statuses {
  group_label: "Market Operations Dashboard"
  label: "Asset Statuses In The Last 6 & 12 Months"
  case_sensitive: no
}
