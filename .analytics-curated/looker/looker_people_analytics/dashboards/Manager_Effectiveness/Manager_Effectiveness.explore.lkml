
include: "/_standard/internal_mobility/company_directory.view.lkml"
include: "/_standard/custom_sql/job_changes.view.lkml"
include: "/_standard/custom_sql/pay_changes.view.lkml"
include: "/_standard/recruiting_kpis/application_info_view.view.lkml"
include: "/_standard/custom_sql/job_history_internal_mobility.view.lkml"
include: "/_standard/custom_sql/jobs_internal_mobility.view.lkml"
include: "/_standard/custom_sql/department_changes.view.lkml"
include: "/_base/analytics/public/disc_master.view.lkml"
include: "/_standard/organizational_summary/ee_company_directory_12_month.view.lkml"
include: "/_standard/recruiting_kpis/disc_gh_ukg.view.lkml"
include: "/_standard/recruiting_kpis/ukg_cost_center_market_id_mapping.view.lkml"
include: "/_standard/organizational_health/planning_financials.view.lkml"
include: "/_standard/custom_sql/hr_greenhouse_link.view.lkml"
include: "/_standard/people_analytics/looker/employee_photos.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_requisition_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"
include: "/_standard/people_analytics/looker/manager_perception.layer.lkml"

view: +ee_company_directory_12_month {

    dimension: position_tenure {

      description: "Time in Position."
      type: number
      sql: datediff(month,${ee_company_directory_12_month.date_position_effective2_date},CURRENT_DATE);;
      value_format: "0"

    }

  dimension: full_name_with_standard_links {

    description: "full_name_with_standard_links."
    type: string
    sql: concat(${TABLE}."FIRST_NAME",' ',${TABLE}."LAST_NAME");;
    link: {
      label: "Greenhouse Application"
      url: ""
    }
    link: {
      label: "DISC Link (Environment {{disc_master.environment_style}})"
      url: "https://www.discoveryreport.com/v/{{disc_code._value}}"
    }
  }

  measure: avg_position_tenure {
    type: number
    sql: round(sum(${ee_company_directory_12_month.position_tenure})/count(distinct ${ee_company_directory_12_month.employee_id}),0);;
    value_format: "0"
  }

  measure: number_markets{
    type: count_distinct
    sql: ${ee_company_directory_12_month.market_id};;
    value_format: "0"
  }
  measure: number_people_managers{
    type: count_distinct
    sql: ${ee_company_directory_12_month.direct_manager_employee_id};;
    value_format: "0"
  }
  measure: span_of_control{
    type: number
    sql:   ${ee_company_directory_12_month.headcount}/ count( distinct ${ee_company_directory_12_month.direct_manager_employee_id}) ;;
    value_format: "0"
  }

  measure: fav_percent_great_job_managing_work{
    type: number
    sql:  case when ${manager_perception.resp_great_job_managing_the_work}>4 THEN ${manager_perception.fav_great_job_people_management}/ ${manager_perception.resp_great_job_people_management} else null end;;
    value_format: "0.0%"
  }

  measure: fav_percent_great_job_managing_people{
    type: number
    sql:  case when ${manager_perception.resp_great_job_people_management}>4 THEN  ${manager_perception.fav_great_job_managing_the_work}/ ${manager_perception.resp_great_job_managing_the_work} else null end ;;
    value_format: "0.0%"
  }

  measure: fav_percent_trust_manager {
    type: number
    sql:   case when ${manager_perception.resp_trust_manager}>4 THEN  ${manager_perception.fav_trust_manager}/ ${manager_perception.resp_trust_manager} else null end;;
    value_format: "0.0%"
  }

  measure: fav_percent_manager_available_address_needs{
    type: number
    sql:  case when ${manager_perception.resp_manager_available_to_address_needs}>4 THEN   ${manager_perception.fav_manager_available_to_address_needs}/ ${manager_perception.resp_manager_available_to_address_needs} else null end;;
    value_format: "0.0%"
  }

  measure: employee_card {
    group_label: "Employee Card"
    label: " "
    type: number
    sql: ${ee_company_directory_12_month.hire_type};;

    html:

       <table style="font-family: Arial; font-size: 14px; color: #323232; width: 100%">


     <tr style="background-color: ##f9f9f6;" ;

      >
      <td colspan="1" style="text-align: center; font-size: 18px" ;
      >
      {{ee_company_directory_12_month.full_name_with_standard_links}}<br></br></td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      {{ee_company_directory_12_month.location}}
      </td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      Hire Type: {{ee_company_directory_12_month.hire_type}}
      </td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      Months in Role: {{ee_company_directory_12_month.position_tenure}} months
      </td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      Scorecard: {{v_dim_candidate.candidate_custom_scorecard_score}}
      </td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      DISC: {{disc_master.environment_style}} Environment
      </td>
      </tr>


      </table> ;;

  }

  measure: employees_card {
    group_label: "Employees Card"
    label: " "
    type: number
    sql: ${ee_company_directory_12_month.headcount};;
    value_format:"0"
    html:

       <table style="font-family: Arial; font-size: 14px; color: #323232; width: 100%">


      <tr style="background-color: #f9f9f6;" ;

      >
      <td colspan="1" style="text-align: center; font-size: 18px" ;
      >Oversees</td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      Number of Locations: {{ee_company_directory_12_month.number_markets}}
      </td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      Number of Employees: {{ee_company_directory_12_month.count_unique_eeid}}
      </td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      Number of People Managers: {{ee_company_directory_12_month.number_people_managers}}
      </td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      Span: {{ee_company_directory_12_month.span_of_control}} emps: 1 manager
      </td>
      </tr>
      <tr style="background-color: #f9f9f6;">
      <td colspan="1" style="text-align: left;">
      Avg Employee Tenure: {{ee_company_directory_12_month.avg_position_tenure}} months
      </td>
      </tr>


      </table> ;;

  }

}

view: +employee_photos {


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

  join: employee_photos {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ee_company_directory_12_month.employee_id} = ${employee_photos.employee_id} ;;
  }

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${disc_master.disc_code} =  ${disc_gh_ukg.disc_code} ;;
  }

  join: v_dim_application {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ee_company_directory_12_month.greenhouse_application_id}  = ${v_dim_application.application_id}   ;;
  }

  join: v_fact_application_requisition_offer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_application_key}=${v_dim_application.application_id}  ;;
  }

  join: v_dim_candidate {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${v_dim_candidate.candidate_id} = ${v_fact_application_requisition_offer.application_requisition_offer_candidate_key} ;;
  }

  join: manager_perception {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${ee_company_directory_12_month.employee_id} = ${manager_perception.manager_eid} ;;
  }


}
