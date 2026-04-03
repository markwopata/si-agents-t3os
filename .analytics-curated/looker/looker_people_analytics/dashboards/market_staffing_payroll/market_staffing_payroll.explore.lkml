include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"
include: "/_standard/analytics/gs/revmodel_market_rollout_conservative.layer.lkml"
include: "/_standard/people_analytics/looker/wfp_headcount_markets.layer.lkml"
include: "/_standard/people_analytics/looker/geozones.layer.lkml"
include: "/_standard/people_analytics/looker/accounting_payroll_dashboard.layer.lkml"


view: +wfp_headcount_markets {

}

explore: wfp_headcount_markets {



}


explore: geozones {



}

explore: accounting_payroll_dashboard {


  join: market_region_xwalk {
    relationship: many_to_one
    type: left_outer
    sql_on: ${accounting_payroll_dashboard.intaact_code}::varchar = ${market_region_xwalk.market_id}::varchar ;;
  }


}
