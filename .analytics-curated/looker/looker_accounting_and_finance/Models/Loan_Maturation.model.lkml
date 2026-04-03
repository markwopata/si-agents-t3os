connection: "es_snowflake_analytics"

include: "/views/custom_sql/loans_maturing_soon.view.lkml"


explore: loans_maturing_soon {
  case_sensitive: no
}
