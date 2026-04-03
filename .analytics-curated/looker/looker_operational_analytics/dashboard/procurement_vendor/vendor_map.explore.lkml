include: "/_base/fleet_optimization/dim_vendors.view.lkml"
include: "/_base/fleet_optimization/dim_markets_fleet_opt.view.lkml"
include: "/_standard/procurement/purchase_orders.layer.lkml"
include: "/_base/procurement/public/purchase_order_line_items.view.lkml"
include: "/_base/es_warehouse/purchases/entity_vendor_settings.view.lkml"
include: "/_standard/fleet_optimization/dim_locations_fleet_opt.layer.lkml"
include: "/_base/fleet_optimization/dim_dates_fleet_opt.view.lkml"
include: "/_base/analytics/parts_inventory/top_vendor_mapping.view.lkml"
include: "/_base/procurement/public/non_inventory_items.view.lkml"

explore: dim_markets_fleet_opt {
  label: "Vendor Map"
  sql_always_where: ${market_active}
    and ${market_company_id} = 1854 ;;

  join: dim_locations_fleet_opt {
    type: inner
    relationship: one_to_one
    sql_on: ${dim_markets_fleet_opt.location_key} = ${dim_locations_fleet_opt.location_key} ;;
  }

  join: dim_vendors {
    type: cross
    relationship: many_to_many
  }

  join: dim_dates_fleet_opt {
    type: cross
    relationship: many_to_many
    sql_where: ${dim_dates_fleet_opt.dt_date_raw} <= current_date() ;;
  }

  join: entity_vendor_settings {
    type: left_outer
    relationship: many_to_one
    sql_on: ${dim_vendors.vendor_sage_id} = ${entity_vendor_settings.external_erp_vendor_ref} ;;
  }

  join: purchase_orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${dim_markets_fleet_opt.market_id} = ${purchase_orders.requesting_branch_id} and ${entity_vendor_settings.entity_id} = ${purchase_orders.vendor_id} and ${dim_dates_fleet_opt.dt_date_date} = ${purchase_orders.date_created_date} ;;
  }

  join: purchase_order_line_items {
    type: left_outer
    relationship: one_to_many
    sql_on: ${purchase_orders.purchase_order_id} = ${purchase_order_line_items.purchase_order_id} ;;
  }

  join: non_inventory_items {
    type: left_outer
    relationship: many_to_one
    sql_on: ${purchase_order_line_items.item_id} = ${non_inventory_items.item_id} ;;
  }

  join: top_vendor_mapping {
    type: inner
    relationship: one_to_one
    sql_on: ${dim_vendors.vendor_sage_id} = ${top_vendor_mapping.vendor_id} ;;
  }
}
