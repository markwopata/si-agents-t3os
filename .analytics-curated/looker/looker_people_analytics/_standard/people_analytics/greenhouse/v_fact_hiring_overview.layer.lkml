view: v_fact_hiring_overview_dashboard {
  sql_table_name: people_analytics.greenhouse.v_fact_hiring_overview ;;

  label: "Fact Hiring Overview"

  # === Base Identifiers ===
  dimension: candidate_full_name {
    type: string
    sql: ${TABLE}.candidate_full_name ;;
  }

  dimension: candidate_key {
    value_format_name: id
    sql: ${TABLE}.candidate_key ;;
  }

  dimension: candidate_id {
    value_format_name: id
    sql: ${TABLE}.candidate_id ;;
  }

  dimension: scorecard_id {
    value_format_name: id
    sql: ${TABLE}.scorecard_id ;;
  }

  dimension: interviewer_name {
    type: string
    sql: ${TABLE}.interviewer_name ;;
  }

  dimension: interview_name {
    type: string
    sql: ${TABLE}.interview_name ;;
  }

  dimension: interview_id {
    value_format_name: id
    sql: ${TABLE}.interview_id ;;
  }

  dimension: application_id {
    value_format_name: id
    sql: ${TABLE}.application_id ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.department_name ;;
  }

  dimension: stage_name {
    type: string
    sql: ${TABLE}.stage_name ;;
  }

  dimension: requisition_name {
    type: string
    sql: ${TABLE}.requisition_name ;;
  }

  dimension: application_source_name {
    type: string
    sql: ${TABLE}.application_source_name ;;
  }

  dimension: application_rejection_reason {
    type: string
    sql: ${TABLE}.application_rejection_reason ;;
  }

  dimension: application_key {
    type: string
    sql: ${TABLE}.application_key ;;
  }

  # === Time Dimensions ===
  dimension_group: scorecard_created_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.scorecard_created_at ;;
  }

  # === Measures ===
  measure: total_applications {
    type: count_distinct
    sql: ${application_id} ;;
    label: "Total Applications"
  }

  measure: total_scorecards {
    type: count_distinct
    sql: ${scorecard_id} ;;
    label: "Total Scorecards"
  }

  measure: candidates_interviewed {
    type: count_distinct
    sql: ${candidate_id} ;;
    label: "Candidates Interviewed"
  }

  measure: by_stage {
    type: count
    sql: ${stage_name} ;;
    label: "Applications by Stage"
  }

  measure: by_source {
    type: count
    sql: ${application_source_name} ;;
    label: "Applications by Source"
  }

  measure: rejections {
    type: count
    filters: [application_rejection_reason: "-NULL"]
    sql: ${application_rejection_reason} ;;
    label: "Rejections"
  }
}
