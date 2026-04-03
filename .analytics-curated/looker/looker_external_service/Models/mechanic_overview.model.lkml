connection: "reportingc_warehouse"

include: "/views/mechanic_overview/*.view.lkml"


explore: mechanic_open_work_orders_info {
  group_label: "Mechanic"
  label: "Mechanic Work Order Info"
  case_sensitive: no
  # persist_for: "10 minutes"
}

explore: mechanic_work_order_assignment_count {
  group_label: "Mechanic"
  label: "Mechanic Assignments"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: mechanic_open_work_orders_info {
    type: left_outer
    relationship: many_to_one
    sql_on: ${mechanic_work_order_assignment_count.work_order_id} = ${mechanic_open_work_orders_info.work_order_id}
            and ${mechanic_work_order_assignment_count.user_id} = ${mechanic_open_work_orders_info.user_id} ;;
  }
}
