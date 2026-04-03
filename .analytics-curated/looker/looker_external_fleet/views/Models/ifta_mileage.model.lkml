connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: ifta_detail {
  group_label: "Fleet"
  label: "IFTA Detail Report"
  case_sensitive: no
  persist_for: "10 minutes"

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${ifta_detail.asset_id} = ${assets.asset_id};;
  }

  join: asset_settings {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_settings_id} = ${asset_settings.asset_settings_id};;
  }

  join: company_dot_numbers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.dot_number_id} = ${company_dot_numbers.dot_number_id} ;;
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
