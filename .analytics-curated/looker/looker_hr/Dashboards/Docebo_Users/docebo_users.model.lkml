connection: "es_snowflake_analytics"


include: "/Dashboards/Docebo_Users/docebo_user_data.view.lkml"


explore: docebo_user_data {
  case_sensitive: no

}
