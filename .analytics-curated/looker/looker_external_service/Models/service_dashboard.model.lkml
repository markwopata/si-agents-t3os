connection: "reportingc_warehouse"

include: "/views/service/*.view.lkml"
include: "/views/asset_status_key_values.view.lkml"


explore: work_order_tag_count {
  group_label: "Service"
  label: "Work Order Tag Count"
  case_sensitive: no
  # persist_for: "10 minutes"
}

explore: activity_feed {
  group_label: "Service"
  label: "Activity Feed"
  case_sensitive: no
  # persist_for: "10 minutes"
}

explore: overdue_work_order_inspections {
  group_label: "Service"
  label: "Overdue Work Order Inspections"
  case_sensitive: no
  # persist_for: "10 minutes"
}

explore: open_work_orders {
  group_label: "Service"
  label: "Open Work Order/Inspections"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: asset_status_key_values {
    type: left_outer
    relationship: one_to_many
    sql_on: ${asset_status_key_values.asset_id} = ${open_work_orders.asset_id}
      ;;
  }
}
