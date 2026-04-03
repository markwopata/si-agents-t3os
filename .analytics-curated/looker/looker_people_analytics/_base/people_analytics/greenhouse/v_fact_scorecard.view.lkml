view: v_fact_scorecard {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_FACT_SCORECARD" ;;

  # Core scorecard info
  dimension: scorecard_id {
    type: number
    sql: ${TABLE}."SCORECARD_ID" ;;
  }
  dimension: scorecard_recommendation {
    type: string
    sql: ${TABLE}."SCORECARD_RECOMMENDATION" ;;
  }
  dimension: created_at {
    type: date_raw
    sql: ${TABLE}."CREATED_AT" ;;
  }
  dimension: updated_at {
    type: date_raw
    sql: ${TABLE}."UPDATED_AT" ;;
  }

  # Who submitted the scorecard (interviewer if present, otherwise creator)
  dimension: creator_user_id {
    type: number
    sql: ${TABLE}."CREATOR_USER_ID" ;;
  }

  # Interviewer info
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

  # Interview info
  dimension: interview_id {
    type: number
    sql: ${TABLE}."INTERVIEW_ID" ;;
  }
  dimension: interview_name {
    type: string
    sql: ${TABLE}."INTERVIEW_NAME" ;;
  }
  dimension: interview_status {
    type: string
    sql: ${TABLE}."INTERVIEW_STATUS" ;;
  }
  dimension: start_of_interview {
    type: date_raw
    sql: ${TABLE}."START_OF_INTERVIEW" ;;
  }
  dimension: end_of_interview {
    type: date_raw
    sql: ${TABLE}."END_OF_INTERVIEW" ;;
  }

  # Application / Candidate / Requisition
  dimension: application_key {
    type: number
    sql: ${TABLE}."APPLICATION_KEY" ;;
  }
  dimension: application_applied_date {
    type: date_raw
    sql: ${TABLE}."APPLICATION_APPLIED_DATE" ;;
  }
  dimension: candidate_key {
    type: number
    sql: ${TABLE}."CANDIDATE_KEY" ;;
  }
  dimension: requisition_key {
    type: number
    sql: ${TABLE}."REQUISITION_KEY" ;;
  }
  dimension: stage_key {
    type: number
    sql: ${TABLE}."STAGE_KEY" ;;
  }

  # Offer context
  dimension: offer_key {
    type: number
    sql: ${TABLE}."OFFER_KEY" ;;
  }
  dimension: offer_resolved_date {
    type: date_raw
    sql: ${TABLE}."OFFER_RESOLVED_DATE" ;;
  }
  dimension: offer_sent_date {
    type: date_raw
    sql: ${TABLE}."OFFER_SENT_DATE" ;;
  }
  dimension: offer_created_date {
    type: date_raw
    sql: ${TABLE}."OFFER_CREATED_DATE" ;;
  }
  dimension: offer_starts_at_date {
    type: date_raw
    sql: ${TABLE}."OFFER_STARTS_AT_DATE" ;;
  }

  # Job metadata
  dimension: job_created_date {
    type: date_raw
    sql: ${TABLE}."JOB_CREATED_DATE" ;;
  }
  dimension: job_closed_date {
    type: date_raw
    sql: ${TABLE}."JOB_CLOSED_DATE" ;;
  }

  # Department
  dimension: department_key {
    type: number
    sql: ${TABLE}."DEPARTMENT_KEY" ;;
  }

  # Measures
  measure: count {
    type: count
    drill_fields: [interviewer_name, interview_name, creator_user_id]
  }
  measure: distinct_interviewers {
    type: count_distinct
    sql: ${interviewer_id} ;;
    description: "Unique interviewers"
  }
  measure: distinct_creators {
    type: count_distinct
    sql: ${creator_user_id} ;;
    description: "Unique scorecard creators"
  }
}
