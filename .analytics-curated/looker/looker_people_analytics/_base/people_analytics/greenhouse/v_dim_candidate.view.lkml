view: v_dim_candidate {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."V_DIM_CANDIDATE" ;;

  dimension: candidate_can_email {
    type: yesno
    sql: ${TABLE}."CANDIDATE_CAN_EMAIL" ;;
  }
  dimension: candidate_coordinator_full_name {
    type: string
    sql: ${TABLE}."CANDIDATE_COORDINATOR_FULL_NAME" ;;
  }
  dimension: candidate_custom_disc_code {
    type: string
    sql: ${TABLE}."CANDIDATE_CUSTOM_DISC_CODE" ;;
  }
  dimension: candidate_custom_disc_sent {
    type: date_raw
    sql: ${TABLE}."CANDIDATE_CUSTOM_DISC_SENT_DATE" ;;
  }
  dimension: candidate_custom_scorecard_score{
    type: number
    sql: ${TABLE}."CANDIDATE_CUSTOM_SCORECARD_SCORE" ;;
  }
  dimension: candidate_first_name {
    type: string
    sql: ${TABLE}."CANDIDATE_FIRST_NAME" ;;
  }
  dimension: candidate_full_name {
    type: string
    sql: ${TABLE}."CANDIDATE_FULL_NAME" ;;
  }
  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }
  dimension: candidate_key {
    type: number
    sql: ${TABLE}."CANDIDATE_KEY" ;;
  }
  dimension: candidate_last_name {
    type: string
    sql: ${TABLE}."CANDIDATE_LAST_NAME" ;;
  }
  dimension: candidate_recruiter_full_name {
    type: string
    sql: ${TABLE}."CANDIDATE_RECRUITER_FULL_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [candidate_first_name, candidate_full_name, candidate_last_name, candidate_recruiter_full_name, candidate_coordinator_full_name]
  }
}
