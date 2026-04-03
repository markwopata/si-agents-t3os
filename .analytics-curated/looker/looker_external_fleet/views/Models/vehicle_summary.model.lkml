connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: vehicle_summary{
  group_label: "Fleet"
  label: "Vehicle Summary Report"
  case_sensitive: no
  persist_for: "1 hour"

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${vehicle_summary.asset_id} = ${assets.asset_id};;
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

  join: organization_asset_xref {
    type: left_outer
    relationship: one_to_many
    sql_on: ${assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }
  }
