view: technician_tiers_overall {
  sql_table_name: "LOOKER"."TECHNICIAN_TIERS_OVERALL" ;;

  dimension: applicant_score {
    type: number
    sql: ${TABLE}."APPLICANT_SCORE" ;;
  }
  dimension: APPLICATION_ID {
    type: string
    sql: ${TABLE}."APPLICATION_ID" ;;
  }
  dimension: hiring_manager_score {
    type: number
    sql: ${TABLE}."HIRING_MANAGER_SCORE" ;;
  }
  dimension: holistic_score {
    type: number
    sql: ${TABLE}."HOLISTIC_SCORE" ;;
  }
  dimension: initial_tier_placement {
    type: string
    sql: ${TABLE}."INITIAL_TIER_PLACEMENT" ;;
  }
  measure: count {
    type: count
  }
}
