connection: "es_snowflake_analytics"

include: "/views/custom_sql/market_oec_v*.view.lkml"


explore: market_oec_v2 {
  group_label: "Market Operations Dashboard"
  label: "Market Oec Logic Comparison 2"
  case_sensitive: no
}
