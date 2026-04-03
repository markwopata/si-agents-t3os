include: "/_standard/people_analytics/greenhouse/v_fact_gm_onboarding.view"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"

explore: v_fact_gm_onboarding {
  description: "GM onboarding lifecycle tracking"

  join: company_directory {            # make sure this matches the `view:` name inside the included file
    type: left_outer
    sql_on: LOWER(TRIM(${v_fact_gm_onboarding.gm_email})) = LOWER(TRIM(${company_directory.work_email})) ;;
    relationship: many_to_one
  }

    join: market_region_xwalk {
      type: left_outer
      relationship: one_to_one
      sql_on: ${v_fact_gm_onboarding.market_name} = ${market_region_xwalk.market_name} ;;
    }

}
