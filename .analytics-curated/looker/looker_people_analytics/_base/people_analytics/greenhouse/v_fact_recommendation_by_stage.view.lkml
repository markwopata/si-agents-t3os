view: v_fact_recommendation_by_stage {
  sql_table_name: PEOPLE_ANALYTICS.GREENHOUSE.V_FACT_RECOMMENDATION_BY_STAGE ;;

  # Primary key
  dimension: scorecard_id {
    type: number
    sql: ${TABLE}.SCORECARD_ID ;;
    primary_key: yes
  }

  # Candidate
  dimension: candidate_full_name {
    type: string
    sql: ${TABLE}.CANDIDATE_FULL_NAME ;;
  }

  dimension: candidate_key {
    type: number
    sql: ${TABLE}.CANDIDATE_KEY ;;
  }

  dimension: candidate_id {
    type: string
    sql: ${TABLE}.CANDIDATE_ID ;;
  }

  # Scorecard
  dimension: scorecard_recommendation {
    type: string
    sql: ${TABLE}.SCORECARD_RECOMMENDATION ;;
  }

  # Interview
  dimension: interviewer_name {
    type: string
    sql: ${TABLE}.INTERVIEWER_NAME ;;
  }

  dimension: interview_name {
    type: string
    sql: ${TABLE}.INTERVIEW_NAME ;;
  }

  dimension: interview_id {
    type: number
    sql: ${TABLE}.INTERVIEW_ID ;;
  }

  # Stage
  dimension: stage_name {
    type: string
    sql: ${TABLE}.STAGE_NAME ;;
  }

  # Application
  dimension: application_id {
    type: string
    sql: ${TABLE}.APPLICATION_ID ;;
  }

  dimension: application_key {
    type: number
    sql: ${TABLE}.APPLICATION_KEY ;;
  }

  dimension: application_source_name {
    type: string
    sql: ${TABLE}.APPLICATION_SOURCE_NAME ;;
  }

  dimension: application_rejection_reason {
    type: string
    sql: ${TABLE}.APPLICATION_REJECTION_REASON ;;
  }

  # Timestamps
  dimension: scorecard_created_at {
    type: date_raw
    sql: ${TABLE}.SCORECARD_CREATED_AT ;;
  }

  # Requisition & Department
  dimension: department_name {
    type: string
    sql: ${TABLE}.DEPARTMENT_NAME ;;
  }

  dimension: requisition_name {
    type: string
    sql: ${TABLE}.REQUISITION_NAME ;;
  }

  dimension: requisition_id {
    type: number
    sql: ${TABLE}.REQUISITION_ID ;;
  }

  dimension: application_history_date {
    type: date_raw
    sql: ${TABLE}.APPLICATION_HISTORY_DATE ;;
  }


  # Optional measures
  measure: recommendation_count {
    type: count_distinct
    sql: ${TABLE}.SCORECARD_ID ;;
    drill_fields: [candidate_full_name, greenhouse_link, stage_name, scorecard_created_at]
  }

  dimension: greenhouse_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.greenhouse.io/people/{{ v_dim_candidate.candidate_id | url_encode }}?application_id={{ v_dim_application.application_id | url_encode }}#application" target="_blank">Greenhouse Link</a></font></u>;;
    sql: 'Link' ;;
  }

}
