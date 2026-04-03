connection: "es_snowflake_analytics"

include: "/Dashboards/asset_availability_finder/*.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/asset_transfer_status.view.lkml"


explore: find_available_assets_nearby {
  group_label: "Asset Inventory"
  label: "Asset Availability Finder"
  description: "Pulls user location and asset location to find closest assets not on rent"
  case_sensitive: no
  persist_for: "5 minutes"

  join: asset_transfer_status {
    type: left_outer
    relationship: many_to_one
    sql_on: ${find_available_assets_nearby.asset_id}=${asset_transfer_status.asset_id} AND ${asset_transfer_status.row_num} = 1   ;;
  }
}


explore: es_asset_classes {
  group_label: "Asset Inventory"
  label: "Asset Availability Asset Class"
  description: "Pull in asset class information for filter of asset availability"
  case_sensitive: no
  persist_for: "10 hours"
}


explore: market_region_xwalk {
  group_label: "Asset Inventory"
  label: "Asset Availability Market Selection"
  description: "Pull in available markets for filter of asset availability"
  case_sensitive: no
  persist_for: "10 hours"
}
