view: work_order_user_assignments {
  sql_table_name: "WORK_ORDERS"."WORK_ORDER_USER_ASSIGNMENTS" ;;
  drill_fields: [work_order_user_assignment_id]

  dimension: work_order_user_assignment_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."WORK_ORDER_USER_ASSIGNMENT_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  dimension: work_order_id_current {
    type: number
    sql: iff(${end_date} is null, ${TABLE}."WORK_ORDER_ID", null) ;;
  }
  dimension: work_order_user_assignment_type_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_USER_ASSIGNMENT_TYPE_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [work_order_user_assignment_id]
  }
}
