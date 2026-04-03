connection: "es_snowflake_analytics"

include: "/Dashboards/Organizational_Health/Views/Planning_Financials.view.lkml"
include: "/Dashboards/Organizational_Health/Views/market_headcount.view.lkml"
include: "/Dashboards/Organizational_Health/Views/organizational_health_jobs.view.lkml"
include: "/Dashboards/Organizational_Health/Views/organizational_health_ee_company_directory_12_month.view.lkml"
include: "/Dashboards/Organizational_Summary/Views/job_profiles.view.lkml"
include: "/Dashboards/Organizational_Health/Views/organizational_health_market_region_xwalk.view.lkml"
include: "/Dashboards/Organizational_Health/Views/gm_position_dates.view.lkml"
include: "/views/ANALYTICS/disc_master.view.lkml"
include: "/Dashboards/Organizational_Health/Views/hr_greenhouse_link.view.lkml"

explore: planning_financials {
  case_sensitive: no

}


explore: market_headcount{

  join: planning_financials {
    type: left_outer
    relationship: one_to_one
    sql_on:${market_headcount.market_id} = ${planning_financials.mkt_id};;
  }

  join: market_region_xwalk {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${market_headcount.market_id}=${market_region_xwalk.market_id} ;;
  }

join: gm_position_dates {
  type:  left_outer
  relationship:  one_to_one
  sql_on: ${planning_financials.employee_id} = ${gm_position_dates.employee_id} ;;
}

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    # sql_on: ${company_directory.work_email} = ${disc_master.email_address}
    #           or ${company_directory.personal_email} = ${disc_master.email_address};;
    sql_on: ${planning_financials.work_email} = ${disc_master.email_address}
      or ${planning_financials.personal_email} = ${disc_master.email_address};;
  }

  join: hr_greenhouse_link {
    type: left_outer
    relationship: one_to_one
    sql_on: ${planning_financials.employee_id} = ${hr_greenhouse_link.employee_id} ;;
  }
}


explore:   organizational_health_ee_company_directory_12_month{

join: organizational_health_jobs {
  type:  left_outer
  relationship:  many_to_many
  sql_on:  ${organizational_health_ee_company_directory_12_month.job_family} = ${organizational_health_jobs.job_family}
  AND ${organizational_health_ee_company_directory_12_month.region2}= ${organizational_health_jobs.region}
  AND ${organizational_health_ee_company_directory_12_month.district} = ${organizational_health_jobs.district};;
}

  join: market_region_xwalk {
    type:  left_outer
    relationship: many_to_one
    sql_on:  ${organizational_health_ee_company_directory_12_month.market_id}=${market_region_xwalk.market_id} ;;
  }


}
