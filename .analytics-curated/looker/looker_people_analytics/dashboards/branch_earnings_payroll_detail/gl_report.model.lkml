## access_grant: secured_payroll_access {
 ## user_attribute: department
 ## allowed_values: ["GMs", "God View", "HR"]
##}



connection: "es_snowflake_pa_c_analytics"

include: "/dashboards/branch_earnings_payroll_detail/gl_report.explore.lkml"
