connection: "es_snowflake_analytics"

include: "/Dashboards/Employee_Vehicle_Assignment/Views/user_asset_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/ANALYTICS/company_directory.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/Dashboards/Employee_Vehicle_Assignment/Views/scd_asset_driver.view.lkml"
include: "/views/ANALYTICS/asset_physical.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"


explore: employee_vehicle_assignments {
  from: asset_physical

  join: user_asset_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${employee_vehicle_assignments.asset_id} = ${user_asset_assignments.asset_id} ;;
  }

  join: users {
    type: left_outer
    relationship: one_to_many
    # company_id needs to be specified here or you'll pull in external users that have matching employee_ids
    sql_on: ${user_asset_assignments.user_id} = ${users.user_id} ;;
  }

  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: TRY_TO_NUMBER(${users.employee_id}) = ${company_directory.employee_id} ;;
  }

  join: employee_market {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id} = ${employee_market.market_id} ;;
  }

  join: asset_market {
    from: markets
    type: inner
    relationship: many_to_one
    sql_on: ${employee_vehicle_assignments.asset_market} = ${asset_market.market_id} ;;
  }
}
