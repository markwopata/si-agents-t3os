view: intaact_code_by_ee {
  sql_table_name: "ANALYTICS"."PAYROLL"."INTAACT_CODE_BY_EE"
    ;;

  dimension: default_cost_centers_intaact {
    type: number
    sql: ${TABLE}."DEFAULT_COST_CENTERS_INTAACT" ;;
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

  measure: count {
    type: count
    drill_fields: [last_name, first_name]
  }
}
