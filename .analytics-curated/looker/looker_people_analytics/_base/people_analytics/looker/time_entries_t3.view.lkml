view: time_entries_t3 {
  sql_table_name: "LOOKER"."TIME_ENTRIES_T3" ;;

  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension: default_location {
    type: string
    sql: ${TABLE}."DEFAULT_LOCATION" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension: end {
    type: date_raw
    sql: ${TABLE}."END_DATE" ;;
    hidden:  yes
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }
  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: overtime_hours {
    type: number
    sql: ${TABLE}."OVERTIME_HOURS" ;;
  }
  dimension: regular_hours {
    type: number
    sql: ${TABLE}."REGULAR_HOURS" ;;
  }
  dimension: start {
    type: date_raw
    sql: ${TABLE}."START_DATE" ;;
    hidden:  yes
  }
  dimension: time_entry_id {
    type: number
    sql: ${TABLE}."TIME_ENTRY_ID" ;;
  }
  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [last_name, first_name, direct_manager_name]
  }

  # any code below this line is new

}
