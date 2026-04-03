connection: "reportingc_warehouse"

include: "/views/*.view.lkml"
include: "/views/fleet_utilization_archive/*.view.lkml"

explore: utilization_daily_summary_archive {
  group_label: "Fleet Utilization"
  label: "Daily Utilization Summary"
  case_sensitive: no
  persist_for: "180 minutes"
}

explore: jobs_list_archive {
  group_label: "Fleet Utilization"
  label: "Jobs List"
  case_sensitive: no
  persist_for: "180 minutes"
  join: asset_info_archive {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_info_archive.asset_id} = ${jobs_list_archive.asset_id} ;;
  }
}

explore: asset_utilization_by_day_archive {
  group_label: "Fleet Utilization"
  label: "Daily Run, Idle and Hauled Summary"
  case_sensitive: no
  persist_for: "180 minutes"

  join: fleet_utilization_asset_details_drilldown {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_utilization_by_day_archive.asset_id} = ${fleet_utilization_asset_details_drilldown.asset_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_utilization_by_day_archive.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
      AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
  }
}

explore: asset_hauled_hauling_time_archive {
  group_label: "Fleet Utilization"
  label: "Asset Hauled and Hauling Summary"
  case_sensitive: no
  persist_for: "180 minutes"

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_hauled_hauling_time_archive.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
      AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
  }
}

explore: asset_info_archive {
  group_label: "Fleet Utilization"
  label: "Asset Info"
  case_sensitive: no
  persist_for: "180 minutes"

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_info_archive.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
      AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
  }
}
