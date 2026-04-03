connection: "es_warehouse"

include: "/views/asset_service_history/asset_service_history.view.lkml"
include: "/views/asset_service_history/owned_asset_list.view.lkml"

explore: asset_service_history {
  group_label: "Service"
  label: "Asset Service History"
  case_sensitive: no
}

explore: owned_asset_list {
  group_label: "Service"
  label: "Owned Asset List"
  case_sensitive: no
}
