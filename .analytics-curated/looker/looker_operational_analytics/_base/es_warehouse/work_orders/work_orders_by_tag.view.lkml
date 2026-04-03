view: work_orders_by_tag {
  sql_table_name: "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS_BY_TAG" ;;
#note this table does not account for tags removed, it includes all tags that have ever been on the work order.
  dimension: company_tag_id {
    type: number
    sql: ${TABLE}."COMPANY_TAG_ID" ;;
    value_format_name: id
  }
  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
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
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension_group: user_assignment_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."USER_ASSIGNMENT_END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: user_assignment_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."USER_ASSIGNMENT_START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
    value_format_name: id
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format_name: id
  }
  measure: count {
    type: count
    drill_fields: [first_name, last_name, name]
  }
}
