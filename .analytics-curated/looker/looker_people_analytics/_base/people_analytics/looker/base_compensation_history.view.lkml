view: base_compensation_history {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."BASE_COMPENSATION_HISTORY" ;;


  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
    hidden: yes
  }

  dimension: increase {
    type: string
    sql: ${TABLE}."%_INCREASE" ;;
  }

  dimension: annual {
    type: string
    sql: ${TABLE}."ANNUAL" ;;
  }

  dimension: amount {
    type: string
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: amount_per {
    type: string
    sql: ${TABLE}."AMOUNT_PER" ;;
  }

  dimension: first_payroll {
    type: date_raw
    sql: ${TABLE}."DATE_FROM" ;;
    hidden: yes
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: reason_code {
    type: string
    sql: ${TABLE}."REASON_CODE" ;;
  }

  measure: count {
    type: count
    drill_fields: [first_name, last_name]
  }
}
