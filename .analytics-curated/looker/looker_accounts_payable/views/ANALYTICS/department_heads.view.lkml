view: department_heads {
  sql_table_name: "CORPORATE_BUDGET"."DEPARTMENT_HEADS" ;;

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }
  dimension: active_status {
    type: yesno
    sql: ${TABLE}."ACTIVE_STATUS" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: end_date {
    type: string
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }
  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [last_name, first_name]
  }
}
