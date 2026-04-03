#connection: "es_snowflake_analytics"
connection: "es_snowflake"

include: "/views/ES_WAREHOUSE/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/custom_sql/3c_clusters.view.lkml"
include: "/views/custom_sql/assets_under_warranty.view.lkml"
include: "/views/custom_sql/daily_rev_calculation.view.lkml"
include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/work_order_user_assignments.view.lkml"
include: "/views/ES_WAREHOUSE/users.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/custom_sql/district_subcategory_ready_to_rent.view.lkml"
include: "/views/custom_sql/expected_lost_revenue_on_work_orders.view.lkml"

explore: work_orders {

  #always_filter: {
  #filters: [asset_nbv_all_owners.rental_status: "Hard Down, Soft Down"]
  #filters: [work_orders.work_order_status_name: "Open"]
  #filters: [work_orders.archived_date: "NULL"]
  #filters: [work_orders.work_order_type_id: "1"]}

  join: assets_aggregate {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.asset_id} = ${assets_aggregate.asset_id} ;;
  }
  join: dim_assets_fleet_opt {
    type: inner
    relationship: one_to_one
    sql_on: ${dim_assets_fleet_opt.asset_id} = ${assets_aggregate.asset_id} ;;
  }
  join: assets_under_warranty {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets_under_warranty.asset_id} ;;
  }
  join: 3c_clusters {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${3c_clusters.work_order_id} ;;
  }
  join: wo_tags_aggregate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_orders.work_order_id} = ${wo_tags_aggregate.work_order_id} ;;
  }
  join: market_region_xwalk {
    type: inner
    relationship: one_to_one
    sql_on:  ${market_region_xwalk.market_id} = ${work_orders.branch_id} ;;
  }
  join: district_subcategory_ready_to_rent {
    type: left_outer
    relationship: many_to_one
    sql_on: ${district_subcategory_ready_to_rent.district} = ${market_region_xwalk.district}
      and ${district_subcategory_ready_to_rent.subcategory_or_class} = iff(${dim_assets_fleet_opt.asset_equipment_subcategory_name} <> 'Unrecognized Equipment Subcategory Name', ${dim_assets_fleet_opt.asset_equipment_subcategory_name}, ${dim_assets_fleet_opt.asset_equipment_class_name});;
  }

  join: asset_status_key_values {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.asset_id} = ${asset_status_key_values.asset_id} ;;
  }

  join: markets {
    type: inner
    relationship: one_to_one
    sql_on: ${work_orders.branch_id} = ${markets.market_id} ;;
  }

  join: daily_rev_calculation {
    type: left_outer
    relationship: many_to_one
    sql_on: ${daily_rev_calculation.equipment_class_id} = ${assets_aggregate.equipment_class_id}
      and ${daily_rev_calculation.district} = ${market_region_xwalk.district};;
  }

  join: estimated_lost_revenue  {
    type: left_outer
    relationship: one_to_one
    sql_on: ${estimated_lost_revenue.work_order_id} = ${work_orders.work_order_id} ;;
  }
## under construction
  join: work_order_user_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_orders.work_order_id} = ${work_order_user_assignments.work_order_id_current} ;;
  }
  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_user_assignments.user_id} = ${users.user_id} ;;
  }

}
