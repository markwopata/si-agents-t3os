connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: assets {
  sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
  OR
  ${asset_id} in ${rental_asset_list_10_days.asset_id} ;;
  # (rental_asset_list(27961, convert_timezone('America/Chicago', 'UTC', current_date::timestamp_ntz), convert_timezone('America/Chicago', 'UTC', current_date::timestamp_ntz), 'America/Chicago')) ;;
  # sql_always_where: ${trips.trip_type_id} in (1,2,5,7) and ${asset_id} in (select asset_id from table(assetlist(5688))) ;;
  # ${asset_id} in (select asset_id from table(assetlist('{{ _user_attributes['user_id'] }}'::numeric)))
  group_label: "Fleet"
  label: "Asset Info with Hours for Last 10 Days"
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

  join: asset_hours_last_seven_days {
    #Using this to only bring in small data set
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_hours_last_seven_days.asset_id} = ${assets.asset_id} ;;
  }

  join: rental_asset_list_10_days {
    #Using this to only bring in small data set
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_asset_list_10_days.asset_id} = ${asset_hours_last_seven_days.asset_id}
    AND ${asset_hours_last_seven_days.start_range_date} BETWEEN ${rental_asset_list_10_days.modified_start_date_date} AND ${rental_asset_list_10_days.end_date_date} ;;
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

  join: suspect_parameter_numbers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${suspect_parameter_numbers.suspect_parameter_number_id} = ${tracking_diagnostic_codes.suspect_parameter_number} ;;
  }

  join: failure_mode_identifiers {
    type: left_outer
    relationship: many_to_one
    sql_on: ${failure_mode_identifiers.failure_mode_identifier_id} = ${tracking_diagnostic_codes.failure_mode_identifier} ;;
  }
}
