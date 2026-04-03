  include: "/_base/people_analytics/greenhouse/v_fact_application_requisition_offer.view.lkml"


view: +v_fact_application_requisition_offer {
  label: "Fact Application Requisition Offer"

  ################ DIMENSIONS ################

  dimension: application_requisition_offer_application_key {
    value_format_name: id
    description: "The Key used to join Application table"
  }

  dimension: application_requisition_offer_requisition_key {
    value_format_name: id
    description: "The Key used to join Requisition table"
  }

  dimension: application_requisition_offer_offer_key {
    value_format_name: id
    description: "The Key used to join Offer table"
  }

  dimension: application_requisition_offer_candidate_key {
    value_format_name: id
    description: "The Key used to join Candidate table"
  }

  dimension: application_requisition_offer_department_key {
    value_format_name: id
    description: "The Key used to join Department table"
  }

  dimension: application_requisition_offer_stage_key {
    value_format_name: id
    description: "The Key used to join Stage table"
  }



  ################ DATES ################

  dimension_group: application_requisition_offer_application_applied {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_application_applied} ;;
  }

  dimension_group: application_requisition_offer_job_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_job_created} ;;
  }

  dimension_group: application_requisition_offer_job_closed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_job_closed} ;;
  }

  dimension_group: application_requisition_offer_offer_resolved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_offer_resolved} ;;
  }

  dimension_group: application_requisition_offer_offer_sent {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_offer_sent} ;;
  }

  dimension_group: application_requisition_offer_offer_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_offer_created} ;;
  }

  dimension_group: application_requisition_offer_offer_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_offer_start} ;;
  }

  dimension_group: application_requisition_offer_job_posting {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_job_posting} ;;
  }

  dimension_group: application_requisition_offer_offer_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_offer_start} ;;
  }

  dimension_group: application_requisition_offer_job_posting {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${application_requisition_offer_job_posting} ;;
  }
}
