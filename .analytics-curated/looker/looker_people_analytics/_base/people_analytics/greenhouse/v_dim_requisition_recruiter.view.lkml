view: v_dim_requisition_recruiter {
  sql_table_name: "GREENHOUSE"."V_DIM_REQUISITION_RECRUITER" ;;

  dimension: requisition_custom_builders_org {
    type: yesno
    sql: ${TABLE}."REQUISITION_CUSTOM_BUILDERS_ORG" ;;
  }
  dimension: requisition_custom_hire_type {
    type: string
    sql: ${TABLE}."REQUISITION_CUSTOM_HIRE_TYPE" ;;
  }
  dimension: requisition_custom_job_type {
    type: string
    sql: ${TABLE}."REQUISITION_CUSTOM_JOB_TYPE" ;;
  }
  dimension: requisition_custom_market_type {
    type: string
    sql: ${TABLE}."REQUISITION_CUSTOM_MARKET_TYPE" ;;
  }
  dimension: requisition_custom_type {
    type: string
    sql: ${TABLE}."REQUISITION_CUSTOM_TYPE" ;;
  }
  dimension: requisition_id {
    type: string
    sql: ${TABLE}."REQUISITION_ID" ;;
  }
  dimension: requisition_key {
    type: number
    sql: ${TABLE}."REQUISITION_KEY" ;;
  }
  dimension: requisition_name {
    type: string
    sql: ${TABLE}."REQUISITION_NAME" ;;
  }
  dimension: requisition_number_id {
    type: number
    sql: ${TABLE}."REQUISITION_NUMBER_ID" ;;
  }
  dimension: requisition_recruiter_employee_id {
    type: string
    sql: ${TABLE}."REQUISITION_RECRUITER_EMPLOYEE_ID" ;;
  }
  dimension: requisition_recruiter_full_name {
    type: string
    sql: ${TABLE}."REQUISITION_RECRUITER_FULL_NAME" ;;
  }
  dimension: requisition_status {
    type: string
    sql: ${TABLE}."REQUISITION_STATUS" ;;
  }
  measure: count {
    type: count
    drill_fields: [requisition_recruiter_full_name, requisition_name]
  }
}
