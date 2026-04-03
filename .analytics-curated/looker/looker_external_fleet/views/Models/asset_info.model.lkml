connection: "es_warehouse"


include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: assets {
  sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
  OR
  ${asset_id} in ${rental_asset_list_10_days.asset_id} ;;
  group_label: "Fleet"
  label: "Total Own/Rented(Rentals Last 10 Days) Asset Count "
  case_sensitive: no
  persist_for: "10 minutes"

  join: rental_asset_list_10_days {
    type: left_outer
    relationship: many_to_one
    sql_on: ${rental_asset_list_10_days.asset_id} = ${assets.asset_id} ;;
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
  #   sql_on: ${states.state_id} = ${trip_details_history.state_id} ;;
  # }

  join: organizations {
    type: left_outer
    relationship: one_to_many
    sql_on: ${organization_asset_xref.organization_id} = ${organizations.organization_id} ;;
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

  join: trackers_from_trackers_db {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trackers_from_trackers_db.device_serial} = ${trackers.device_serial} ;;
  }

  join: tracker_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracker_types.tracker_type_id} = coalesce(${trackers.tracker_type_id},${trackers_from_trackers_db.tracker_type_id}) ;;
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
    relationship: many_to_many
    sql_on: ${tracking_diagnostic_and_obd_codes.asset_id} = ${assets.asset_id} ;;
  }

  # Trip log details and trip detail history will need to be commented out once the new trip log report is ready.
  join: trip_log_details {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trip_log_details.asset_id} = ${assets.asset_id} ;;
  }

  join: trip_detail_history {
    type: left_outer
    relationship: many_to_one
    sql_on: ${trip_detail_history.asset_id} = ${assets.asset_id} ;;
  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

  }
