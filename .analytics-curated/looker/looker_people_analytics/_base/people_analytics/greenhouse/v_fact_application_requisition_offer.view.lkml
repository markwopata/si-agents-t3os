view: v_fact_application_requisition_offer {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_FACT_APPLICATION_REQUISITION_OFFER" ;;

  dimension: application_requisition_offer_application_applied {
    type: date_raw
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_APPLICATION_APPLIED_DATE" ;;
  }
  dimension: application_requisition_offer_application_key {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_APPLICATION_KEY" ;;
  }
  dimension: application_requisition_offer_candidate_key {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_CANDIDATE_KEY" ;;
  }
  dimension: application_requisition_offer_days_to_fill {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_DAYS_TO_FILL" ;;
  }
  dimension: application_requisition_offer_days_to_start {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_DAYS_TO_START" ;;
  }
  dimension: application_requisition_offer_offer_sent_to_start {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_DAYS_OFFER_SENT_TO_START" ;;
  }
  dimension: application_requisition_offer_days_to_hire {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_DAYS_TO_HIRE" ;;
  }
  dimension: application_requisition_offer_days_requisition_open {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_DAYS_REQUISITION_OPEN" ;;
  }
  dimension: application_requisition_offer_department_key {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_DEPARTMENT_KEY" ;;
  }
  dimension: application_requisition_offer_job_closed {
    type: date_raw
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_JOB_CLOSED_DATE" ;;
  }
  dimension: application_requisition_offer_job_created {
    type: date_raw
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_JOB_CREATED_DATE" ;;
  }
  dimension: application_requisition_offer_key {
    type: string
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_KEY" ;;
  }
  dimension: application_requisition_offer_offer_created {
    type: date_raw
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_OFFER_CREATED_DATE" ;;
  }
  dimension: application_requisition_offer_offer_key {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_OFFER_KEY" ;;
  }
  dimension: application_requisition_offer_offer_resolved {
    type: date_raw
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_OFFER_RESOLVED_DATE" ;;
  }
  dimension: application_requisition_offer_offer_sent {
    type: date_raw
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_OFFER_SENT_DATE" ;;
  }
  dimension: application_requisition_offer_offer_start {
    type: date_raw
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_OFFER_START_DATE" ;;
  }
  dimension: application_requisition_offer_requisition_key {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_REQUISITION_KEY" ;;
  }
  dimension: application_requisition_offer_stage_key {
    type: number
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_STAGE_KEY" ;;
  }
  dimension: application_requisition_offer_job_posting {
    type: date_raw
    sql: ${TABLE}."APPLICATION_REQUISITION_OFFER_JOB_POSTING_DATE" ;;
  }
  measure: count {
    type: count
  }

}
