connection: "es_snowflake_analytics"

## under construction

include: "/views/ANALYTICS/attachment_provider_ids.view.lkml"
include: "/views/ANALYTICS/parts_inventory_parts.view.lkml"
include: "/views/ANALYTICS/INTACCT_MODELS/part_inventory_transactions_b.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ES_WAREHOUSE/INVENTORY/store_parts.view.lkml"
include: "/views/INVENTORY/inventory_locations.view.lkml"
include: "/views/ANALYTICS/es_companies.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/PLATFORM/v_assets.view.lkml"
include: "/Dashboards/SI67_attachments_oversight/rental_comparisons_by_market.view.lkml"
include: "/Dashboards/SI67_attachments_oversight/main_movers.view.lkml"
include: "/Dashboards/SI67_attachments_oversight/attachments.view.lkml"
include: "/Dashboards/SI67_attachments_oversight/main_movers_history.view.lkml"
include: "/Dashboards/SI67_attachments_oversight/attachments_history.view.lkml"
include: "/Dashboards/SI67_attachments_oversight/rentals_missing_attachments.view.lkml"
include: "/Dashboards/SI67_attachments_oversight/high_level_compatibility.view.lkml"
include: "/views/OPERATIONAL_ANALYTICS/oa_dim_dates.view.lkml"

include: "/views/ES_WAREHOUSE/orders.view.lkml"
include: "/views/ES_WAREHOUSE/rentals.view.lkml"
include: "/views/ES_WAREHOUSE/rental_part_assignments.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_parts_fleet_opt.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: attachment_provider_ids {
#
#   join: parts_inventory_parts {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${attachment_provider_ids.provider_id} = ${parts_inventory_parts.provider_id} and ${parts_inventory_parts.name not ilike '%telehandler%'};;
#   }
#
#   join: store_parts {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${parts_inventory_parts.part_id} = ${store_parts.part_id} ;;
#   }
#
#   join: inventory_locations {
#     type: inner
#     relationship: one_to_many
#     sql_on: ${store_parts.inventory_location_id} = ${inventory_locations.inventory_location_id} ;;
#   }
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${inventory_locations.branch_id} = ${market_region_xwalk.market_id} ;;
#   }
#
#   join: part_inventory_transactions_b {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${parts_inventory_parts.part_id} = ${part_inventory_transactions_b.part_id}
#     and ${store_parts.inventory_location_id} = ${part_inventory_transactions_b.store_id};;
#   }
#
# } ## attachment_providers_ids explore

# explore: rental_comparisons_by_market {

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${rental_comparisons_by_market.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# } ## rental_comparisons_by_market explore

explore: market_region_xwalk {
  sql_always_where: ${oa_dim_dates.dt_standard_date} < current_date ;;

  join: oa_dim_dates {
    type: cross
    relationship: one_to_many
  }

  join: main_movers_history {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${main_movers_history.rental_branch_id} and ${oa_dim_dates.dt_standard_date} = ${main_movers_history.dt_date};;
  }

  join: attachments_history {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${attachments_history.market_id} and ${oa_dim_dates.dt_standard_date} = ${attachments_history.dt_date};;
  }

  join: parts_inventory_parts {
    type: inner
    relationship: one_to_many
    sql_on: ${attachments_history.part_id} = ${parts_inventory_parts.part_id} ;;
  }

  join: high_level_compatibility {
    type: inner
    relationship: many_to_one
    sql_on: upper(${main_movers_history.main_mover_type}) = upper(${high_level_compatibility.mm_type})
            and contains(${attachments_history.si_67_part_provider_name}, upper(${high_level_compatibility.attachment_type}));;
  }

} ## market_region_xwalk

# explore: rentals_missing_attachments {

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: one_to_one
#     sql_on: ${rentals_missing_attachments.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }

explore: rental_contract_adoption {
  view_name: market_region_xwalk
  sql_always_where: ${high_level_compatibility.mm_type} is not null ;;

  join: orders {
    type: left_outer
    relationship: one_to_many
    sql_on: ${market_region_xwalk.market_id} = ${orders.market_id} and not ${orders.deleted} ;;
  }

  join: rentals {
    type: left_outer
    relationship: one_to_many
    sql_on: ${orders.order_id} = ${rentals.order_id} and ${rentals.on_rent} and not ${rentals.deleted};;
  }

  join: main_movers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rentals.asset_id} = ${main_movers.asset_id} ;;
  }

  join: rental_part_assignments {
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${rental_part_assignments.rental_id} and ${rental_part_assignments.currently_on_rent};;
  }

  join: dim_parts_fleet_opt {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_part_assignments.part_id} = ${dim_parts_fleet_opt.part_id} and ${dim_parts_fleet_opt.part_provider_name} not ilike '%telehandler%'
    ;;
  }

  join: high_level_compatibility {
    type: left_outer
    relationship: many_to_one
    sql_on: upper(${main_movers.main_mover_type}) = upper(${high_level_compatibility.mm_type})
      or contains(${dim_parts_fleet_opt.si_67_part_provider_name}, upper(${high_level_compatibility.attachment_type}));;
  }

  join: rentals_missing_attachments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${rentals.rental_id} = ${rentals_missing_attachments.rental_id} ;;
  }

  join: child_rental {
    from: rentals
    type: left_outer
    relationship: one_to_many
    sql_on: ${rentals.rental_id} = ${child_rental.parent_rental_id} ;;
  }

} #end rental_contract_adoption explore
