connection: "es_snowflake_analytics"

include: "/Dashboards/bulk_parts_inventory_information/*.view.lkml"

explore: bulk_inventory_information {
  case_sensitive: no
}
