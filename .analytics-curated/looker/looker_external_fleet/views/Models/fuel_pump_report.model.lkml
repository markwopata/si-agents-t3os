connection: "es_warehouse"

include: "/views/*.view.lkml"
include: "/views/fuel_pump_outside_hours_alert/*.view.lkml"

datagroup: ASSET_FUEL_CONSUMPTION_update {
  sql_trigger: select max(data_refresh_timestamp) from business_intelligence.triage.STG_T3__ASSET_FUEL_CONSUMPTION ;;
  max_cache_age: "2 hours"
}

explore: fuel_pump_data {
  group_label: "Fuel"
  label: "Fuel Pump Report"
  case_sensitive: no
  persist_for: "10 minutes"

  # join: assets {
  #   view_label: "Fueled Asset"
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${fuel_pump_data.fueled_asset_id} = ${assets.asset_id};;
  # }

  # join:asset_types {
  #   view_label: "Fueled Asset Type"
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  # }

  # join: categories {
  #   view_label: "Fueled Category"
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${categories.category_id} = ${assets.category_id} ;;
  # }
}

explore: asset_fuel_consumption {
  group_label: "Fuel"
  label: "Fuel Consumption Report"
  case_sensitive: no
  persist_with: ASSET_FUEL_CONSUMPTION_update
  # persist_for: "10 minutes"
  #sql_always_where: ${assets.deleted} = FALSE ;;

  # join:asset_types {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  # }

  # join: categories {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${categories.category_id} = ${assets.category_id} ;;
  # }

  # join: markets {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  # }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_fuel_consumption.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

}

# explore: fuel_purchases {
#   label: "Fuel Purchases"
#   description: "Fuel purchases per asset from es_warehouse.public.fuel_purchases"

#   join: organization_asset_xref {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${fuel_purchases.asset_id} = ${organization_asset_xref.asset_id} ;;
#   }

#   join: organizations {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
#   }
# }


explore: fuel_pump_outside_hours_alert {
  group_label: "Fuel"
  label: "Fuel Pump Outside Hours Alert"
  case_sensitive: no
  persist_for: "10 minutes"
}
