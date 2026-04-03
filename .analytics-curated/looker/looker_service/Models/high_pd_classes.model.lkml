connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/high_pd_classes.view.lkml"

explore: high_pd_classes{
  case_sensitive: no
  label: "High PD Classes"
}
