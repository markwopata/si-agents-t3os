view: corporate_wfp_goals {
  sql_table_name: "LOOKER"."CORPORATE_WFP_GOALS" ;;

  dimension: department {
    type: string
    sql: ${TABLE}."DEPARTMENT" ;;
  }
  dimension: goal_2025_base_payroll {
    type: number
    sql: ${TABLE}."GOAL_2025_BASE_PAYROLL" ;;
  }
  dimension: goal_2025_end_headcount {
    type: number
    sql: ${TABLE}."GOAL_2025_END_HEADCOUNT" ;;

  }

  dimension: goal_2025_total_payroll {
    type: number
    sql: ${TABLE}."GOAL_2025_TOTAL_PAYROLL" ;;

  }
  dimension: subdepartment {
    primary_key: yes
    type: string
    sql: ${TABLE}."SUBDEPARTMENT" ;;
  }
  measure: count {
    type: count
  }
}
