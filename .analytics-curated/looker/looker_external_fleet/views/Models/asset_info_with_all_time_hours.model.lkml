connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: assets {
sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
  OR
  ${asset_id} in ${hourly_asset_usage_date_filter.asset_id} ;;
  group_label: "Fleet"
  label: "Asset Info with All Time Hours"
  case_sensitive: no
  persist_for: "10 minutes"

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

  # join: last_asset_location {
  #   type: left_outer
  #   relationship: one_to_one
  #   sql_on: ${assets.asset_id} = ${last_asset_location.asset_id} ;;
  # }

  join: asset_last_location {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_last_location.asset_id} ;;
  }

  # join: states {
  #   type: left_outer
  #   relationship: many_to_one
  #   sql_on: ${states.state_id} = ${last_asset_location.state_id} ;;
  # }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
  }

  join: hourly_asset_usage_date_filter {
    type: left_outer
    relationship: many_to_one
    sql_on: ${hourly_asset_usage_date_filter.asset_id} = ${assets.asset_id} ;;
  }

  join: categories {
    type: left_outer
    relationship: many_to_one
    sql_on: ${categories.category_id} = ${assets.category_id} ;;
  }

  join: asset_status_key_values {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_status_key_values.asset_id} = ${assets.asset_id} ;;
  }

  join: out_of_lock {
    type: inner
    relationship: one_to_one
    sql_on: ${out_of_lock.asset_id} = ${assets.asset_id} ;;
  }

  join: trackers {
    type: left_outer
    relationship: one_to_many
    sql_on: ${trackers.tracker_id} = ${assets.tracker_id} ;;
  }

  join: tracker_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracker_types.tracker_type_id} = ${trackers.tracker_type_id} ;;
  }

  join: tracking_diagnostic_codes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracking_diagnostic_codes.asset_id} = ${assets.asset_id} AND ${tracking_diagnostic_codes.cleared_raw} is null ;;
  }

  join: tracking_obd_dtc_codes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracking_obd_dtc_codes.tracking_obd_dtc_code_id} = ${tracking_diagnostic_codes.tracking_obd_dtc_code_id} ;;
  }

  join: tracking_diagnostic_and_obd_codes {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracking_diagnostic_and_obd_codes.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

  join: photos {
    type: left_outer
    relationship: one_to_one
    sql_on: ${photos.photo_id} = ${assets.photo_id} ;;
  }

  join: trip_details {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_utilization_by_day_date_filter.asset_id} = ${trip_details.asset_id} ;;
    # sql_on: ${assets.asset_id} = ${trip_details.asset_id} ;;
  }

  join: asset_total_hours_odometer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_total_hours_odometer.asset_id} ;;
  }

  join: asset_current_geofence {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_current_geofence.asset_id} ;;
  }

  join: asset_odometer_based_off_date_selection {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_odometer_based_off_date_selection.asset_id} ;;
  }

  join: asset_hours_based_off_date_selection {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_hours_based_off_date_selection.asset_id} ;;
  }

  join: asset_utilization_by_day_date_filter {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_utilization_by_day_date_filter.asset_id} = ${hourly_asset_usage_date_filter.asset_id} ;;
  }

  join: utilization_by_day {
    type: left_outer
    relationship: many_to_one
    sql_on: ${utilization_by_day.day} = ${asset_utilization_by_day_date_filter.date} ;;
  }

  join: asset_last_location_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${asset_last_location_history.asset_id} = ${assets.asset_id} ;;
  }

  join: trackers_mapping {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers_mapping.asset_id} = ${assets.asset_id} ;;
  }

}
