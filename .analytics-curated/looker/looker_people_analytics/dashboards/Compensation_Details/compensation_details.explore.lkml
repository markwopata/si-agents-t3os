include: "/_standard/people_analytics/looker/compensation_details.layer.lkml"
include: "/_standard/analytics/public/market_region_xwalk.layer.lkml"
include: "/_base/people_analytics/gl_account.view.lkml"
include: "/_standard/analytics/payroll/pa_market_access.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"

explore: compensation_details{
  from:compensation_details
  case_sensitive: no
  always_join: [pa_market_access]
  sql_always_where:  'yes' = {{ _user_attributes['people_analytics_access'] }}
    OR CONTAINS(${pa_market_access.market_access_email},  LOWER('{{ _user_attributes['email'] }}')) ;;

  join: market_region_xwalk {
    relationship: many_to_one
    type: left_outer
    sql_on: ${compensation_details.intaact_code}::varchar = ${market_region_xwalk.market_id} ::varchar ;;

    }

  join: pa_market_access {
    type: left_outer
    relationship: one_to_many
    sql_on: ${compensation_details.intaact_code}::varchar=  ${pa_market_access.market_id}::varchar ;;
  }

  join: gl_account {
    type: left_outer
    relationship: many_to_one
    sql_on: ${compensation_details.gl_account_no}::varchar=  ${gl_account.accountno}::varchar ;;
  }

  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: ${compensation_details.employee_id}=  ${company_directory.employee_id};;
  }

}
