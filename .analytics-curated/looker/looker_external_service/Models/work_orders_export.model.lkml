connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: work_orders {
  group_label: "Service"
  label: "Work Orders Export"
  sql_always_where: ${archived_date} is null ;;
  case_sensitive: no
  persist_for: "2 minutes"

  join: work_order_notes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_notes.work_order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_notes.creator_user_id} = ${users.user_id} ;;
  }

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: work_order_statuses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_statuses.work_order_status_id} = ${work_orders.work_order_status_id} ;;
  }

  join: urgency_levels {
    type: left_outer
    relationship: many_to_one
    sql_on: ${urgency_levels.urgency_level_id} = ${work_orders.urgency_level_id} ;;
  }

  join: users_creator_id {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.creator_user_id} = ${users_creator_id.user_id} ;;
  }

  join: work_order_user_times {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_times.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: work_orders_assigned_to {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders_assigned_to.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: time_tracking_entries {
    type: left_outer
    relationship: many_to_one
    sql_on: ${time_tracking_entries.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: users_mechanic {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${time_tracking_entries.user_id} = ${users.user_id} ;;
  }

  join: work_order_files {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_files.work_order_id} ;;
  }

}

explore: work_orders_time_tracking {
  from: work_orders
  group_label: "Service"
  label: "Work Orders Time Tracking"
  sql_always_where: ${archived_date} is null ;;
  case_sensitive: no
  persist_for: "2 minutes"

  join: time_tracking_entries {
    type: inner
    relationship: many_to_one
    sql_on: ${time_tracking_entries.work_order_id} = ${work_orders_time_tracking.work_order_id} ;;
  }

  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${time_tracking_entries.user_id} = ${users.user_id} ;;
  }
}


explore: work_order_updates {
  from: work_orders
  group_label: "Service"
  label: "Work Order Updates With Pictures"
  sql_always_where: ${archived_date} is null ;;
  case_sensitive: no
  persist_for: "2 minutes"

  join: work_order_updates_with_pictures {
    type: inner
    relationship: many_to_one
    sql_on: ${work_order_updates_with_pictures.work_order_id} = ${work_order_updates.work_order_id} ;;
  }
}

explore: work_order_tasks {
  from: work_orders
  group_label: "Service"
  label: "Work Order Task List"
  sql_always_where: ${archived_date} is null ;;
  case_sensitive: no
  persist_for: "2 minutes"

  join: work_order_task_list {
    type: inner
    relationship: one_to_many
    sql_on: ${work_order_tasks.work_order_id} = ${work_order_task_list.work_order_id} ;;
  }
}
