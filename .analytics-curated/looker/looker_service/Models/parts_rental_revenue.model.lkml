connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/v_line_items.view.lkml"
include: "/views/ANALYTICS/parts_inventory_parts.view.lkml"
include: "/views/INVENTORY/providers.view.lkml"
include: "/views/ES_WAREHOUSE/rental_part_assignments.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_dates_fleet_opt.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"


explore: v_line_items {
  sql_always_where: ${dim_markets_fleet_opt.market_district} != '0-0'
                and ${dim_markets_fleet_opt.market_region} != '0' ;;

  join: rental_part_assignments {
    type: inner
    relationship: many_to_one
    sql_on: ${v_line_items.rental_id} = ${rental_part_assignments.rental_id} ;;
  }

  join: parts_inventory_parts {
    type: inner
    relationship: many_to_one
    sql_on: ${rental_part_assignments.part_id} = ${parts_inventory_parts.part_id} ;;
  }

  join: providers {
    type: inner
    relationship: many_to_one
    sql_on: ${parts_inventory_parts.provider_id} = ${providers.provider_id} ;;

  }

  join: dim_dates_fleet_opt {
    type: inner
    relationship: many_to_one
    sql_on: ${v_line_items.gl_billing_approved_date_date} = ${dim_dates_fleet_opt.dt_date} ;;
  }

  join: dim_markets_fleet_opt {
    type: inner
    relationship: many_to_one
    sql_on: ${v_line_items.branch_id} = ${dim_markets_fleet_opt.market_id} ;;
  }
}
