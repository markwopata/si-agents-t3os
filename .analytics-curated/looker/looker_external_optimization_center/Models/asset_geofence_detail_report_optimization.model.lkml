connection: "es_warehouse_stage"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: asset_geofence_details {
  sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) AND ${geofences.company_id} = {{ _user_attributes['company_id'] }}::numeric
      OR
      ${asset_id} in ${rental_asset_list_10_days.asset_id} AND ${geofences.company_id} = {{ _user_attributes['company_id'] }}::numeric;;
  group_label: "Optimization"
  label: "Asset Geofence Detail Report"
  case_sensitive: no

  join: assets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_geofence_details.asset_id} = ${assets.asset_id} ;;
  }

  join: rental_asset_list_10_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_asset_list_10_days.asset_id} = ${assets.asset_id} ;;
  }

  join:asset_types {
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
    relationship: one_to_one
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: geofences {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_geofence_details.geofence_id} = ${geofences.geofence_id} ;;
  }

}
