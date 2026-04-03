connection: "es_snowflake"

include: "/views/SCD/scd_asset_rsp.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/companies.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/asset_physical.view.lkml"
include: "/Dashboards/Asset_Market_History/views/*.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"


explore: asset_market_history {
  from: scd_union

  join: markets {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_market_history.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: market_owner {
    from: companies
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.company_id} = ${market_owner.company_id} ;;
  }

  join: asset_details {
    from: asset_physical
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_market_history.asset_id} = ${asset_details.asset_id} ;;
  }

  join: current_asset_owner {
    from: companies
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_details.company_id} = ${current_asset_owner.company_id} ;;
  }

  join: transferred_by {
    from: users
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_market_history.user_id} = ${transferred_by.user_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_one
    sql_on: try_to_number(${transferred_by.employee_id}) = ${company_directory.employee_id} ;;
  }

  join: user_market {
    from: markets
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.market_id} = ${user_market.market_id} and ${user_market.company_id} = 1854 ;;
  }

}
