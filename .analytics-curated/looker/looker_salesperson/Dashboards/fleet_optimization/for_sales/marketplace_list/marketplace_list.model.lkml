connection: "es_snowflake_analytics"

include: "./*.view.lkml"

explore: marketplace_list {
  group_label: "Fleet"
  label: "Marketplace List"
  case_sensitive: no
  }
