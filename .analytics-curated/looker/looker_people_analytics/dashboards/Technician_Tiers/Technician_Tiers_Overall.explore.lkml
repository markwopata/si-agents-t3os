
include: "/_standard/people_analytics/looker/technician_tiers_overall.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_department.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_office.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_requisition.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_history.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_bridge_dim_requisition_dim_employee.layer.lkml"


explore: technician_tiers_overall {


  join: v_dim_application {
    type: inner
    relationship: one_to_one
    sql_on: ${technician_tiers_overall.APPLICATION_ID} = ${v_dim_application.application_key}::varchar ;;
  }

  join: v_fact_application_history {
    type: inner
    relationship: one_to_many
    sql_on: ${v_dim_application.application_key} = ${v_fact_application_history.application_history_application_key} ;;
  }

  join: v_dim_requisition {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_requistion_key} = ${v_dim_requisition.requisition_key} ;;
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

  join: v_bridge_dim_requisition_dim_employee {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_history.application_history_requistion_key} = ${v_bridge_dim_requisition_dim_employee.bridge_dim_requisition_dim_employee_requisition_key} ;;
  }
}
