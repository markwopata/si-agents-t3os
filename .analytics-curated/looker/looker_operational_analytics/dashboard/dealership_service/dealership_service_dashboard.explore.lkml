include: "/_base/fleet_optimization/dim_asset_company_pit.view.lkml"
include: "/_base/fleet_optimization/dim_assets_fleet_opt.view.lkml"
include: "/_base/fleet_optimization/dim_companies_fleet_opt.view.lkml"
include: "/_base/fleet_optimization/dim_markets_fleet_opt.view.lkml"
include: "/_base/fleet_optimization/dim_work_orders_fleet_opt.view.lkml"
include: "/_base/fleet_optimization/dim_parts_fleet_opt.view.lkml"
include: "/_base/procurement/public/price_list_entries.view.lkml"
include: "/_base/es_warehouse/work_orders/company_tags.view.lkml"
include: "/_base/es_warehouse/work_orders/work_order_company_tags.view.lkml"
include: "/_standard/es_warehouse/time_entries.layer.lkml"
include: "/_standard/procurement/purchase_order_line_items.layer.lkml"
include: "/_standard/custom_sql/work_order_parts.view.lkml"
include: "/_standard/custom_sql/work_order_invoice_link.view.lkml"
include: "/_standard/es_warehouse/line_items.layer.lkml"

explore: dim_work_orders_fleet_opt {
  label: "Dealership Service"
  sql_always_where: ${work_order_date_archived_date} is null
    and ${dim_assets_fleet_opt.asset_id} != -1
    and ${dim_markets_fleet_opt.market_company_id} = 1854
    and ${dim_markets_fleet_opt.market_active};;

  join: dim_markets_fleet_opt {
    type: inner
    relationship: many_to_one
    sql_on: ${dim_work_orders_fleet_opt.work_order_market_id} = ${dim_markets_fleet_opt.market_id} ;;
  }

  join: dim_assets_fleet_opt {
    type: inner
    relationship: many_to_one
    sql_on: ${dim_work_orders_fleet_opt.work_order_asset_id} = ${dim_assets_fleet_opt.asset_id} ;;
  }

  join: purchase_order_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_work_orders_fleet_opt.work_order_id} = ${purchase_order_line_items.allocation_id}
      and ${purchase_order_line_items.allocation_type} = 'WORK_ORDER'
      and ${purchase_order_line_items.date_archived_date} is null
      and ${purchase_order_line_items.total_accepted} > 0
      and ${purchase_order_line_items.item_id} in ('d6fd484c-da57-4e62-a2c5-9a2d0202ffdb','cb7d6b8b-3efd-4d6c-a300-c79fa9bd8d9b');;
  }

  join: work_order_parts {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_work_orders_fleet_opt.work_order_id} = ${work_order_parts.work_order_id} ;;
  }

  join: time_entries {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_work_orders_fleet_opt.work_order_id} = ${time_entries.work_order_id} ;;
  }

  join: work_order_to_invoice {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_work_orders_fleet_opt.work_order_id} = ${work_order_to_invoice.work_order_id} ;;
  }

  join: line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${work_order_to_invoice.invoice_id} = ${line_items.invoice_id} ;;
  }

  join: dim_asset_company_pit {
    type: inner
    relationship: one_to_one
    sql_on: ${dim_work_orders_fleet_opt.work_order_asset_id} = ${dim_asset_company_pit.asset_id} and ${dim_work_orders_fleet_opt.work_order_created_raw} between ${dim_asset_company_pit.company_ownership_start_raw} and ${dim_asset_company_pit.company_ownership_end_raw} ;;
  }

  join: dim_companies_fleet_opt {
    type: inner
    relationship: one_to_one
    sql_on: ${dim_asset_company_pit.current_company_id} = ${dim_companies_fleet_opt.company_id} ;;
  }

  join: dim_parts_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${work_order_parts.part_id} = ${dim_parts_fleet_opt.part_id} ;;
  }

  join: price_list_entries {
    type: left_outer
    relationship: one_to_one
    sql_on: ${dim_parts_fleet_opt.item_id} = ${price_list_entries.item_id} ;;
  }

  join: work_order_company_tags {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_work_orders_fleet_opt.work_order_id} = ${work_order_company_tags.work_order_id} and ${work_order_company_tags.deleted_raw} is null ;;
  }

  join: company_tags {
    type: left_outer
    relationship: one_to_one
    sql_on: ${work_order_company_tags.company_tag_id} = ${company_tags.company_tag_id} ;;
  }
}
