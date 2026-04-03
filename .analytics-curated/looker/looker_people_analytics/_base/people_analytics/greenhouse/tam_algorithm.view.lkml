view: tam_algorithm {
  sql_table_name: "PEOPLE_ANALYTICS"."GREENHOUSE"."TAM_ALGORITHM" ;;

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }
  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }
  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }
  dimension: total_score {
    type: number
    sql: ${TABLE}."TOTAL_SCORE" ;;
  }
  measure: count {
    type: count
  }
}
