view: work_order_user_times {
  sql_table_name: "WORK_ORDERS"."WORK_ORDER_USER_TIMES"
    ;;
  drill_fields: [work_order_user_time_id]

  dimension: work_order_user_time_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_USER_TIME_ID" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_deleted {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_DELETED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    # sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ)) ;;
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    # sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ)) ;;
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: updated_by_user_id {
    type: number
    sql: ${TABLE}."UPDATED_BY_USER_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [work_order_user_time_id]
  }

  dimension: total_time {
    type: number
    sql: datediff('seconds',${start_raw},${end_raw}) ;;
  }

  measure: total_time_in_hours {
    type: sum
    sql: coalesce(${total_time}/3600,0) ;;
    value_format_name: decimal_2
    html: {{rendered_value }} hrs. ;;
  }

  dimension: start_date_time {
    type: date_time
    sql: coalesce(${start_raw},current_timestamp) ;;
    html: {{ rendered_value | date: "%x %r" }} ;;
  }

  dimension: end_date_time {
    type: date_time
    sql: coalesce(${end_raw},current_timestamp) ;;
    html: {{ rendered_value | date: "%x %r" }} ;;
  }

  dimension: fake_string {
    type: yesno
    sql: ${work_orders.work_order_id} <> ${work_order_id} ;;
  }

}
