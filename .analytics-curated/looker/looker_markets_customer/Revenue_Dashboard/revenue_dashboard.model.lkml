connection: "es_snowflake_analytics"
include: "/Revenue_Dashboard/views/*.view.lkml"

include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/equipment_classes.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ANALYTICS/asset_ownership.view.lkml"

explore: market_region_xwalk {}

# explore: financial_utilization {
#   label: "Financial Util aggregate table"
#   description: "This is pulling from a table that is populated nightly."
#
#   join: unit_utilization {
#     type: left_outer # some classes exist in Fin Util that aren't in Unit Util
#     relationship: one_to_one
#     sql_on: ${financial_utilization.asset_id} = ${unit_utilization.asset_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${financial_utilization.rental_branch_id} = ${market_region_xwalk.market_id} ;;
#   }
#
#   join: assets_aggregate {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${financial_utilization.asset_id} = ${assets_aggregate.asset_id} ;;
#   }
# }

explore: v_line_items {
  label: "Line Items View"
  view_label: "Line Items"
  group_label: "Revenue Dashboard"
  case_sensitive: no

  join: asset_type_info {
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_line_items.asset_id} = ${asset_type_info.asset_id} ;;
  }

  join: asset_rental_branch {
    from: market_region_xwalk
    type: inner
    relationship: one_to_one
    sql_on: ${asset_type_info.rental_branch_id} = ${asset_rental_branch.market_id} ;;
  }

  join: line_item_mrx {
    from: market_region_xwalk
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_line_items.branch_id} = ${line_item_mrx.market_id} ;;
  }

  join: line_item_market {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_line_items.branch_id} = ${line_item_market.market_id} ;;
  }

}

explore: asset_fin_util {
  label: "Financial Utilization"
  view_label: "Financial Utilization"
  group_label: "Revenue Dashboard"

  join: asset_type_info {
    type: inner
    relationship: one_to_one
    sql_on: ${asset_fin_util.asset_id} = ${asset_type_info.asset_id} ;;
  }

  join: asset_rental_branch {
    from: market_region_xwalk
    type: inner
    relationship: one_to_one
    sql_on: ${asset_type_info.rental_branch_id} = ${asset_rental_branch.market_id} ;;
  }

}

explore: historical_utilization {

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_utilization.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: asset_company {
    from: companies_ext
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_utilization.company_id} = ${asset_company.company_id} ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${historical_utilization.asset_id} = ${assets_aggregate.asset_id} ;;
  }

  ### This join allows you to pull in all assets even though they have 0 utilization
  join: all_assets {
    from: assets_aggregate
    type: full_outer
    relationship: one_to_many
    sql_on: ${all_assets.equipment_class_id} = ${assets_aggregate.equipment_class_id};;
  }

  ### Joining this in for asset ownership
  join: asset_ownership {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_ownership.asset_id} = ${all_assets.asset_id} ;;
  }

  join: equipment_classes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.equipment_class_id} = ${equipment_classes.equipment_class_id} ;;
  }

  join: asset_type_info {
    type: left_outer
    relationship: one_to_one
    sql_on: ${historical_utilization.asset_id} = ${asset_type_info.asset_id} ;;
  }

  join: asset_fin_util {
    type: inner
    relationship: one_to_many
    sql_on: ${asset_fin_util.asset_id} = ${historical_utilization.asset_id} ;;
  }
}
