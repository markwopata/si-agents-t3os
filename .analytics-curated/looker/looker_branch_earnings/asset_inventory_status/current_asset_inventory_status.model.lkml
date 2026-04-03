connection: "es_snowflake_c_analytics"

include: "/views/ANALYTICS/parent_market.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/revmodel_market_rollout_conservative.view.lkml"
include: "/views/ANALYTICS/plexi_periods.view.lkml"
include: "/views/ANALYTICS/int_markets.view.lkml"
include: "/asset_inventory_status/stg_es_warehouse_scd__scd_asset_inventory_status.view.lkml"
include: "/views/ANALYTICS/int_assets.view.lkml"

explore: stg_es_warehouse_scd__scd_asset_inventory_status {
  label: "Current Asset Inventory Days in Status"

  sql_always_where: (
      ${market_region_xwalk.District_Region_Market_Access}
    )
    -- Let devs, admins, and jabbok see unpublished BE periods.
    or 'developer' = {{ _user_attributes['department'] }}
    or 'admin' = {{ _user_attributes['department'] }}
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'jabbok@equipmentshare.com'
    or trim(lower('{{ _user_attributes['email'] | replace: "'", "\\'"}}')) = 'mark.wallace@equipmentshare.com'
    ;;

  join: int_assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${stg_es_warehouse_scd__scd_asset_inventory_status.asset_id}=${int_assets.asset_id} ;;
  }

  join: parent_market {
    type: left_outer
    relationship: many_to_one
    sql_on: ${int_assets.market_id}::text = ${parent_market.market_id}
      and current_date()::date >= date_trunc(month, ${parent_market.start_date}::date)
      and current_date()::date <= coalesce(date_trunc(month, ${parent_market.end_date}::date), '2099-12-31')
      ;;
  }

  join: market_region_xwalk {
    type: inner
    relationship: many_to_one
    sql_on: coalesce(${parent_market.parent_market_id}, ${int_assets.market_id}::text) = ${market_region_xwalk.market_id}::text ;;
  }

  join: revmodel_market_rollout_conservative {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id} = ${revmodel_market_rollout_conservative.market_id} ;;
  }

  join: int_markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${market_region_xwalk.market_id}=${int_markets.market_id} ;;
  }

  join: plexi_periods {
    type: left_outer
    relationship: many_to_one
    sql_on: ${plexi_periods.display}::date = date_trunc(month,current_date()::date) ;;
  }
}
