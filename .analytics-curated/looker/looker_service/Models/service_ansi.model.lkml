connection: "es_snowflake_analytics"

include: "/views/ES_WAREHOUSE/assets.view.lkml"
include: "/views/ES_WAREHOUSE/asset_status_key_values.view.lkml"
include: "/views/ES_WAREHOUSE/asset_service_intervals.view.lkml"
include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/assets_aggregate.view.lkml"
include: "/views/SAASY/PUBLIC/asset_maintenance_status.view.lkml"


explore: asset_service_intervals {
  group_label: "Service"
  label: "ANSI Service"
  sql_always_where: ${maintenance_group_interval_name} ilike '%ANSI%' OR ${maintenance_group_interval_name} ilike '%Annual%' OR ${maintenance_group_interval_name} ilike '%DOT %';;

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_service_intervals.asset_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = coalesce(${assets.service_branch_id}, ${assets.rental_branch_id}) ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${markets.market_id}  ;;
  }

  join: assets_aggregate {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_aggregate.asset_id} = ${assets.asset_id};;
  }

  join: asset_maintenance_status {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_maintenance_status.asset_id} = ${asset_service_intervals.asset_id}
      and ${asset_maintenance_status.maintenance_group_interval_id} = ${asset_service_intervals.maintenance_group_interval_id}
      and ${asset_maintenance_status.is_deleted} = false ;;
  }
}

#MB commented out 5/22/24 ties to no active dashboard/look
# explore: assets {
#   group_label: "Service"
#   label: "ANSI Service - Includes Exempt Assets"

#   join: asset_service_intervals {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${assets.asset_id} = ${asset_service_intervals.asset_id} ;;
#   }

#   join: asset_status_key_values {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
#   }

#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = coalesce(${assets.service_branch_id}, ${assets.inventory_branch_id});;
#   }

#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_xwalk.market_id} = ${markets.market_id} ;;
#   }
# }
