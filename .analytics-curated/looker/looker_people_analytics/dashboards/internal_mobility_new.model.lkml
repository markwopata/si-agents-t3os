connection: "es_snowflake_pa_c_analytics"

include: "/_standard/internal_mobility/company_directory.view.lkml"
include: "/_standard/custom_sql/job_changes.view.lkml"
include: "/_standard/custom_sql/pay_changes.view.lkml"
include: "/_standard/recruiting_kpis/application_info_view.view.lkml"
include: "/_standard/custom_sql/job_history_internal_mobility.view.lkml"
include: "/_standard/custom_sql/jobs_internal_mobility.view.lkml"
include: "/_standard/custom_sql/department_changes.view.lkml"
include: "/_standard/organizational_summary/ee_company_directory_12_month.view.lkml"
include: "/_standard/recruiting_kpis/disc_gh_ukg.view.lkml"
include: "/_standard/recruiting_kpis/ukg_cost_center_market_id_mapping.view.lkml"
include: "/_standard/organizational_health/planning_financials.view.lkml"
include: "/_standard/custom_sql/hr_greenhouse_link.view.lkml"

# # Select the views that should be a part of this model,
# # and define the joins that connect them together.

explore: company_directory {
  case_sensitive: no

}


explore: job_changes {

  join: disc_gh_ukg {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${job_changes.employee_id} = ${disc_gh_ukg.employee_id};;
  }

  join: ee_company_directory_12_month {
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${ee_company_directory_12_month.employee_id} = ${job_changes.employee_id} ;;
  }

  join: application_info_view{
    type:  left_outer
    relationship: one_to_one
    sql_on:  ${ee_company_directory_12_month.greenhouse_application_id} = ${application_info_view.application_id} ;;
  }

  join: jobs_internal_mobility {
    type: left_outer
    relationship: many_to_one
    sql_on: ${jobs_internal_mobility.job_id} = ${application_info_view.job_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ee_company_directory_12_month.employee_id} = ${company_directory.employee_id};;
  }

}


explore: ukg_cost_center_market_id_mapping {

  join: ee_company_directory_12_month {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${ee_company_directory_12_month.default_cost_centers_full_path} = ${ukg_cost_center_market_id_mapping.cost_centers_full_path} ;;
  }

  join: planning_financials {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${ukg_cost_center_market_id_mapping.intaact_code}= TO_VARCHAR(${planning_financials.mkt_id}) ;;
  }

  join: job_changes {
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${job_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }

  join: pay_changes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${pay_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }
}

explore: department_changes {


  join: ee_company_directory_12_month {
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${ee_company_directory_12_month.employee_id} = ${department_changes.employee_id} ;;
  }

  join: job_changes {
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${job_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }
}


explore: application_info_view {
  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${application_info_view.application_id} = ${company_directory.greenhouse_application_id} ;;
  }

  join: jobs_internal_mobility {
    type: left_outer
    relationship: many_to_one
    sql_on: ${jobs_internal_mobility.job_id} = ${application_info_view.job_id} ;;
  }

  join: job_history_internal_mobility {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.employee_id} = ${job_history_internal_mobility.employee_id}
      and ${company_directory.employee_title} = ${job_history_internal_mobility.current_title};;
  }

}

  # join: hr_greenhouse_link{
  #  type: left_outer
  #  relationship: many_to_one
  #  sql_on: ${hr_greenhouse_link_standard.employee_id} = ${company_directory_standard.employee_id};;
  # }
