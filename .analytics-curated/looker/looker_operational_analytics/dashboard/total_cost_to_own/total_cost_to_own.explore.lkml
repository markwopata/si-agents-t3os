include: "/_base/fleet_optimization/dim_assets_fleet_opt.view.lkml"
include: "/_base/fleet_optimization/dim_timeframe_windows_historic.view.lkml"
include: "/_standard/fleet_optimization/dim_markets_fleet_opt.layer.lkml"
include: "/_standard/fleet_optimization/fact_total_cost_to_own.layer.lkml"
include: "/_standard/fleet_optimization/fact_total_cost_to_own_by_asset_market_month.layer.lkml"

explore:  dim_markets_fleet_opt {
  label: "Total Cost to Own Model"
  sql_always_where: ${reporting_market} ;;

  join: fact_total_cost_to_own_by_asset_market_month {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_markets_fleet_opt.market_key} = ${fact_total_cost_to_own_by_asset_market_month.market_key} ;;
  }

  join: fact_total_cost_to_own {
    type: left_outer
    relationship: one_to_many
    sql_on: ${fact_total_cost_to_own_by_asset_market_month.asset_month_key} = ${fact_total_cost_to_own.asset_month_key} ;;
  }

  join: dim_assets_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_total_cost_to_own_by_asset_market_month.asset_key} = ${dim_assets_fleet_opt.asset_key} ;;
  }

  join: dim_timeframe_windows_historic {
    type: left_outer
    relationship: many_to_one
    sql_on: ${fact_total_cost_to_own_by_asset_market_month.tf_key} = ${dim_timeframe_windows_historic.tf_key} ;;
  }
}
