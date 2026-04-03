connection: "es_snowflake_pa_c_analytics"

include: "/_standard/people_analytics/greenhouse/v_fact_hiring_overview.view"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_stage.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_history.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_interview_scorecard.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_department.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_requisition_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_scorecard.layer.lkml"




explore: hiring_overview {
  label: "Hiring Overview"
  view_name: v_dim_application

  join: v_dim_candidate {
    type: inner
    relationship: one_to_one
    sql_on: ${v_dim_application.application_candidate_key} = ${v_dim_candidate.candidate_key} ;;
  }

  join: v_dim_requisition {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_requistion_key} = ${v_dim_requisition.requisition_key} ;;
  }

  join: v_fact_application_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_application.application_key} = ${v_fact_application_history.application_history_application_key} ;;
  }

  join: v_dim_stage {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_stage_key} = ${v_dim_stage.stage_key} ;;
  }

  join:  v_dim_offer {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_offer_key} = ${v_dim_offer.offer_key};;
  }


  join: v_fact_interview_scorecard {
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_dim_application.application_key} = ${v_fact_interview_scorecard.application_key} ;;
  }


  join: v_dim_department {
    type: inner
    relationship: one_to_one
    sql_on: ${v_dim_application.application_department_key} = ${v_dim_department.department_key} ;;
  }

  join: v_bridge_dim_office {
    type: inner
    relationship: one_to_one
    sql_on: ${v_dim_requisition.requisition_key} = ${v_bridge_dim_office.bridge_dim_office_requisition_key} ;;
  }

  join:  v_dim_office {
    type: inner
    relationship: one_to_many
    sql_on: ${v_dim_office.office_key} = ${v_bridge_dim_office.bridge_dim_office_key};;
  }

  join: v_fact_application_requisition_offer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_application.application_key} = ${v_fact_application_requisition_offer.application_requisition_offer_application_key} ;;
  }

  join: v_fact_hiring_overview {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_dim_application.application_key} = ${v_fact_hiring_overview.application_key} ;;
  }

  join: v_fact_scorecard {
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_dim_application.application_key} = ${v_fact_scorecard.application_key} ;;
  }



}
