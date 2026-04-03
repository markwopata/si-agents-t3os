include: "/_base/people_analytics/greenhouse/v_fact_application_history.view.lkml"


view: +v_fact_application_history {
  label: "Fact Application History"

  ################ DIMENSIONS ################

  dimension: application_history_application_key {
    value_format_name: id
    description: "The Key used to join Application table"
  }

  dimension: application_history_requistion_key {
    value_format_name: id
    description: "The Key used to join Requisition table"
  }

  dimension: application_history_stage_key {
    value_format_name: id
    description: "The Key used to join Stage table"
  }

  dimension: application_history_candidate_key {
    value_format_name: id
    description: "The Key used to join Candidate table"
  }

  dimension: application_history_department_key {
    value_format_name: id
    description: "The Key used to join Department table"
  }

  dimension: application_history_offer_key {
    value_format_name: id
    description: "The Key used to join Offer table"
  }

  dimension: application_history_key {
    primary_key: yes
    value_format_name: id
    description: "The Primary Key for the Application History Table"
  }

  dimension: pass_indicator {
    type: number
    sql: case when ${application_history_new_status} = 'rejected' then 0
    else 1 end;;
    description: "If 1 then this candidate passed this stage. This should be used as an indicator for pass through rates."
  }

  dimension: rejected_indicator {
    type: number
    sql: case when ${application_history_new_status} = 'rejected' then 1
      else 0 end;;
    description: "If 1 then this candidate was rejected at this stage. This should be used as an indicator for pass through rates."
  }

  ################ DATES ################

  dimension_group: application_history {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history} ;;
  }

  dimension_group: application_history_starts_at_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_starts_at} ;;
  }

  dimension_group: application_history_prior_stage_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_prior_stage} ;;
  }

  dimension_group: application_history_application_applied_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_application_applied} ;;
  }

  dimension_group: application_history_job_created_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_job_created} ;;
  }

  dimension_group: application_history_job_closed_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_job_closed} ;;
  }

  dimension_group: application_history_offer_created_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_offer_created} ;;
  }

  dimension_group: application_history_offer_sent_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_offer_sent} ;;
  }

  dimension_group: application_history_offer_resolved_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_history_offer_resolved} ;;
  }

  ################ MEASURES ################

  measure: sum_days_in_stage {
    type: sum
    sql: ${TABLE}."APPLICATION_HISTORY_DAYS_IN_STAGE" ;;
    value_format_name: decimal_2
  }

  measure: total_pass_throughs {
    type: sum
    sql: ${pass_indicator} ;;
    value_format_name: decimal_2
  }

  measure: total_rejections {
    type: sum
    sql: ${rejected_indicator} ;;
    value_format_name: decimal_2
  }


}
