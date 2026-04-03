connection: "es_snowflake_analytics"

include: "/views/custom_sql/asset_engines.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/es_companies.view.lkml"
include: "/Dashboards/Engines/engine_serial_plate_added_process.view.lkml"

explore: assets {
  from: dim_assets_fleet_opt
  label: "Asset Engine Data"
  sql_always_where: (${es_companies.company_id} is not null or ${asset_own_flag}) ;;

  join: es_companies {
    type: left_outer
    relationship: many_to_one
    sql_on:  ${assets.asset_company_id}=${es_companies.company_id} and ${es_companies.owned} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_market_coalesce} = ${market_region_xwalk.market_id} ;;
  }

  join: asset_engines {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id}=${asset_engines.asset_id} ;;
  }

  join: engine_serial_plate_added_process {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id}=${engine_serial_plate_added_process.asset_id} ;;
  }
}
