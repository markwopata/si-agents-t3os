connection: "es_snowflake_analytics"

include: "/location_permissions/*.view.lkml"

explore: location_permissions {
   from: location_permissions_optimized
  group_label: "Permissions"
  label: "Location Permissions"
  description: "Used to populate filters based on user allowed access via company directory or Looker"
  case_sensitive: no
  sql_always_where: ${location_permissions.market_access} OR ${location_permissions.district_access} OR ${location_permissions.region_access} ;;

  join: gm_sm_info {
    type: left_outer
    relationship: many_to_one
    sql_on: ${location_permissions.market_id} = ${gm_sm_info.market_id} ;;
  }
}

explore: branch_window_location_perm {
  group_label: "Permissions"
  label: "Location Permissions - Branch Window"
  description: "Used to populate filters based on user allowed access via company directory or Looker, allowing market level employees to only see their own markets info"
  case_sensitive: no
  persist_for: "8 hours"
}
