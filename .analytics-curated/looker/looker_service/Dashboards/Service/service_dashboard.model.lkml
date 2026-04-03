connection: "es_snowflake"

include: "/views/custom_sql/wo_tags_aggregate.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/Dashboards/Service/Views/Analytics/wo_updates.view.lkml"
include: "/views/custom_sql/lead_time.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/INVENTORY/assets_under_warranty.view.lkml"

explore: wo_tags_aggregate {
  case_sensitive: no

  join: work_orders {
    type: inner
    relationship: one_to_one
    sql_on: ${wo_tags_aggregate.work_order_id} = ${work_orders.work_order_id} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${market_region_xwalk.market_id} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.asset_id} = ${assets.asset_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${assets.asset_id};;
  }

  join: assets_under_warranty {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_under_warranty.asset_id} = ${work_orders.asset_id};;
    sql_where: ${assets_under_warranty.currently_under_warranty} = TRUE ;;
  }
}

#MB commented out 5/22/24 ties to no active dashboard/look
# explore: work_orders {}

# explore: lead_time {}
