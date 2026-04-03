connection: "es_snowflake_analytics"

##include: "/views/*.view.lkml"                # include all views in the views/ folder in this project
include: "/views/WORK_ORDERS/work_orders.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/ANALYTICS/dot_inspections.view.lkml"
include: "/views/ES_WAREHOUSE/scd_asset_msp.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/custom_sql/transportation_assets.view.lkml"
include: "/views/ES_WAREHOUSE/company_purchase_order_line_items.view.lkml"



explore: dot_inspections{
  case_sensitive: no
  group_label: "DOT Data"
  label: "DOT Inspections with Market"

  join: assets_aggregate {
    type: inner
    relationship: one_to_one
    sql_on:  ${dot_inspections.vehicle_unit_1_vin} = ${assets_aggregate.vin}
      ;;
  }

  join: work_orders {
    type:  inner
    relationship: one_to_one
    sql_on: ${assets_aggregate.asset_id} = ${work_orders.asset_id}
          ;;
  }

  join: scd_asset_msp {
    type: inner
    relationship: many_to_one
    sql_on: ${work_orders.branch_id} = ${scd_asset_msp.service_branch_id}
      AND ${work_orders.asset_id} = ${scd_asset_msp.asset_id};;
  }

  join: markets {
    type: inner
    relationship: one_to_one
    sql_on: ${scd_asset_msp.service_branch_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: one_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: transportation_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${transportation_assets.asset_id} ;;
  }

  join: company_purchase_order_line_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_purchase_order_line_items.asset_id} = ${assets_aggregate.asset_id} ;;
  }

}
