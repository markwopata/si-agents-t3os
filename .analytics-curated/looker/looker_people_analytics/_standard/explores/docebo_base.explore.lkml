include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/people_analytics/docebo/users.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"
include: "/_standard/es_warehouse/public/markets.layer.lkml"


explore: company_directory {
  label: "Docebo Base Explore"
  case_sensitive: no


  join: users {
    type: inner
    relationship: one_to_one
    sql_on: to_varchar(${company_directory.employee_id}) = ${users.employee_id};;

  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

}
