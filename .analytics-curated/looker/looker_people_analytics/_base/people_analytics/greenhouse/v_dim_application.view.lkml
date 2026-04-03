view: v_dim_application {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_DIM_APPLICATION" ;;

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }
  dimension: application_key {
    type: number
    sql: ${TABLE}."APPLICATION_KEY" ;;
  }
  dimension: application_location_address {
    type: string
    sql: ${TABLE}."APPLICATION_LOCATION_ADDRESS" ;;
  }
  dimension: application_prospect {
    type: string
    sql: ${TABLE}."APPLICATION_PROSPECT" ;;
  }
  dimension: application_rejection_reason {
    type: string
    sql: ${TABLE}."APPLICATION_REJECTION_REASON" ;;
  }
  dimension: application_rejection_reason_type_name {
    type: string
    sql: ${TABLE}."APPLICATION_REJECTION_REASON_TYPE_NAME" ;;
  }
  dimension: application_source_name {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE_NAME" ;;
  }
  dimension: application_status {
    type: string
    sql: ${TABLE}."APPLICATION_STATUS" ;;
  }
  dimension: application_candidate_key {
    type: number
    sql: ${TABLE}."APPLICATION_CANDIDATE_KEY" ;;
  }
  dimension: application_department_key {
    type: string
    sql: ${TABLE}."APPLICATION_DEPARTMENT_KEY";;
  }
  dimension: application_requisition_key {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_KEY";;
  }
  measure: count {
    type: count
    drill_fields: [application_source_name, application_rejection_reason_type_name]
  }
}
