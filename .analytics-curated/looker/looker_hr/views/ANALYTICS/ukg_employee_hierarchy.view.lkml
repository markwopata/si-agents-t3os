view: ukg_employee_hierarchy {
  sql_table_name: "ANALYTICS"."PAYROLL"."V_EMPLOYEE_HIERARCHY"
    ;;

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: employee_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_NAME" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: hierarchy_depth {
    type: number
    sql: ${TABLE}."HIERARCHY_DEPTH" ;;
  }

  dimension: manager_employee_id {
    type: string
    sql: ${TABLE}."MANAGER_EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: manager_list {
    type: string
    sql: ${TABLE}."MANAGER_LIST" ;;
  }

  dimension: num_reports_above {
    type: number
    sql: ${TABLE}."NUM_REPORTS_ABOVE" ;;
  }

  dimension: top_level_manager {
    type: string
    sql: ${TABLE}."TOP_LEVEL_MANAGER" ;;
  }

  measure: count {
    type: count
    drill_fields: [employee_name, direct_manager_name]
  }
}
