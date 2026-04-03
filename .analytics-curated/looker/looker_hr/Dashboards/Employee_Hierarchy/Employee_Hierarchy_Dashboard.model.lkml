connection: "es_snowflake_analytics"


include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/Dashboards/Employee_Hierarchy/employee_manager_hierarchy.view.lkml"
include: "/views/custom_sql/job_history_internal_mobility.view.lkml"

explore: company_directory {
  case_sensitive: no

  join: employee_manager_hierarchy {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.employee_id} = ${employee_manager_hierarchy.employee_id};;
  }

  join: job_history_internal_mobility {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.employee_id} = ${job_history_internal_mobility.employee_id}
    AND  ${company_directory.employee_title} = ${job_history_internal_mobility.current_title};;
  }


}
