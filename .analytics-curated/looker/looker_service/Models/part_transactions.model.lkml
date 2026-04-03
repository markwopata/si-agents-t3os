connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/INTACCT_MODELS/part_inventory_transactions_b.view.lkml"
include: "/views/ANALYTICS/telematics_part_ids.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_dates_fleet_opt.view.lkml"
include: "/views/INVENTORY/providers.view.lkml"
include: "/views/ANALYTICS/parts_inventory_parts.view.lkml"
include: "/views/INVENTORY/inventory_locations.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: part_inventory_transactions_b {
#   label: "Improper Movement"
#   sql_always_where: ${part_inventory_transactions_b.date_cancelled_date} is null ;;
#
#   join: parts_inventory_parts {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${part_inventory_transactions_b.part_id} = ${parts_inventory_parts.part_id} ;;
#   }
#
#   join: to_store {
#     from: inventory_locations
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${part_inventory_transactions_b.to_id} = ${to_store.inventory_location_id} and ${part_inventory_transactions_b.transaction_type} ilike 'store to store' ;;
#   }
#
#   join: from_store {
#     from: inventory_locations
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${part_inventory_transactions_b.from_id} = ${from_store.inventory_location_id} and ${part_inventory_transactions_b.transaction_type} ilike 'store to store' ;;
#   }
#
#   join: providers {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${parts_inventory_parts.provider_id} = ${providers.provider_id} ;;
#   }
#
#   join: telematics_part_ids {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${part_inventory_transactions_b.part_id} = ${telematics_part_ids.part_id} ;;
#   }
#
#   join: dim_dates_fleet_opt {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${part_inventory_transactions_b.date_completed_date} = ${dim_dates_fleet_opt.dt_date} ;;
#   }
# }
