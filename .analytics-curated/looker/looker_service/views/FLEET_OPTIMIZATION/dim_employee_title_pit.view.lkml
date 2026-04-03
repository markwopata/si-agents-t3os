view: dim_employee_title_pit {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_EMPLOYEE_TITLE_PIT" ;;

  dimension: directory_pit_key {
    type: string
    sql: ${TABLE}."DIRECTORY_PIT_KEY" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension_group: employee_title_pit_last_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."EMPLOYEE_TITLE_PIT_LAST_UPDATED" ;;
  }
  dimension: employee_user_key {
    type: string
    sql: ${TABLE}."EMPLOYEE_USER_KEY" ;;
  }
  dimension: is_current_title {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_TITLE" ;;
  }
  dimension: is_warranty_team {
    type: yesno
    sql: ${TABLE}."IS_WARRANTY_TEAM" ;;
  }
  dimension_group: title_end_window {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."TITLE_END_WINDOW" ;;
  }
  dimension_group: title_start_window {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."TITLE_START_WINDOW" ;;
  }
  measure: count {
    type: count
  }
}
