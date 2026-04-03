connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/SERVICE/asset_month_maintenance_cost.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ES_WAREHOUSE/scd_asset_rsp.view.lkml"

explore: cost_of_maintenance {
  from: asset_month_maintenance_cost

  join: scd_asset_rsp {
    type: inner
    relationship: one_to_one
    sql_on: ${cost_of_maintenance.asset_id}=${scd_asset_rsp.asset_id} and ${cost_of_maintenance.month_group_date}>=${scd_asset_rsp.date_start_date} and ${cost_of_maintenance.month_group_date}<${scd_asset_rsp.date_end_date} ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: ${scd_asset_rsp.rental_branch_id}=${market_region_xwalk.market_id} ;;
  }
}
