include: "/_standard/people_analytics/greenhouse/tam_algorithm.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_date.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_department.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_stage.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_requisition_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_requisition_dim_employee.layer.lkml"
include: "/_standard/analytics/public/disc_master.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"

  view: +v_fact_application_requisition_offer {

    dimension: unicorn_departments_jobs {
      type: string
      sql:CASE WHEN CONTAINS(${v_dim_requisition.requisition_name},'General Manager') AND NOT CONTAINS(${v_dim_requisition.requisition_name}, 'Assistant General Manager') THEN 'General Managers'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'District Sales Manager') THEN 'District Sales Managers'
          WHEN CONTAINS(${v_dim_department.department_name},'Business Analytics') THEN 'Business Analytics'
          WHEN (CONTAINS(${v_dim_department.department_name},'Accounting') OR CONTAINS(${v_dim_department.department_name},'Finance')) THEN 'Accounting/Finance'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'Construction Project Manager') THEN 'Construction Project Managers'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'Territory Account Manager') THEN 'Territory Account Managers'
          ELSE 'Other' END ;;
    }
  }

  view: +v_dim_application {

    measure: unique_application_ids {
      type: count_distinct
      sql: ${application_id} ;;
      description: "Total number of distinct applications"
      drill_fields: [v_dim_office.office_region_name,
        application_id,
        v_dim_candidate.candidate_full_name,
        tam_disc.environment_style,
        v_dim_candidate.disc_link,
        tam_algorithm_application.total_score]
    }
  }

  view: +v_dim_candidate {

    measure: unique_candidate_ids {
      type: count_distinct
      sql: ${candidate_id} ;;
      drill_fields: [candidate_drills*]
    }

    set: candidate_drills {
      fields: [v_dim_application.application_id,
      v_dim_stage.stage_name,
      candidate_full_name,
      v_dim_requisition.requisition_id,
      v_dim_requisition.requisition_name,
      v_bridge_dim_office.bridge_dim_office_name_full_path,
      greenhouse_link,
      tam_disc.environment_style,
      disc_link,
      tam_algorithm.total_score,
      tam_disc.disc_points]
    }
  }

explore:  v_fact_application_requisition_offer {
  label: "Greenhouse"

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

  join: v_dim_requisition {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_requisition_key} = ${v_dim_requisition.requisition_key} ;;
  }

  join: v_dim_stage {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_stage_key} = ${v_dim_stage.stage_key} ;;
  }

  join: v_bridge_dim_requisition_dim_employee {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_requisition_key} = ${v_bridge_dim_requisition_dim_employee.bridge_dim_requisition_dim_employee_requisition_key} ;;
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
    sql_on: ${v_dim_requisition.requisition_key} = ${tam_algorithm_application.job_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_application.application_id} = ${company_directory.greenhouse_application_id} ;;
  }
}
