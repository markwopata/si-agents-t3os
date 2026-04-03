view: v_bridge_dim_requisition_dim_employee {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_BRIDGE_DIM_REQUISITION_DIM_EMPLOYEE" ;;

  dimension: bridge_dim_requisition_dim_employee_employee_key {
    type: number
    sql: ${TABLE}."BRIDGE_DIM_REQUISITION_DIM_EMPLOYEE_EMPLOYEE_KEY" ;;
  }
  dimension: bridge_dim_requisition_dim_employee_id_full_path {
    type: string
    sql: ${TABLE}."BRIDGE_DIM_REQUISITION_DIM_EMPLOYEE_ID_FULL_PATH" ;;
  }
  dimension: bridge_dim_requisition_dim_employee_key {
    type: string
    sql: ${TABLE}."BRIDGE_DIM_REQUISITION_DIM_EMPLOYEE_KEY" ;;
  }
  dimension: bridge_dim_requisition_dim_employee_name_full_path {
    type: string
    sql: ${TABLE}."BRIDGE_DIM_REQUISITION_DIM_EMPLOYEE_NAME_FULL_PATH" ;;
  }
  dimension: bridge_dim_requisition_dim_employee_requisition_key {
    type: number
    sql: ${TABLE}."BRIDGE_DIM_REQUISITION_DIM_EMPLOYEE_REQUISITION_KEY" ;;
  }
  dimension: bridge_dim_requisition_dim_employee_responsible {
    type: yesno
    sql: ${TABLE}."BRIDGE_DIM_REQUISITION_DIM_EMPLOYEE_RESPONSIBLE" ;;
  }
  dimension: bridge_dim_requisition_dim_employee_role {
    type: string
    sql: ${TABLE}."BRIDGE_DIM_REQUISITION_DIM_EMPLOYEE_ROLE" ;;
  }
  measure: count {
    type: count
  }
}
