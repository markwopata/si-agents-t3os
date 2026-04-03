connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this

explore: company_owned_assets_and_groups {
  sql_always_where: ${company_owned_assets_and_groups.asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) ;;
  group_label: "Fleet"
  label: "Group Assignment Report"
  case_sensitive: no
  persist_for: "10 minutes"

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${group_assignment_trips.asset_id} = ${assets.asset_id};;
  }

  join:asset_types {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_type_id} = ${asset_types.asset_type_id} ;;
  }

  join: categories {
    type: inner
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  # join: company_owned_assets_and_groups {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${assets_owned_assets.asset_id} = ${group_assignment_trips.asset_id} and ${company_owned_assets_and_groups.groups} = ${group_assignment_trips.group_name} ;;
  # }

  join: group_assignment_trips {
    type: left_outer
    relationship: many_to_one
    sql_on: ${group_assignment_trips.asset_id} = ${company_owned_assets_and_groups.asset_id} and ${company_owned_assets_and_groups.groups} = ${group_assignment_trips.group_name} ;;
  }

  join: assets_owned_assets {
    from: assets
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_owned_assets_and_groups.asset_id} = ${assets_owned_assets.asset_id};;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets_owned_assets.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  }
