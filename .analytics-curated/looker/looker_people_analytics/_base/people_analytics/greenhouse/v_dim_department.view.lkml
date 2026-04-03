view: v_dim_department {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_DIM_DEPARTMENT" ;;

  dimension: department_full_path {
    type: string
    sql: ${TABLE}."DEPARTMENT_FULL_PATH" ;;
  }
  dimension: department_hierarchy_level {
    type: number
    sql: ${TABLE}."DEPARTMENT_HIERARCHY_LEVEL" ;;
  }
  dimension: department_id {
    type: number
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }
  dimension: department_key {
    type: number
    sql: ${TABLE}."DEPARTMENT_KEY" ;;
  }
  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }
  dimension: department_parent_id {
    type: number
    sql: ${TABLE}."DEPARTMENT_PARENT_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [department_name]
  }
}
