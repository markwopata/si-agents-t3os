connection: "es_snowflake_analytics"

include: "/views/custom_sql/Balance_Sheet_Assets.view.lkml"

explore:  Balance_Sheet_Assets{
  case_sensitive: no
}
