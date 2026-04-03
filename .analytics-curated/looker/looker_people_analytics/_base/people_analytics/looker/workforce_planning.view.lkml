view: workforce_planning {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."WORKFORCE_PLANNING" ;;

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
  dimension: sub_department {
    primary_key: yes
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT" ;;
  }
  dimension: months_left {
    type: number
    sql: ${TABLE}."MONTHS_LEFT" ;;
  }
  measure: count {
    type: count
  }
}
