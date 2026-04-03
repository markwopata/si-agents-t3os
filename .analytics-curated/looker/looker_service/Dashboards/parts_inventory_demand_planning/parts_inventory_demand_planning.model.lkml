connection: "es_snowflake_analytics"

include: "/Dashboards/parts_inventory_demand_planning/views/suggested_min_max.view.lkml"
include: "/views/FLEET_OPTIMIZATION/dim_markets_fleet_opt.view.lkml"
include: "/views/custom_sql/current_deadstock.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_substitutes.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_suppression_categories.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/parts_attributes.view.lkml"
include: "/views/ANALYTICS/PARTS_INVENTORY/part_categorization_structure.view.lkml"

explore: dim_markets_fleet_opt {
  label: "Suggested Min/Max"

  join: suggested_min_max  {
    type: inner
    relationship: many_to_one
    sql_on: ${suggested_min_max.market_id} = ${dim_markets_fleet_opt.market_id} ;;
  }

  join: company_wide_part_dead_stock {
    type: left_outer
    relationship: one_to_many
    sql_on: ${company_wide_part_dead_stock.part_number} = ${suggested_min_max.part_number} ;;
  }

  join: market_wide_part_dead_stock {
    type: left_outer
    relationship: one_to_one
    sql_on: ${market_wide_part_dead_stock.part_number} = ${suggested_min_max.part_number}
      and ${market_wide_part_dead_stock.market_id} = ${suggested_min_max.market_id};;
  }

  join: part_substitutes_flag_sub_type {
    type: left_outer
    relationship: many_to_one
    sql_on: ${part_substitutes_flag_sub_type.part_id} = ${suggested_min_max.master_part_id} ;;
  }

  join: part_suppression_categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${part_suppression_categories.part_id} = ${suggested_min_max.master_part_id} ;;
  }

  join: parts_attributes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${parts_attributes.part_id} = ${suggested_min_max.master_part_id}
      and ${parts_attributes.is_current} ;;
  }

  join: part_categorization_structure {
    type: left_outer
    relationship: one_to_one
    sql_on: ${part_categorization_structure.part_categorization_id} = ${parts_attributes.part_categorization_id} ;;
  }
}
