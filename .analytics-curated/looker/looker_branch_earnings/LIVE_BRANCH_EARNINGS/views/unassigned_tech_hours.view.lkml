view: unassigned_tech_hours {
  sql_table_name: analytics.branch_earnings.unassigned_tech_hours ;;
  drill_fields: [pk_unassigned_tech_hours_id]

  dimension: pk_unassigned_tech_hours_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_UNASSIGNED_TECH_HOURS_ID" ;;
  }
  dimension: assigned_hours {
    type: number
    sql: ${TABLE}."ASSIGNED_HOURS" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: filter_month {
    type: string
    sql:${TABLE}."FILTER_MONTH" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_greater_than_12_months {
    type: yesno
    sql:${TABLE}."MARKET_GREATER_THAN_12_MONTHS" ;;
  }
  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }
  dimension: work_codes {
    type: string
    sql: ${TABLE}."WORK_CODES" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  dimension: work_order_type {
    type: string
    sql: ${TABLE}."WORK_ORDER_TYPE" ;;
  }
  measure: total_hours {
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."TOTAL_HOURS" ;;
  }
  measure: unassigned_hours {
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."UNASSIGNED_HOURS" ;;
    drill_fields: [employee_name, employee_title, unassigned_hours, assigned_hours, total_hours]
  }
  measure: percent_unassigned {
    type: number
    value_format: "#,##0.0%;-#,##0.0%;-"
    sql: ${unassigned_hours}/nullifzero(${total_hours}) ;;
    drill_fields: [market_name,unassigned_hours]
  }
  measure: count {
    type: count
    drill_fields: [pk_unassigned_tech_hours_id, employee_name, market_name]
  }
}
