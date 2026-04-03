include: "/_base/people_analytics/greenhouse/v_fact_interview_scorecard.view.lkml"


view: +v_fact_interview_scorecard {
  label: "Fact Interview Scorecard"

  ################ DIMENSIONS ################

  dimension: interview_id {
    value_format_name: id
    description: "The ID used to identify a specific interview."
  }

  dimension: application_key {
    value_format_name: id
    description: "The Key used to join the Application table. Also is the application ID"
  }

  dimension: requisition_key {
    value_format_name: id
    description: "The Key used to join the Requisition table."
  }

  dimension: stage_key {
    value_format_name: id
    description: "The Key used to join the Stage table."
  }

  dimension: offer_key {
    value_format_name: id
    description: "The Key used to join the Offer table."
  }

  dimension: candidate_key {
    value_format_name: id
    description: "The Key used to join Stage table"
  }

  dimension: department_key {
    value_format_name: id
    description: "The Key used to join the Department table."
  }

  dimension: organizer_id {
    value_format_name: id
    description: "The ID used to identify who the organizer of the interview is."
  }

  dimension: interviewer_id {
    value_format_name: id
    description: "The ID used to identify who the interviewer is."
  }

  dimension: scorecard_id {
    value_format_name: id
    description: "The ID used to identify a unique scorecard."
  }

  dimension: unsubmitted_scorecard_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.greenhouse.io/guides/{{ interview_id | url_encode }}/people/{{ v_dim_candidate.candidate_id | url_encode }}?application_id={{ v_dim_application.application_id }}#scorecard" target="_blank">Scorecard Link</a></font></u>;;
    sql: 'Link' ;;
  }

  ################ MEASURES ################

  set: interview_drill_fields {
    fields: [interview_id,
      interview_name,
      interview_status,
      v_dim_candidate.candidate_full_name,
      interviewer_name,
      interviewer_role,
      scorecard_recommendation,
      unsubmitted_scorecard_link,
      start_of_interview_date]
  }

  measure: unique_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    drill_fields: [interview_drill_fields*]
    description: "Total number of distinct interviews."
  }

  measure: completed_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "complete"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of distinct completed interviews."
  }

  measure: scheduled_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "scheduled"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of distinct completed interviews."
  }

  measure: awaiting_feedback_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "awaiting_feedback"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of distinct completed interviews."
  }

  measure: to_be_scheduled_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "to_be_scheduled"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of distinct completed interviews."
  }

  measure: skipped_interview_ids {
    type: count_distinct
    sql: ${interview_id} ;;
    filters: [interview_status: "skipped"]
    drill_fields: [interview_drill_fields*]
    description: "Total number of distinct completed interviews."
  }

  ################ DATES ################

  dimension_group: start_of_interview {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${start_of_interview} ;;
  }

  dimension_group: end_of_interview {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${end_of_interview} ;;
  }

  dimension_group: application_applied {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_applied} ;;
  }

  dimension_group: offer_resolved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_resolved} ;;
  }

  dimension_group: offer_sent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_sent} ;;
  }

  dimension_group: offer_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_created} ;;
  }

  dimension_group: offer_starts_at {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${offer_starts_at} ;;
  }
  dimension_group: job_closed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${job_closed} ;;
  }
  dimension_group: job_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${job_created} ;;
  }
}
