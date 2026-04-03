connection: "es_snowflake_analytics"

include: "/views/TIME_TRACKING/time_entries.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"

explore: work_orders {
  label: "Audit Work Order Time Entries"
join: time_entries {
  type: left_outer
  relationship: one_to_many
  sql_on: ${work_orders.work_order_id} = ${time_entries.work_order_id};;
}
join: users {
  type: inner
  relationship: many_to_one
  sql_on: ${time_entries.user_id}=${users.user_id} and ${users.company_id}=1854 ;;
}
}
