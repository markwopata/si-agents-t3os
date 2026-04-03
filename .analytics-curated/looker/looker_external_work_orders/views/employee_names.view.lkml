view: employee_names {
 derived_table: {
  sql: select distinct
              u.user_id
              , concat(u.first_name, ' ', u.last_name) as time_entry_user_name
            from
              work_orders.work_order_user_times wout
              join users u on u.user_id = wout.user_id
            where
              u.company_id = {{ _user_attributes['company_id'] }}::numeric

              --u.company_id = 50::numeric

            union
            select
              distinct
              u.user_id
              , concat(u.first_name, ' ', u.last_name) as time_entry_user_name
            from
              time_tracking.time_entries er
              join users u on u.user_id = er.user_id
            where
              u.company_id = {{ _user_attributes['company_id'] }}::numeric
              --u.company_id = 50::numeric
              and er.work_order_id is not null
              AND er.event_type_id = 1 --only pulling 'on duty' event types
              ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: user_id {
  type: number
  sql: ${TABLE}."USER_ID" ;;
}

dimension: time_entry_user_name {
  type: string
  sql: ${TABLE}."TIME_ENTRY_USER_NAME" ;;
}

  filter: employee_name_filter {
    type: string
  }

set: detail {
  fields: [
    user_id,
    time_entry_user_name
  ]
}
}
