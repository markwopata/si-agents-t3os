view: v_fact_application_history {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_FACT_APPLICATION_HISTORY" ;;

  dimension: application_history_application_applied {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_APPLICATION_APPLIED_DATE" ;;
  }
  dimension: application_history_application_key {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_APPLICATION_KEY" ;;
  }
  dimension: application_history_candidate_key {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_CANDIDATE_KEY" ;;
  }
  dimension: application_history {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_DATE" ;;
  }
  dimension: application_history_days_in_stage {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_DAYS_IN_STAGE" ;;
  }
  dimension: application_history_department_key {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_DEPARTMENT_KEY" ;;
  }
  dimension: application_history_is_current_stage {
    type: yesno
    sql: ${TABLE}."APPLICATION_HISTORY_IS_CURRENT_STAGE" ;;
  }
  dimension: application_history_job_closed {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_JOB_CLOSED_DATE" ;;
  }
  dimension: application_history_job_created {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_JOB_CREATED_DATE" ;;
  }
  dimension: application_history_key {
    type: string
    sql: ${TABLE}."APPLICATION_HISTORY_KEY" ;;
  }
  dimension: application_history_new_status {
    type: string
    sql: ${TABLE}."APPLICATION_HISTORY_NEW_STATUS" ;;
  }
  dimension: application_history_final_new_status {
    type: string
    sql: ${TABLE}."APPLICATION_HISTORY_FINAL_NEW_STATUS" ;;
  }
  dimension: application_history_offer_created {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_OFFER_CREATED_DATE" ;;
  }
  dimension: application_history_offer_key {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_OFFER_KEY" ;;
  }
  dimension: application_history_offer_resolved {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_OFFER_RESOLVED_DATE" ;;
  }
  dimension: application_history_offer_sent {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_OFFER_SENT_DATE" ;;
  }
  dimension: application_history_out_of_sequence {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_OUT_OF_SEQUENCE" ;;
  }
  dimension: application_history_prior_stage {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_PRIOR_STAGE_DATE" ;;
  }
  dimension: application_history_priority {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_PRIORITY" ;;
  }
  dimension: application_history_requistion_key {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_REQUISTION_KEY" ;;
  }
  dimension: application_history_stage_key {
    type: number
    sql: ${TABLE}."APPLICATION_HISTORY_STAGE_KEY" ;;
  }
  dimension: application_history_starts_at {
    type: date_raw
    sql: ${TABLE}."APPLICATION_HISTORY_STARTS_AT_DATE" ;;
  }

}
