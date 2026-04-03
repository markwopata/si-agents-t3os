connection: "es_snowflake_analytics"

################### ANALYTICS ###################
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/SERVICE/weekly_work_order_info.view.lkml"
include: "/views/ANALYTICS/SERVICE/category_class_comparison.view.lkml"
include: "/views/ANALYTICS/SERVICE/category_class_mmy_aggregation.view.lkml"
include: "/views/ANALYTICS/SERVICE/daily_work_order_info.view.lkml"
################## ES_WAREHOUSE ##################
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
################## PLATFORM ##################
include: "/views/PLATFORM/v_parts.view.lkml"
################## WORK_ORDERS ##################
include: "/views/WORK_ORDERS/work_order_originators.view.lkml"
################## custom_sql ##################
include: "/views/custom_sql/parts_by_make_model.view.lkml"
include: "/views/custom_sql/wo_ccc_problem_group.view.lkml"
include: "/views/custom_sql/umc_front.view.lkml"
include: "/views/custom_sql/umc_wo_savings.view.lkml"

################### EXPLORES ###################

# Commented out due to low usage on 2026-03-27
# explore: weekly_work_order_info {
#   label: "Failure and Cost Make/Model/Class"
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${weekly_work_order_info.branch_id} = ${market_region_xwalk.market_id} ;;
#   }
#   join: assets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${weekly_work_order_info.asset_id} = ${assets.asset_id} ;;
#   }
#   join: work_order_originators {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${weekly_work_order_info.work_order_id} = ${work_order_originators.work_order_id} ;;
#   }
# }

explore: category_class_comparison {
  label: "Context Class Comparison"
}

explore: category_class_roc {}

explore: daily_work_order_info {
  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${daily_work_order_info.asset_id} = ${assets.asset_id} ;;
  }
  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.inventory_branch_id} = ${markets.market_id} ;;
  }
}

explore: parts_by_make_model {
  join: wo_ccc_problem_group {
    type: left_outer
    relationship: many_to_one
    sql_on: ${parts_by_make_model.work_order_id} = ${wo_ccc_problem_group.work_order_id} ;;
  }
}

explore: umc_wo_savings {}

explore: umc_front {}
