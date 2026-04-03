connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: asset_geofence_encounters {
  sql_always_where: (${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric))) AND ${geofences.company_id} = {{ _user_attributes['company_id'] }}::numeric
  OR
  ${asset_id} in ${rental_asset_list_current.asset_id} AND ${geofences.company_id} = {{ _user_attributes['company_id'] }}::numeric )
  AND ${geofences.deleted} = FALSE ;;
  # ${asset_id} in (select asset_id from table(assetlist('{{ _user_attributes['user_id'] }}'::numeric)))
  group_label: "Fleet"
  label: "Asset Geofences"
  case_sensitive: no
  persist_for: "30 minutes"

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_geofence_encounters.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
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

  join: geofences {
    type: full_outer
    relationship: one_to_many
    sql_on: ${geofences.geofence_id} = ${asset_geofence_encounters.geofence_id} AND ${asset_geofence_encounters.end_range_date} is null AND ${asset_geofence_encounters.start_range_date} is not null ;;
  }

  join: rental_asset_list_current {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_asset_list_current.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

  join: trackers_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers_mapping.asset_id} = ${assets.asset_id} ;;
  }

}

explore: asset_geofence_time_utilization {
  group_label: "Geofence"
  label: "By Asset Geofence Utilization"
  case_sensitive: no
  persist_for: "30 minutes"
  sql_always_where: ${geofences.deleted} = FALSE ;;

  join: geofences {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_geofence_time_utilization.geofence_id} = ${geofences.geofence_id} ;;
  }

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_geofence_time_utilization.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
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

  join: asset_geofence_idle_time {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_geofence_idle_time.geofence_id} = ${asset_geofence_time_utilization.geofence_id} and ${asset_geofence_idle_time.asset_id} = ${asset_geofence_time_utilization.asset_id} ;;
  }

  join: asset_geofence_entry_exit {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_geofence_entry_exit.asset_id} = ${asset_geofence_time_utilization.asset_id} and ${asset_geofence_entry_exit.geofence_id} = ${asset_geofence_time_utilization.geofence_id} ;;
  }

  join: asset_geofence_trip_time {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_geofence_trip_time.asset_id} = ${asset_geofence_time_utilization.asset_id} and ${asset_geofence_trip_time.geofence_id} = ${asset_geofence_time_utilization.geofence_id} ;;
  }

  join: asset_geo_fence_miles_driven_detail {
    type: inner
    relationship: many_to_one
    sql_on: ${asset_geo_fence_miles_driven_detail.asset_id} = ${asset_geofence_time_utilization.asset_id} and ${asset_geo_fence_miles_driven_detail.geofence_id} = ${asset_geofence_time_utilization.geofence_id} ;;
  }

  join: trackers_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers_mapping.asset_id} = ${assets.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }
}
