connection: "es_warehouse"

include: "/views/asset_utilization/*.view.lkml"

explore: utilization_history {
  group_label: "RentOps"
  label: "Asset Utilization"
  description: "Explore used for RentOps Asset Utilization"
  case_sensitive: no
  persist_for: "20 minutes"

  join: utilization_history_by_asset {
    type: inner
    relationship: many_to_one
    sql_on: ${utilization_history_by_asset.asset_class} = ${utilization_history_by_asset.asset_class} and ${utilization_history.day} = ${utilization_history_by_asset.day} ;;
  }

}

explore: unavailable_oec {
  group_label: "RentOps"
  label: "Unavailable OEC Asset Utilization"
  description: "Explore used for RentOps Asset Utilization"
  case_sensitive: no
  persist_for: "20 minutes"
}

explore: asset_class_utilization_history {
  group_label: "RentOps"
  label: "Asset Class Asset Utilization"
  description: "Explore used for RentOps Asset Utilization"
  case_sensitive: no
  persist_for: "20 minutes"

  join: asset_class_utilization_history_asset_drill {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_class_utilization_history_asset_drill.asset_class} = ${asset_class_utilization_history.asset_class} and ${asset_class_utilization_history.day} = ${asset_class_utilization_history_asset_drill.day} ;;
  }

  join: own_asset_list {
    type: inner
    relationship: many_to_many
    sql_on: ${own_asset_list.asset_id} = ${asset_class_utilization_history_asset_drill.asset_id} ;;
  }
}
