
connection: "es_snowflake_analytics"


########### custom_sql ###########

include: "/views/custom_sql/parts_master.view.lkml"

explore: parts_master_vw {
  case_sensitive: no
}
