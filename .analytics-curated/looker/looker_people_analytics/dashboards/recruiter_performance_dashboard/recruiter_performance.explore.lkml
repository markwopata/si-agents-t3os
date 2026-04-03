include: "/_standard/people_analytics/greenhouse/tam_algorithm.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_date.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_department.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition_recruiter.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_stage.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_requisition_offer.layer.lkml"
include: "/_standard/analytics/public/disc_master.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/analytics/payroll/recruiter_company_directory.layer.lkml"
include: "/_standard/people_analytics/looker/recruiting_difficulty.layer.lkml"

view: +v_fact_application_requisition_offer {


}

view: +v_dim_application {

  measure: unique_application_ids {
    type: count_distinct
    sql: ${application_id} ;;
    description: "The number of unique application ids"
    drill_fields: [application_drill_fields*]
  }

  set: application_drill_fields {
    fields: [v_dim_candidate.candidate_full_name,
      v_dim_requisition_recruiter.requisition_name,
      v_dim_stage.stage_name,
      v_dim_candidate.greenhouse_link,
      v_dim_candidate.disc_link,
      disc_master.environment_style_link,
      v_fact_application_requisition_offer.application_requisition_offer_application_applied_date]
  }
}

view: +v_dim_candidate {

  measure: unique_candidate_ids {
    type: count_distinct
    sql: ${candidate_id} ;;
    description: "The number of unique candidate ids"
    drill_fields: [candidate_drill_fields*]
  }

  set: candidate_drill_fields {
    fields: [v_dim_requisition_recruiter.requisition_id,
      candidate_full_name,
      v_dim_requisition_recruiter.requisition_name,
      v_dim_stage.stage_name,
      greenhouse_link,
      disc_link,
      disc_master.environment_style_link,
      disc_master.d_environment,
      disc_master.i_environment,
      disc_master.s_environment,
      disc_master.c_environment,
      v_fact_application_requisition_offer.application_requisition_offer_application_applied_date,
      v_fact_application_requisition_offer.application_requisition_offer_offer_start_date]
  }
}

view: +v_dim_offer {

  measure: unique_offer_ids {
    type: count_distinct
    sql: ${offer_id} ;;
    drill_fields: [drill_fields*]
    description: "Total number of distinct offers"
  }

  measure: unique_internal_offers {
    type: count_distinct
    sql: ${offer_id} ;;
    filters: [offer_custom_internal_external_applicant: "Internal"]
    drill_fields: [drill_fields*]
    description: "Total number of distinct internal offers"
  }

  measure: unique_external_offers {
    type: count_distinct
    sql: ${offer_id} ;;
    filters: [offer_custom_internal_external_applicant: "External"]
    drill_fields: [drill_fields*]
    description: "Total number of distinct external offers"
  }

  set: drill_fields {
    fields: [offer_id,
      v_dim_application.application_id,
      v_dim_candidate.candidate_full_name,
      v_dim_requisition_recruiter.requisition_name,
      v_fact_application_requisition_offer.application_requisition_offer_offer_created_date,
      v_fact_application_requisition_offer.application_requisition_offer_offer_sent_date,
      v_fact_application_requisition_offer.application_requisition_offer_offer_resolved_date]
  }
}

view: +v_dim_requisition_recruiter {

  measure: unique_requisition_ids {
    type: count_distinct
    sql: ${requisition_id} ;;
    drill_fields: [drill_fields*]
    description: "Total number of distinct requisitions"
  }

  measure: unique_backfill_requisition_ids {
    type: count_distinct
    sql: ${requisition_id} ;;
    drill_fields: [drill_fields*]
    description: "Total number of distinct backfill requisitions"
  }

  measure: unique_new_headcount_requisition_ids {
    type: count_distinct
    sql: ${requisition_id} ;;
    drill_fields: [drill_fields*]
    description: "Total number of distinct new headcount requisitions"
  }

  set: drill_fields {
    fields: [requisition_id,
      requisition_name,
      requisition_key,
      requisition_status,
      v_dim_office.office_name,
      v_fact_application_requisition_offer.application_requisition_offer_job_created_date,
      v_fact_application_requisition_offer.application_requisition_offer_job_closed_date,
      greenhouse_link,
      v_fact_application_requisition_offer.application_requisition_offer_offer_start_date]
  }
}

explore:  v_fact_application_requisition_offer {
  label: "TA Dashboard Greenhouse"

  join:  v_bridge_dim_office {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_key} = ${v_bridge_dim_office.bridge_dim_office_application_requisition_offer_key} ;;
  }

  join: v_dim_application {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_application_key} = ${v_dim_application.application_key} ;;
  }

  join: v_dim_candidate {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_candidate_key} = ${v_dim_candidate.candidate_key} ;;
  }

  join: v_dim_department {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_department_key} = ${v_dim_department.department_key} ;;
  }

  join: v_dim_offer {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_offer_key} = ${v_dim_offer.offer_key} ;;
  }

  join: v_dim_office {
    type: inner
    relationship: one_to_one
    sql_on: ${v_bridge_dim_office.bridge_dim_office_key} = ${v_dim_office.office_key} ;;
  }

  join: v_dim_requisition_recruiter {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_requisition_key} = ${v_dim_requisition_recruiter.requisition_key} ;;
  }

  join: v_dim_stage {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_stage_key} = ${v_dim_stage.stage_key} ;;
  }

  join: application_dates {
    view_label: "Dates: Application"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_application_applied} = ${application_dates.date} ;;
  }

  join: requisition_open_dates {
    view_label: "Dates: Requisition Open"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_job_created} = ${requisition_open_dates.date} ;;
  }

  join: requisition_closed_dates {
    view_label: "Dates: Requisition Closed"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_job_closed} = ${requisition_closed_dates.date} ;;
  }

  join: offer_created_dates {
    view_label: "Dates: Offer Created"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_offer_created} = ${offer_created_dates.date} ;;
  }

  join: offer_resolved_dates {
    view_label: "Dates: Offer Resolved"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_offer_resolved} = ${offer_resolved_dates.date} ;;
  }

  join: offer_sent_dates {
    view_label: "Dates: Offer Sent"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_offer_sent} = ${offer_sent_dates.date} ;;
  }

  join: offer_start_dates {
    view_label: "Dates: Offer Start"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_offer_start} = ${offer_start_dates.date} ;;
  }

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_candidate.candidate_custom_disc_code} = ${disc_master.disc_code} ;;
  }

  join: tam_algorithm_application {
    view_label: "TAM Algorithm by Application"
    from: tam_algorithm
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_application.application_id} = ${tam_algorithm_application.application_id} ;;
  }

  join: tam_algorithm_candidate {
    view_label: "TAM Algorithm by Candidate"
    from: tam_algorithm
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_candidate.candidate_id} = ${tam_algorithm_application.candidate_id} ;;
  }

  join: tam_algorithm_job {
    view_label: "TAM Algorithm by Job"
    from: tam_algorithm
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_requisition_recruiter.requisition_key} = ${tam_algorithm_application.job_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_application_key} = ${company_directory.greenhouse_application_id} ;;
  }


  join: recruiting_difficulty{
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_dim_requisition_recruiter.requisition_name} = ${recruiting_difficulty.job_name} ;;
  }

  join: recruiter_company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_requisition_recruiter.requisition_recruiter_employee_id}::varchar = ${recruiter_company_directory.employee_id}::varchar ;;
  }
}
