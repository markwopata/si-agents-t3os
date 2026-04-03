include: "/_standard/people_analytics/greenhouse/v_bridge_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_department.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_stage.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_interview_scorecard.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_history.layer.lkml"

view: +v_fact_interview_scorecard {

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
          WHEN (CONTAINS(${v_dim_requisition.requisition_name},'Field Technician') OR CONTAINS(${v_dim_requisition.requisition_name},'Shop Technician') OR CONTAINS(${v_dim_requisition.requisition_name},'Service Technician') OR CONTAINS(${v_dim_requisition.requisition_name},'Diesel Technician')) THEN 'Techs'
          WHEN CONTAINS(${v_dim_requisition.requisition_name},'CDL Delivery Driver') THEN 'CDL Delivery Driver'
          ELSE 'Other' END ;;
  }
}

explore:  v_fact_interview_scorecard {
  label: "TA Dashboard Interview Scorecard"

  join: v_dim_application {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_interview_scorecard.application_key} = ${v_dim_application.application_key} ;;
  }

  join: v_dim_requisition {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_interview_scorecard.requisition_key} = ${v_dim_requisition.requisition_key} ;;
  }

  join: v_dim_stage {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_interview_scorecard.stage_key} = ${v_dim_stage.stage_key} ;;
  }

  join: v_dim_candidate {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_interview_scorecard.candidate_key} = ${v_dim_candidate.candidate_key} ;;
  }

  join: v_dim_department {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_interview_scorecard.department_key} = ${v_dim_department.department_key} ;;
  }

  join: v_dim_offer {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_interview_scorecard.offer_key} = ${v_dim_offer.offer_key} ;;
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

  join: v_fact_application_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_interview_scorecard.application_key} = ${v_fact_application_history.application_history_application_key} ;;
  }
}
