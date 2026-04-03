include: "/_base/people_analytics/greenhouse/v_fact_recommendation_pass_through.view.lkml"

view: +recommendation_pass_through {

  ################ CORE FIELDS ################

  dimension: greenhouse_link {
    type: string
    html: "<a href=\"https://app.greenhouse.io/people/{{ candidate_id | url_encode }}?application_id={{ application_id | url_encode }}#application\" target=\"_blank\">Greenhouse Link</a>" ;;
  }

  dimension_group: application_history_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_date} ;;
  }

  ################ BENCHMARK DIMENSIONS (BY v_dim_stage.stage_name) ################

  dimension: benchmark_pass_through_rate {
    label: "Benchmark - Pass Through Rate"
    type: number
    value_format_name: "percent_0"
    sql:
      CASE
        WHEN ${v_dim_stage.stage_name} = 'Recruiter Phone Screen'       THEN 0.70
        WHEN ${v_dim_stage.stage_name} = 'Sent to Hiring Manager'       THEN 0.65
        WHEN ${v_dim_stage.stage_name} = 'Hiring Manager Interview(s)'  THEN 0.75
        WHEN ${v_dim_stage.stage_name} = 'Final Interview'              THEN 0.12
        ELSE NULL
      END ;;
  }

  dimension: benchmark_days_in_stage {
    label: "Benchmark - Days in Stage"
    type: number
    value_format_name: "decimal_0"
    sql:
      CASE
        WHEN ${v_dim_stage.stage_name} = 'Recruiter Phone Screen'       THEN 3
        WHEN ${v_dim_stage.stage_name} = 'Sent to Hiring Manager'       THEN 5
        WHEN ${v_dim_stage.stage_name} = 'Hiring Manager Interview(s)'  THEN 7
        WHEN ${v_dim_stage.stage_name} = 'Final Interview'              THEN 3
        ELSE NULL
      END ;;
  }

  ################ METRICS ################

  measure: unique_candidate_ids {
    type: count_distinct
    sql: ${candidate_id} ;;
    description: "The number of unique candidates"
    drill_fields: [candidate_full_name, candidate_id, greenhouse_link]
  }

  measure: avg_days_in_stage {
    type: average
    sql: ${application_history_days_in_stage} ;;
    value_format_name: "decimal_2"
    label: "Average Days in Stage"
  }

  measure: total_pass_throughs {
    type: sum
    sql: CASE WHEN ${application_rejection_reason} IS NULL THEN 1 ELSE 0 END ;;
    value_format_name: "decimal_0"
    label: "Total Pass-Throughs"
  }

  measure: total_rejections {
    type: sum
    sql: CASE WHEN ${application_rejection_reason} IS NOT NULL THEN 1 ELSE 0 END ;;
    value_format_name: "decimal_0"
    label: "Total Rejections"
  }
}
