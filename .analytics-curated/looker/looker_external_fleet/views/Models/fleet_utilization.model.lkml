connection: "reportingc_warehouse"

include: "/views/*.view.lkml"
include: "/views/fleet_utilization/*.view.lkml"

datagroup: by_day_util_update {
  sql_trigger: select max(data_refresh_timestamp) from business_intelligence.triage.stg_t3__by_day_utilization ;;
  max_cache_age: "4 hours"
}

explore: utilization_daily_summary {
    group_label: "Fleet Utilization"
    label: "Daily Utilization Summary"
    case_sensitive: no
    persist_with: by_day_util_update
  }

explore: jobs_list {
  group_label: "Fleet Utilization"
  label: "Jobs List"
  case_sensitive: no
  persist_with: by_day_util_update

join: asset_info {
  type: left_outer
  relationship: many_to_one
  sql_on: ${asset_info.asset_id} = ${jobs_list.asset_id} ;;
   }
}

explore: sub_renters {
  group_label: "Fleet Utilization"
  label: "Sub Renters"
  case_sensitive: no
  persist_with: by_day_util_update

join: asset_info {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_info.asset_id} = ${sub_renters.asset_id} ;;
  }
}

explore: rental_company_name {
  group_label: "Fleet Utilization"
  label: "Rental Company Name"
  case_sensitive: no
  persist_with: by_day_util_update

  join: asset_info {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_info.asset_id} = ${rental_company_name.asset_id} ;;
  }
}

explore: asset_utilization_by_day {
  group_label: "Fleet Utilization"
  label: "Daily Run, Idle and Hauled Summary"
  case_sensitive: no
  persist_with: by_day_util_update

  join: fleet_utilization_asset_details_drilldown {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_utilization_by_day.asset_id} = ${fleet_utilization_asset_details_drilldown.asset_id} ;;
  }

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_utilization_by_day.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
    AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
  }

  join: telematics_health {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_health.asset_id} = ${asset_utilization_by_day.asset_id};;
  }
}


explore: asset_hauled_hauling_time {
  group_label: "Fleet Utilization"
  label: "Asset Hauled and Hauling Summary"
  case_sensitive: no
  persist_with: by_day_util_update

  join: organization_asset_xref {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_hauled_hauling_time.asset_id} = ${organization_asset_xref.asset_id} ;;
  }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
    AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
  }

  join: telematics_health {
    type: left_outer
    relationship: many_to_one
    sql_on: ${telematics_health.asset_id} = ${asset_hauled_hauling_time.asset_id};;
    }
}

  explore: asset_info {
    group_label: "Fleet Utilization"
    label: "Asset Info"
    case_sensitive: no
    persist_with: by_day_util_update

    join: organization_asset_xref {
      type: left_outer
      relationship: many_to_one
      sql_on: ${asset_info.asset_id} = ${organization_asset_xref.asset_id} ;;
    }

    join: organizations {
      type: left_outer
      relationship: one_to_many
      sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id}
      AND ${organizations.company_id} = {{ _user_attributes['company_id'] }}::numeric ;;
    }
}
