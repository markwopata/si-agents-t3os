view: corporate_wfp {
  sql_table_name: "LOOKER"."CORPORATE_WFP" ;;

  dimension: average_salary {
    type: number
    sql: ${TABLE}."AVERAGE_SALARY" ;;
  }
  dimension: compensation_through_prev_month {
    type: number
    sql: ${TABLE}."COMPENSATION_THROUGH_PREV_MONTH" ;;
  }
  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: employee_count {
    type: number
    sql: ${TABLE}."EMPLOYEE_COUNT" ;;
  }
  measure: count {
    type: count
  }
}
