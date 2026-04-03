connection: "es_snowflake_analytics"


include: "/Dashboards/Recruiting_KPIs/Views/hires_info_view.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/requisitions.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/location_region_xwalk.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/job_family_xwalk.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/jobs.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/job_office.view.lkml"
include: "/views/ANALYTICS/job_opening.view.lkml"
include: "/views/ANALYTICS/candidate_info_view.view.lkml"
include: "/views/GREENHOUSE/job_department.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/locations_by_job_view.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/location_hierarchy.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/department_by_job.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/stages_info_view.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/application_info_view.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/job_pipeline.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/hiring_managers.view.lkml"
include: "/views/custom_sql/user_recruiters.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/sourcers.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/job_name_job_family_xwalk.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/site_forecast.view.lkml"
include: "/Dashboards/Organizational_Health/Views/job_families.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/disc_gh_ukg.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/date_holder.view.lkml"
include: "/Dashboards/Organizational_Summary/Views/ee_company_directory_12_month.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/scorecard.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/scorecard_attribute.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/unicorns.view.lkml"
include: "/views/custom_sql/job_changes.view.lkml"
include: "/Dashboards/Organizational_Summary/Views/ee_company_directory_12_month.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/offer.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/application_history.view.lkml"
include: "/views/GREENHOUSE/department.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/disc_master.view.lkml"
include: "/views/GREENHOUSE/application.view.lkml"
include: "/views/GREENHOUSE/source.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/job_stage.view.lkml"

# explore: requisitions { --MB comment out 10-10-23 due to inactivity

#   join: location_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${requisitions.location}=${location_region_xwalk.location};;
#     }

#   join: job_family_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${requisitions.job_name}=${job_family_xwalk.job_name};;
#   }


# }

explore: job_changes {

  join: disc_gh_ukg {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${job_changes.employee_id}=${disc_gh_ukg.employee_id};;
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

  join: department_by_job {
    type:  left_outer
    relationship:  many_to_one
    sql_on: ${application_info_view.job_id} = ${department_by_job.job_id} ;;
  }

  join: user_recruiters {
    type: left_outer
    relationship: one_to_one
    sql_on: ${department_by_job.job_id} = ${user_recruiters.job_id} ;;
  }

  join: jobs {
    type: left_outer
    relationship: one_to_one
    sql_on: ${department_by_job.job_id} = ${jobs.job_id};;
  }

  join: offer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${application_info_view.application_id} = ${offer.application_id} ;;
  }

}
explore: jobs {

  join: job_family_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${jobs.job_name} =${job_family_xwalk.job_name};;
  }

  join: job_department {
    type: left_outer
    relationship: one_to_one
    sql_on: ${jobs.job_id} =${job_department.job_id};;
  }

  join:  locations_by_job_view {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${jobs.job_id} = ${locations_by_job_view.job_id} ;;
  }

  join: department_by_job {
    type:  left_outer
    relationship:  one_to_one
    sql_on:  ${jobs.job_id} = ${department_by_job.job_id};;
  }

  join: job_pipeline {
    type:  left_outer
    relationship:  one_to_one
    sql_on:   ${jobs.job_id}  = ${job_pipeline.job_id};;
  }

  join: hiring_managers {
    type:  left_outer
    relationship:  one_to_one
    sql_on:   ${jobs.job_id}  = ${hiring_managers.job_id};;
  }

  join: user_recruiters {
    type: left_outer
    relationship: one_to_one
    sql_on: ${jobs.job_id} = ${user_recruiters.job_id} ;;
  }

  join: sourcers {
    type:  left_outer
    relationship:  one_to_one
    sql_on:   ${jobs.job_id}  = ${sourcers.job_id};;
  }

  join: job_name_job_family_xwalk{
    type:  left_outer
    relationship:  one_to_one
    sql_on:   ${jobs.job_name}  = ${job_name_job_family_xwalk.job_name};;
  }

  join: department {
    type: left_outer
    relationship: one_to_one
    sql_on: ${job_department.department_id} =${department.id};;
  }

  join: job_office {
    type: left_outer
    relationship: one_to_one
    sql_on: ${job_office.job_id} = ${jobs.job_id} ;;
  }

  join: location_hierarchy {
    type: left_outer
    relationship: one_to_one
    sql_on: ${location_hierarchy.location_id} = ${job_office.office_id} ;;
  }
}

explore: stages_info_view{
  join: jobs {
  type:  left_outer
  relationship:  many_to_one
  sql_on:  ${stages_info_view.job_id} = ${jobs.job_id} ;;
  }


  join: job_family_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${stages_info_view.job_name} =${job_family_xwalk.job_name};;
  }

  join: job_department {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${stages_info_view.job_id}  =${job_department.job_id};;
  }

  join:  locations_by_job_view {
    type:  left_outer
    relationship:  one_to_one
    sql_on:   ${stages_info_view.job_id}  = ${locations_by_job_view.job_id} ;;
  }

  join: department_by_job {
    type:  left_outer
    relationship:  one_to_one
    sql_on:   ${stages_info_view.job_id}  = ${department_by_job.job_id};;
  }

  join: job_pipeline {
    type:  left_outer
    relationship:  one_to_one
    sql_on:   ${jobs.job_id}  = ${job_pipeline.job_id};;
  }

  join: application_info_view {
    type: left_outer
    relationship: one_to_one
    sql_on: ${application_info_view.application_id} = ${stages_info_view.application_id} ;;

  }


}

explore: application_info_view{
  join: jobs {
    type:  left_outer
    relationship:  many_to_one
    sql_on:  ${application_info_view.job_id} = ${jobs.job_id} ;;
  }


  join: job_family_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${application_info_view.job_name} =${job_family_xwalk.job_name};;
  }

  join: job_department {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${application_info_view.job_id}  =${job_department.job_id};;
  }

  join:  locations_by_job_view {
    type:  left_outer
    relationship:  many_to_one
    sql_on:   ${application_info_view.job_id}  = ${locations_by_job_view.job_id} ;;
  }

  join: department_by_job {
    type:  left_outer
    relationship:  many_to_one
    sql_on:  ${application_info_view.job_id} = ${department_by_job.job_id};;
  }

  join: disc_gh_ukg {
    type: left_outer
    relationship:  many_to_one
    sql_on:  ${application_info_view.application_id}=${disc_gh_ukg.external_id} ;;
  }

  join: disc_master {
    type: left_outer
    relationship:  one_to_one
    sql_on:  ${candidate_info_view.email_address} = ${disc_master.email_address} ;;
  }

  join: ee_company_directory_12_month {
    type: left_outer
    relationship: one_to_one
    sql_on:  ${application_info_view.application_id}=${ee_company_directory_12_month.greenhouse_application_id} ;;
  }

  join: date_holder {
    type: cross
    relationship: many_to_many
    sql_on:  1=1 ;;
  }

  join: stages_info_view {
    type:  left_outer
    relationship: one_to_one
    sql_on:  ${application_info_view.application_id}=${stages_info_view.application_id} ;;
  }

  join: user_recruiters {
    type: left_outer
    relationship: one_to_one
    sql_on: ${application_info_view.job_id} = ${user_recruiters.job_id} ;;
  }

  join: scorecard {
    type: left_outer
    relationship: one_to_many
    sql_on: ${application_info_view.application_id} = ${scorecard.application_id} ;;
  }

  join: scorecard_attribute {
    type: left_outer
    relationship: one_to_one
    sql_on: ${scorecard.id} = ${scorecard_attribute.scorecard_id} ;;
  }

  join: unicorns {
    type: left_outer
    relationship:  many_to_one
    sql_on: ${application_info_view.candidate_id} = ${unicorns.candidate_id} ;;
  }

  join: offer {
    type: left_outer
    relationship:  one_to_one
    sql_on: ${application_info_view.application_id} = ${offer.application_id} ;;
  }

  join: application_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${application_info_view.application_id} = ${application_history.application_id} ;;
  }

  join: department {
    type: left_outer
    relationship: one_to_one
    sql_on: ${job_department.department_id} =${department.id};;
  }

  join: job_changes {
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${job_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }

  join: job_stage {
    type: left_outer
    relationship: many_to_one
    sql_on: ${application_history.new_stage_id} = ${job_stage.id} ;;
  }

  join: job_office {
    type: left_outer
    relationship: one_to_one
    sql_on: ${job_office.job_id} = ${application_info_view.job_id} ;;
  }

  join: location_hierarchy {
    type: left_outer
    relationship: one_to_one
    sql_on: ${location_hierarchy.location_id} = ${job_office.office_id} ;;
  }

  join: candidate_info_view {
    type: left_outer
    relationship: one_to_one
    sql_on: ${candidate_info_view.candidate_id} = ${application_info_view.candidate_id} ;;
  }
}

explore: site_forecast{
  join: job_families {
    type:  cross
    relationship: many_to_many
    sql_on: 1 = 1;;
  }

    }
