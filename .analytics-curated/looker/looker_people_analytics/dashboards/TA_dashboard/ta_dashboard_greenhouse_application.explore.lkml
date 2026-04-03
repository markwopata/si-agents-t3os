include: "/_standard/people_analytics/greenhouse/tam_algorithm.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_date.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_department.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_stage.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_history.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_requisition_offer.layer.lkml"


view: +v_fact_application_history {

  dimension: unicorn_departments_jobs {
    type: string
    sql:CASE WHEN ${v_dim_requisition.requisition_name}='General Manager' OR ${v_dim_requisition.requisition_name}='General Manager - Advanced Solutions' THEN 'General Managers'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'District Sales Manager') THEN 'District Sales Managers'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'Service Manager') THEN 'Service Managers'
          WHEN CONTAINS(${v_dim_department.department_name},'Business Analytics') THEN 'Business Analytics'
          WHEN (CONTAINS(${v_dim_department.department_name},'Accounting') OR CONTAINS(${v_dim_department.department_name},'Finance')) THEN 'Accounting/Finance'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'Construction Project Manager') THEN 'Construction Project Managers'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager') THEN 'Territory Account Managers'
          WHEN (CONTAINS(${v_dim_requisition.requisition_name},'National Account Manager') OR CONTAINS(${v_dim_requisition.requisition_name},'Retail Sales Manager') OR CONTAINS(${v_dim_requisition.requisition_name},'New Equipment Sales Rep')) THEN 'Sales'
          WHEN (CONTAINS(${v_dim_requisition.requisition_name},'Field Technician') OR CONTAINS(${v_dim_requisition.requisition_name},'Service Technician') OR CONTAINS(${v_dim_requisition.requisition_name},'Shop Technician') OR CONTAINS(${v_dim_requisition.requisition_name},'Diesel Technician')) THEN 'Techs'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'CDL Delivery Driver') THEN 'CDL Delivery Driver'
          ELSE 'Other' END ;;
  }
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
      v_dim_requisition.requisition_name,
      v_dim_stage.stage_name,
      v_dim_candidate.greenhouse_link,
      v_dim_candidate.disc_link,
      v_fact_application_history.application_requisition_offer_application_applied_date]
  }
}

view: +v_dim_offer {

  measure: unique_no_shows {
    type: count_distinct
    sql: ${v_dim_candidate.candidate_id} ;;
    filters: [v_fact_application_history.application_history_new_status: "hired",
      v_fact_application_history.application_history_final_new_status: "rejected"]
    description: "Total number of distinct no show candidates."
    drill_fields: [v_dim_requisition.requisition_id,
      v_dim_candidate.candidate_full_name,
      v_dim_requisition.requisition_name,
      v_dim_stage.stage_name,
      v_dim_candidate.greenhouse_link,
      v_dim_candidate.disc_link,
      v_fact_application_history.application_requisition_offer_application_applied_date]
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
    fields: [v_dim_requisition.requisition_id,
      candidate_full_name,
      v_dim_requisition.requisition_name,
      v_dim_stage.stage_name,
      greenhouse_link,
      disc_link,
      v_fact_application_history.application_requisition_offer_application_applied_date]
  }
}

view: +v_dim_requisition {

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
      v_fact_application_history.application_requisition_offer_job_created_date,
      v_fact_application_history.application_requisition_offer_job_closed_date,
      greenhouse_link,
      v_fact_application_history.application_requisition_offer_offer_start_date]
  }
}





explore:  v_fact_application_history {
  label: "TA Dashboard Greenhouse Application History"

  join: v_dim_application {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_application_key} = ${v_dim_application.application_key} ;;
  }

  join: v_dim_requisition {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_requistion_key} = ${v_dim_requisition.requisition_key} ;;
  }

  join: v_dim_stage {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_stage_key} = ${v_dim_stage.stage_key} ;;
  }

  join: v_dim_candidate {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_candidate_key} = ${v_dim_candidate.candidate_key} ;;
  }

  join: v_dim_department {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_department_key} = ${v_dim_department.department_key} ;;
  }

  join: application_history_dates {
    view_label: "Dates: Application History"
    from: v_dim_date
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_date} = ${application_history_dates.date} ;;
  }

  join:  v_bridge_dim_office {
    type: inner
    relationship: one_to_one
    sql_on: ${v_dim_requisition.requisition_key}= ${v_bridge_dim_office.bridge_dim_office_requisition_key} ;;
  }

  join:  v_dim_office {
    type: inner
    relationship: one_to_many
    sql_on: ${v_dim_office.office_key} = ${v_bridge_dim_office.bridge_dim_office_key};;
  }

  join:  v_dim_offer {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_offer_key} = ${v_dim_offer.offer_key};;
  }

  join: application_dates {
    view_label: "Dates: Application"
    from: v_dim_date
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_application_applied} = ${application_dates.date} ;;
  }

  join: requisition_open_dates {
    view_label: "Dates: Requisition Open"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_history.application_history_job_created} = ${requisition_open_dates.date} ;;
  }

  join: requisition_closed_dates {
    view_label: "Dates: Requisition Closed"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_history.application_history_job_closed} = ${requisition_closed_dates.date} ;;
  }

  join: offer_created_dates {
    view_label: "Dates: Offer Created"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_history.application_history_offer_created} = ${offer_created_dates.date} ;;
  }

  join: offer_resolved_dates {
    view_label: "Dates: Offer Resolved"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_history.application_history_offer_resolved} = ${offer_resolved_dates.date} ;;
  }

  join: offer_sent_dates {
    view_label: "Dates: Offer Sent"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_history.application_history_offer_sent} = ${offer_sent_dates.date} ;;
  }

  join: offer_start_dates {
    view_label: "Dates: Offer Start"
    from: v_dim_date
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_fact_application_history.application_history_starts_at} = ${offer_start_dates.date} ;;
  }

  join: prior_stage_dates {
    view_label: "Dates: Application History"
    from: v_dim_date
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_prior_stage_date_date} = ${prior_stage_dates.date} ;;
  }

  join: v_fact_application_requisition_offer {
    type: left_outer
    sql_on: ${v_fact_application_history.application_history_application_key} = ${v_fact_application_requisition_offer.application_requisition_offer_application_key} ;;
    relationship: many_to_one
  }
}
