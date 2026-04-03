view: v_fact_interview_scorecard {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_FACT_INTERVIEW_SCORECARD" ;;

  dimension: application_applied {
    type: date_raw
    sql: ${TABLE}."APPLICATION_APPLIED_DATE" ;;
  }
  dimension: application_key {
    type: number
    sql: ${TABLE}."APPLICATION_KEY" ;;
  }
  dimension: candidate_key {
    type: number
    sql: ${TABLE}."CANDIDATE_KEY" ;;
  }
  dimension: department_key {
    type: number
    sql: ${TABLE}."DEPARTMENT_KEY" ;;
  }
  dimension: end_of_interview {
    type: date_raw
    sql: ${TABLE}."END_OF_INTERVIEW" ;;
  }
  dimension: interview_id {
    type: number
    sql: ${TABLE}."INTERVIEW_ID" ;;
  }
  dimension: interview_name {
    type: string
    sql: ${TABLE}."INTERVIEW_NAME" ;;
  }
  dimension: interview_scheduled_organizer_interviewer_key {
    type: string
    sql: ${TABLE}."INTERVIEW_SCHEDULED_ORGANIZER_INTERVIEWER_KEY" ;;
  }
  dimension: interviewer_id {
    type: number
    sql: ${TABLE}."INTERVIEWER_ID" ;;
  }
  dimension: interviewer_name {
    type: string
    sql: ${TABLE}."INTERVIEWER_NAME" ;;
  }
  dimension: interviewer_role {
    type: string
    sql: ${TABLE}."INTERVIEWER_ROLE" ;;
  }
  dimension: interview_status {
    type: string
    sql: ${TABLE}."INTERVIEW_STATUS" ;;
  }
  dimension: job_closed {
    type: date_raw
    sql: ${TABLE}."JOB_CLOSED_DATE" ;;
  }
  dimension: job_created {
    type: date_raw
    sql: ${TABLE}."JOB_CREATED_DATE" ;;
  }
  dimension: offer_created {
    type: date_raw
    sql: ${TABLE}."OFFER_CREATED_DATE" ;;
  }
  dimension: offer_key {
    type: number
    sql: ${TABLE}."OFFER_KEY" ;;
  }
  dimension: offer_resolved {
    type: date_raw
    sql: ${TABLE}."OFFER_RESOLVED_DATE" ;;
  }
  dimension: offer_sent {
    type: date_raw
    sql: ${TABLE}."OFFER_SENT_DATE" ;;
  }
  dimension: offer_starts_at {
    type: date_raw
    sql: ${TABLE}."OFFER_STARTS_AT_DATE" ;;
  }
  dimension: organizer_id {
    type: number
    sql: ${TABLE}."ORGANIZER_ID" ;;
  }
  dimension: organizer_name {
    type: string
    sql: ${TABLE}."ORGANIZER_NAME" ;;
  }
  dimension: organizer_role {
    type: string
    sql: ${TABLE}."ORGANIZER_ROLE" ;;
  }
  dimension: requisition_key {
    type: number
    sql: ${TABLE}."REQUISITION_KEY" ;;
  }
  dimension: scorecard_id {
    type: number
    sql: ${TABLE}."SCORECARD_ID" ;;
  }
  dimension: scorecard_recommendation {
    type: string
    sql: ${TABLE}."SCORECARD_RECOMMENDATION" ;;
  }
  dimension: stage_key {
    type: number
    sql: ${TABLE}."STAGE_KEY" ;;
  }
  dimension: start_of_interview {
    type: date_raw
    sql: ${TABLE}."START_OF_INTERVIEW" ;;
  }
  measure: count {
    type: count
    drill_fields: [interviewer_name, interview_name, organizer_name]
  }
}
