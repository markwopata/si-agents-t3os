connection: "es_snowflake"

# include: "my_dashboard.dashboard.lookml"   # include a LookML dashboard called my_dashboard
include: "/views/service_outside_labor.view.lkml"


# For enhancement
include: "/views/PROCUREMENT/purchase_orders.view.lkml"
include: "/views/PROCUREMENT/purchase_order_line_items.view.lkml"

include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_assets_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_work_orders_fleet_opt.view.lkml"
include: "/views/ES_WAREHOUSE/PURCHASES/entities.view.lkml"

explore: service_outside_labor {
  case_sensitive: no
}

# Commented out due to low usage on 2026-03-27
# explore: purchase_order_line_items {
#   label: "PO Line & Asset Grain Data"
#   case_sensitive: no
#   sql_always_where: ${purchase_orders.date_created_year} >= 2023 AND ${item_id} = 'd6fd484c-da57-4e62-a2c5-9a2d0202ffdb';;
#
#   join: purchase_orders {
#     relationship: many_to_one
#     sql_on: ${purchase_order_line_items.purchase_order_id} = ${purchase_orders.purchase_order_id} ;;
#   }
#
#   join: dim_markets_fleet_opt {
#     relationship: many_to_one
#     sql_on: ${purchase_orders.requesting_branch_id} = ${dim_markets_fleet_opt.market_id} ;;
#   }
#
#   join: dim_work_orders_fleet_opt {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${purchase_order_line_items.allocation_type} = 'WORK_ORDER'
#       AND ${purchase_order_line_items.allocation_id} = CAST(${dim_work_orders_fleet_opt.work_order_id} AS VARCHAR) ;;
#   }
#
#   join: dim_assets_fleet_opt {
#     relationship: many_to_one
#     type: left_outer
#     sql_on: ${dim_work_orders_fleet_opt.work_order_asset_id} = ${dim_assets_fleet_opt.asset_id} ;;
#   }
#
#   join: entities {
#     relationship: many_to_many
#     type: left_outer
#     sql_on: ${purchase_orders.vendor_id} = ${entities.entity_id} ;;
#   }
#
# }
