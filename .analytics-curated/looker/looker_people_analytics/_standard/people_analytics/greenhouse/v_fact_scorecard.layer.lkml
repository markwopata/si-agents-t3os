include: "/_base/people_analytics/greenhouse/v_fact_scorecard.view.lkml"

view: +v_fact_scorecard {
  label: "Fact Scorecard"

  ################ DIMENSIONS ################

  dimension: scorecard_id {
    value_format_name: id
    description: "The ID used to identify a unique scorecard."
  }

  dimension: creator_user_id {
    value_format_name: id
    description: "The ID of the user who created or submitted the scorecard."
  }

  dimension: interviewer_id {
    value_format_name: id
    description: "The ID used to identify the interviewer, if applicable."
  }

  dimension: interview_id {
    value_format_name: id
    description: "The ID used to identify the scheduled interview, if applicable."
  }

  dimension: interviewer_name {
    value_format_name: id
    description: "The name of the interviewer, if applicable."
  }

  dimension: application_key {
    value_format_name: id
    description: "The Key used to join to the Application table."
  }

  dimension: candidate_key {
    value_format_name: id
    description: "The Key used to join to the Candidate table."
  }

  dimension: requisition_key {
    value_format_name: id
    description: "The Key used to join to the Requisition (Job) table."
  }

  dimension: stage_key {
    value_format_name: id
    description: "The Key used to join to the Job Stage table."
  }

  dimension: offer_key {
    value_format_name: id
    description: "The Key used to join to the Offer table."
  }

  dimension: department_key {
    value_format_name: id
    description: "The Key used to join to the Department table."
  }

  ################ MEASURES ################

  set: scorecard_drill_fields {
    fields: [
      scorecard_id,
      creator_user_id,
      interviewer_id,
      interview_id,
      application_key,
      candidate_key,
      requisition_key,
      scorecard_recommendation
    ]
  }

  measure: total_scorecards {
    type: count
    drill_fields: [scorecard_drill_fields*]
    description: "Total number of scorecards."
  }

  measure: unique_interviewers {
    type: count_distinct
    sql: ${interviewer_id} ;;
    drill_fields: [scorecard_drill_fields*]
    description: "Number of distinct interviewers who submitted scorecards."
  }

  measure: unique_creators {
    type: count_distinct
    sql: ${creator_user_id} ;;
    drill_fields: [scorecard_drill_fields*]
    description: "Number of distinct users who created scorecards."
  }

  ################ DATE DIMENSION GROUPS ################

  dimension_group: created_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${created_at} ;;
    description: "Timestamp when the scorecard record was created."
  }

  dimension_group: updated_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${updated_at} ;;
    description: "Timestamp when the scorecard record was last updated."
  }

  dimension_group: start_of_interview {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${start_of_interview} ;;
    description: "Start time of the interview."
  }

  dimension_group: end_of_interview {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${end_of_interview} ;;
    description: "End time of the interview."
  }

  dimension_group: application_applied_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_applied_date} ;;
    description: "Date when the application was submitted."
  }

  dimension_group: offer_resolved_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_resolved_date} ;;
    description: "Date when the offer was resolved."
  }

  dimension_group: offer_sent_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_sent_date} ;;
    description: "Date when the offer was sent."
  }

  dimension_group: offer_created_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_created_date} ;;
    description: "Date when the offer record was created."
  }

  dimension_group: offer_starts_at_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_starts_at_date} ;;
    description: "The start date for the accepted offer."
  }

  dimension_group: job_created_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${job_created_date} ;;
    description: "Date when the job was created."
  }

  dimension_group: job_closed_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${job_closed_date} ;;
    description: "Date when the job was closed."
  }
}
