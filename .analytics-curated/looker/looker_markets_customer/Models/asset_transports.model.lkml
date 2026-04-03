connection: "es_snowflake_c_analytics"

include: "/views/ANALYTICS/asset_transports.view.lkml"

explore: asset_transports {
  group_label: "Asset Transports"
  label: "Asset Transports"
  case_sensitive: no
  description: "View of asset transports"
}
