include: "/_standard/people_analytics/looker/cdl_headcount_optimization.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"
include: "/_standard/analytics/payroll/pa_market_access.layer.lkml"



explore: cdl_headcount_optimization {
  label: "CDL Planning New"
  always_join: [pa_market_access]
  sql_always_where:  'yes' = {{ _user_attributes['people_analytics_access'] }}
    OR CONTAINS(${pa_market_access.market_access_email},  LOWER('{{ _user_attributes['email'] }}')) ;;

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${cdl_headcount_optimization.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: pa_market_access {
    type: left_outer
    relationship: one_to_one
    sql_on: ${cdl_headcount_optimization.market_id}::varchar = ${pa_market_access.market_id}::varchar ;;
  }
}
