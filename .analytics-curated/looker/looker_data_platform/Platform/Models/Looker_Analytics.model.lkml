connection: "es_snowflake_c_analytics"

include: "/Platform/Views/Analytics/looker_dashboards__spike.view.lkml"
include: "/Platform/Views/Analytics/looker_dashboard_tiles__spike.view.lkml"
include: "/Platform/Views/int_assets.view.lkml"
include: "/Platform/Views/market_region_xwalk.view.lkml"

datagroup: int_assets_datagroup {
  sql_trigger: select max("DATE_UPDATED") from "ANALYTICS"."ASSETS"."INT_ASSETS" ;;
  max_cache_age: "2 hours"
  description: "Looking at ANALYTICS.ASSETS.INT_ASSETS to get most recent update."
}

explore: looker_dashboard_lookup {
  from: looker_dashboards__spike
  case_sensitive: no
}

explore: looker_dashboard_tiles__spike {
  case_sensitive: no
  group_label: "Dashboard Finder"
  label: "Looker Dashboard Finder"
}

# Commented out due to low usage on 2026-03-27
# explore: int_assets {
#   case_sensitive: no
#   label: "Asset Inventory"
#   group_label: "Assets"
#   description: "Explore for analyzing asset inventory across markets, branches, categories, and ownership types"
#   persist_with: int_assets_datagroup
#
#   join: market_region_xwalk {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${int_assets.market_id} = ${market_region_xwalk.market_id} ;;
#   }
# }
