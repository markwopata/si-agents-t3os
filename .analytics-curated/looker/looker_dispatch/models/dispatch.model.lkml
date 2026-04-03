connection: "es_snowflake"

include: "/views/custom_sql/delivery_by_driver.view.lkml"
include: "/views/custom_sql/del_by_driver_filter.view.lkml"

explore: delivery_by_driver {
  group_label: "Dispatch"
  from: delivery_by_driver
  case_sensitive: no
  label: "Delivery by Driver"

  join: del_by_driver_filter {
  type: left_outer
  relationship: one_to_one
  sql_on: ${delivery_by_driver.delivery_id} = ${del_by_driver_filter.delivery_id} ;;
  }
 }
