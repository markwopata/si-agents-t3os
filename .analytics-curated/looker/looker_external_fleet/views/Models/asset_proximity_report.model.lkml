connection: "reportingc_warehouse"

include: "/views/asset_proximity_report/*.view.lkml"
include: "/views/unique_addresses_with_lat_lon.view.lkml"
include: "/views/organization_asset_xref.view.lkml"
include: "/views/organizations.view.lkml"
include: "/views/fleet_utilization/*.view.lkml"

explore: asset_proximity_report {
  group_label: "Asset Proximity Report"
  label: "Assets Proxmity"
  case_sensitive: no
  persist_for: "45 minutes"

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_proximity_report.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: asset_info {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_proximity_report.asset_id} = ${asset_info.asset_id} ;;
  }

}

explore: unique_addresses_with_lat_lon {
  group_label: "Asset Proximity Report"
  label: "Possible Addresses"
  case_sensitive: no
  persist_for: "45 minutes"

}

explore: asset_proximity_map_points {
  group_label: "Asset Proximity Report"
  label: "Location of Map Points"
  case_sensitive: no
  persist_for: "45 minutes"

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_proximity_map_points.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: asset_info {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_proximity_map_points.asset_id} = ${asset_info.asset_id} ;;
  }

}

explore: asset_prox_logged_events {
  group_label: "Asset Proximity Report"
  label: "Logging Events"
  case_sensitive: no
  persist_for: "45 minutes"

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_prox_logged_events.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: asset_info {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_prox_logged_events.asset_id} = ${asset_info.asset_id} ;;
  }

}
