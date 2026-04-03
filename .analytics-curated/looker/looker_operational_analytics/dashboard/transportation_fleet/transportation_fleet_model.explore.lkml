include: "/_standard/analytics/company_directory.layer.lkml"
include: "/_standard/analytics/financial_utilization.layer.lkml"
include: "/_standard/analytics/int_asset_historical.layer.lkml"
include: "/_base/business_intelligence/fact_operator_assignments.view.lkml"
include: "/_base/es_warehouse/public/company_purchase_orders.view.lkml"
include: "/_standard/es_warehouse/company_purchase_order_line_items.layer.lkml"
include: "/_base/platform/gold/v_assets.view.lkml"
include: "/_base/platform/gold/v_markets.view.lkml"

explore: v_markets {
  label: "Transportation Fleet Model"
  sql_always_where: ${v_markets.market_region} != 0 ;;

  join: v_assets {
    type: inner
    relationship: one_to_many
    sql_on: ${v_markets.market_id} = ${v_assets.asset_market_id} and ${v_assets.asset_active} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_assets.asset_id} = ${company_purchase_order_line_items.asset_id} ;;
  }

  join: company_purchase_orders {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.company_purchase_order_id} = ${company_purchase_orders.company_purchase_order_id} and ${company_purchase_orders.company_purchase_order_type_id} = 3 ;;
  }

  join: company_directory {
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_markets.market_id} = ${company_directory.market_id} ;;
  }

  join: int_asset_historical {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_assets.asset_id} = ${int_asset_historical.asset_id} and ${int_asset_historical.month_end_date} = date_trunc(month,current_date) ;;
  }

  join: financial_utilization {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_assets.asset_id} = ${financial_utilization.asset_id} and ${financial_utilization.rental_branch_id} = ${financial_utilization.market_id} ;;
  }

  join: fact_operator_assignments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_assets.asset_id} = ${fact_operator_assignments.asset_id} and ${fact_operator_assignments.current_assignment} ;;
  }
}
