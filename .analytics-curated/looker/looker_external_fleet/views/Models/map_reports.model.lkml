connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: map_reports {
  group_label: "Fleet"
  label: "Map Reports"
  case_sensitive: no
  persist_for: "10 minutes"
  sql_always_where: ${assets.asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${map_reports.asset_id} = ${assets.asset_id} ;;
  }

  join:asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

}

explore: unique_addresses_with_lat_lon {
  group_label: "Fleet"
  label: "Possible Addresses"
  case_sensitive: no
  persist_for: "45 minutes"

}

explore: asset_entry_exit_time_from_address {
  group_label: "Fleet"
  label: "Assets in Proxmity"
  case_sensitive: no
  persist_for: "45 minutes"

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_entry_exit_time_from_address.asset_id} ;;
  }

  join: asset_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

}
