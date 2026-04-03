connection: "es_snowflake_c_analytics"

include: "./*.view.lkml"

explore: price_history {
  group_label: "ESQR History"
  label: "ESQR History"
  case_sensitive: no
}
