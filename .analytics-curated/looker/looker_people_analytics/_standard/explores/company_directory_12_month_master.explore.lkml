include: "/_standard/internal_mobility/company_directory.view.lkml"
include: "/_standard/custom_sql/job_changes.view.lkml"
include: "/_standard/custom_sql/pay_changes.view.lkml"
include: "/_standard/recruiting_kpis/application_info_view.view.lkml"
include: "/_standard/custom_sql/job_history_internal_mobility.view.lkml"
include: "/_standard/custom_sql/jobs_internal_mobility.view.lkml"
include: "/_standard/custom_sql/department_changes.view.lkml"

include: "/_standard/organizational_summary/ee_company_directory_12_month.view.lkml" ##we have to get this replaced. Have to address the change of measures to
## dimensions (i.e., headcount, terminations, rehires, etc.) These are breaking the refinement.
# include: "/_standard/analytics/payroll/ee_company_directory_12_month.layer.lkml"

include: "/_standard/recruiting_kpis/disc_gh_ukg.view.lkml"
include: "/_standard/recruiting_kpis/ukg_cost_center_market_id_mapping.view.lkml"
include: "/_standard/organizational_health/planning_financials.view.lkml"
include: "/_standard/custom_sql/hr_greenhouse_link.view.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_requisition_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"

view: +ee_company_directory_12_month {

  parameter: select_period_over_period {
    type: unquoted
    default_value: "1"
    allowed_value: {
      value: "1"
      label: "Last 12 Months"
    }
    allowed_value: {
      value: "2"
      label: "2024"
    }
    allowed_value: {
      value: "3"
      label: "2023"
    }
  }

  dimension: period_over_period_date {
    type: date
    sql:
      case
    when {{ select_period_over_period._parameter_value }} = 1 then date_trunc('month',${_es_update_timestamp_raw_})
    when {{ select_period_over_period._parameter_value }} = 2 then date_trunc('month',${_es_update_timestamp_raw_})
    when {{ select_period_over_period._parameter_value }} = 3 then date_trunc('month',${_es_update_timestamp_raw_})
    else date_trunc('month',${_es_update_timestamp_raw_})
    end
    ;;
  }

  dimension: period_over_period_flag {
    type: yesno
    sql:
      case
    when {{ select_period_over_period._parameter_value }} = 1 then ${_es_update_timestamp_date} >= to_date(dateadd('month',-12,date_trunc('month',current_date)))
    when {{ select_period_over_period._parameter_value }} = 2 then ${_es_update_timestamp_year} = 2024
    when {{ select_period_over_period._parameter_value }} = 3 then ${_es_update_timestamp_year} = 2023
    else ${_es_update_timestamp_date} >= to_date(dateadd('month',-12,date_trunc('month',current_date)))
    end
    ;;
  }
}

explore: ee_company_directory_12_month {
  always_join: [job_changes]
  label: "Company Directory 12 Month Master"
  case_sensitive: no

  join: job_changes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${job_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }

  join: disc_gh_ukg {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${job_changes.employee_id} = ${disc_gh_ukg.employee_id};;
  }

  join: application_info_view {
    type:  left_outer
    relationship: one_to_one
    sql_on:  ${ee_company_directory_12_month.greenhouse_application_id} = ${application_info_view.application_id} ;;
  }

  join: jobs_internal_mobility {
    type: left_outer
    relationship: many_to_one
    sql_on: ${jobs_internal_mobility.job_id} = ${application_info_view.job_id} ;;
  }

  join: department_changes {
    type: left_outer
    relationship: many_to_many
    sql_on:  ${ee_company_directory_12_month.employee_id} = ${department_changes.employee_id} ;;
  }

  join: pay_changes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${pay_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }

  join: v_fact_application_requisition_offer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${ee_company_directory_12_month.greenhouse_application_id} = ${v_fact_application_requisition_offer.application_requisition_offer_application_key} ;;
  }

  join: v_dim_application {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_application_key} = ${v_dim_application.application_key};;
  }

  join: v_dim_candidate {
    type: inner
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_candidate_key} = ${v_dim_candidate.candidate_key};;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ee_company_directory_12_month.market_id} = ${market_region_xwalk.market_id} ;;
  }

}
