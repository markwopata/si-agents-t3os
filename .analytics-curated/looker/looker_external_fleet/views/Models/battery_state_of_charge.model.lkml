connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: battery_state_of_charge {
  sql_always_where: ${asset_id} in ${battery_state_of_charge.asset_id} ;;
  group_label: "Custom Report"
  label: "Battery State of Charge"
  case_sensitive: no
  persist_for: "10 minutes"

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${battery_state_of_charge.asset_id} ;;
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
