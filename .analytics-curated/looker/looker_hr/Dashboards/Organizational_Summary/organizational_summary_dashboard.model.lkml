connection: "es_snowflake_analytics"


include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/Dashboards/Organizational_Summary/Views/ee_company_directory_12_month.view.lkml"
include: "/Dashboards/Organizational_Summary/Views/job_profiles.view.lkml"
include: "/Dashboards/Organizational_Health/Views/organizational_health_market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/cost_center_to_market_id.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/application_info_view.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/jobs.view.lkml"
include: "/Dashboards/Recruiting_KPIs/Views/locations_by_job_view.view.lkml"
include: "/Dashboards/Organizational_Summary/Views/job_changes.view.lkml"
include: "/Dashboards/Organizational_Summary/Views/pa_market_access.view.lkml"




explore: ee_company_directory_12_month {
  always_join: [pa_market_access]
  case_sensitive: no
  sql_always_where:  ('yes' = {{ _user_attributes['people_analytics_access'] }})
  OR CONTAINS(LOWER(${pa_market_access.market_access_emails}),  LOWER('{{ _user_attributes['email'] }}'))
  OR ('developer' = {{ _user_attributes['department'] }})
  OR ('hr' = {{ _user_attributes['department'] }})
  OR  ('hrbp' = {{ _user_attributes['job_role'] }})
  ;;


  join: pa_market_access {
    type: left_outer
    relationship: many_to_one
    sql_on: ${pa_market_access.market_id} = ${ee_company_directory_12_month.market_id};;
  }

  join: job_profiles {
    type: left_outer
    relationship: one_to_one
    sql_on: ${ee_company_directory_12_month.employee_title}=${job_profiles.job_title};;
  }

  join: market_region_xwalk {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${ee_company_directory_12_month.market_id}=${market_region_xwalk.market_id} ;;
  }

  join: job_changes {
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${job_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }
}

explore: market_region_xwalk {
  case_sensitive: no

  join: cost_center_to_market_id {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${cost_center_to_market_id.market_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: many_to_many
    sql_on: ${cost_center_to_market_id.market_id} = ${company_directory.market_id} ;;
  }
}
