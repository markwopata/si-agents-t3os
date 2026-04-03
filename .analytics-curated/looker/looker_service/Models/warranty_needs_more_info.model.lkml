connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/WARRANTIES/warranty_reviews.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_users_fleet_opt.view.lkml"
include: "/views/PLATFORM/fact_work_order_lines.view.lkml"
include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/TIME_TRACKING/time_entries.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_work_orders_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"


explore:  warranty_reviews{
  case_sensitive: no

  join: dim_users_fleet_opt {
    relationship: one_to_one
    sql_on: ${warranty_reviews.created_by} = ${dim_users_fleet_opt.user_id} ;;
  }

  join:  work_orders{
    relationship: one_to_one
    type: left_outer
    sql_on: ${warranty_reviews.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: wo_tags_aggregate {
    relationship: one_to_one
    sql_on: ${warranty_reviews.work_order_id} = ${wo_tags_aggregate.work_order_id};;
  }

  join:  time_entries_agg{
    relationship: one_to_one
    sql_on:  ${work_orders.work_order_id} = ${time_entries_agg.work_order_id};;
  }

  join:  time_entries{
    relationship: one_to_many
    sql_on:  ${work_orders.work_order_id} = ${time_entries.work_order_id};;
  }

  join: dim_work_orders_fleet_opt {
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${dim_work_orders_fleet_opt.work_order_id};;
  }

  join: fact_work_order_lines {
    relationship: one_to_many
    sql_on: ${dim_work_orders_fleet_opt.work_order_key} = ${fact_work_order_lines.work_order_line_work_order_key};;
  }

  join: dim_assets_fleet_opt {
    relationship: one_to_one
    sql_on: ${dim_work_orders_fleet_opt.work_order_asset_key} = ${dim_assets_fleet_opt.asset_key} ;;
  }

  join:  dim_markets_fleet_opt{
    relationship: one_to_one
    sql_on: ${dim_work_orders_fleet_opt.work_order_market_key} = ${dim_markets_fleet_opt.market_key} ;;
  }

}
