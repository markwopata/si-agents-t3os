connection: "es_snowflake_analytics"


include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/custom_sql/part_average_cost.view.lkml"
include: "/views/INVENTORY/parts.view.lkml"
include: "/views/INVENTORY/part_types.view.lkml"
include: "/views/custom_sql/bulk_part_providers.view.lkml"

explore: part_average_cost {
  sql_always_where: ${market_region_xwalk.District_Region_Market_Access} or ${market_region_xwalk.market_id} is null ;;

  join: market_region_xwalk {
    relationship: many_to_one
    sql_on: ${part_average_cost.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: parts {
    relationship: many_to_one
    type: left_outer
    sql_on: ${part_average_cost.part_id} = ${parts.part_id} ;;
  }

  join: part_types {
    relationship: many_to_one
    type: left_outer
    sql_on: ${parts.part_type_id} = ${part_types.part_type_id} ;;
  }
}

explore: bulk_part_providers {

}
