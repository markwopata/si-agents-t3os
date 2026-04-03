view: time_tracking_entries {
  derived_table: {
    sql: select
          te.entry_id::text as entry_id,
          wo.work_order_id,
          te.start_date,
          te.end_date,
          u.user_id,
          concat(u.first_name,' ',u.last_name) as mechanic
      from
          work_orders.work_orders wo
          inner join time_tracking.time_tracking_entries te on wo.work_order_id = te.work_order_id
          left join users u on u.user_id = te.user_id
      where
          {% condition work_order_filter %} wo.work_order_id {% endcondition %}
      union
      select
          te.time_entry_id::text as entry_id,
          wo.work_order_id,
          te.start_date,
          te.end_date,
          u.user_id,
          concat(u.first_name,' ',u.last_name) as mechanic
      from
          work_orders.work_orders wo
          inner join time_tracking.time_entries te on wo.work_order_id = te.work_order_id
          left join users u on u.user_id = te.user_id
      where
          {% condition work_order_filter %} wo.work_order_id {% endcondition %}
      union
      select
          te.work_order_user_time_id::text as entry_id,
          wo.work_order_id,
          te.start_date,
          te.end_date,
          u.user_id,
          concat(u.first_name,' ',u.last_name) as mechanic
      from
          work_orders.work_orders wo
          inner join work_orders.work_order_user_times te on wo.work_order_id = te.work_order_id
          left join users u on u.user_id = te.user_id
      where
          {% condition work_order_filter %} wo.work_order_id {% endcondition %}
       ;;
  }

  dimension: entry_id {
    type: string
    sql: ${TABLE}."ENTRY_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension_group: start_date {
    type: time
    sql: CONVERT_TIMEZONE('America/Chicago',CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ)) ;;
  }

  dimension_group: end_date {
    type: time
    sql: CONVERT_TIMEZONE('America/Chicago',CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ)) ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: mechanic {
    type: string
    sql: ${TABLE}."MECHANIC" ;;
  }

  dimension: primary_key {
    primary_key: yes
    type: string
    sql: concat(${entry_id},${work_order_id},${mechanic},${start_date_raw}) ;;
  }

  dimension: total_time {
    type: number
    sql: datediff('seconds',${start_date_raw},${end_date_raw}) ;;
  }

  measure: total_time_in_hours {
    type: sum
    sql: coalesce(coalesce(${total_time},0)/3600,0) ;;
    value_format_name: decimal_2
    html: {{rendered_value }} hrs. ;;
  }

  dimension: start_date_time_formatted {
    type: date_time
    sql: coalesce(${start_date_raw},current_timestamp) ;;
    html: {{ rendered_value | date: "%x %r"  }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  dimension: end_date_time_formatted {
    type: date_time
    sql: coalesce(${end_date_raw},current_timestamp) ;;
    html: {{ rendered_value | date: "%x %r" }} {{ _user_attributes['user_timezone_label'] }} ;;
  }

  filter: work_order_filter {
    default_value: "870300"
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
