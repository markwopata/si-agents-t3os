connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: assets {
  sql_always_where: ${asset_id} in (select asset_id from table(assetlist({{ _user_attributes['user_id'] }}::numeric)))
  OR
  ${asset_id} in (
      SELECT
  coalesce(ea.asset_id, r.asset_id) as asset_id
FROM
es_warehouse.public.orders o
join es_warehouse.public.users u on u.user_id = o.user_id
join es_warehouse.public.rentals r on r.order_id = o.order_id
left join es_warehouse.public.equipment_assignments ea on ea.rental_id = r.rental_id and ea.end_date is null
join es_warehouse.public.rental_types rt on rt.rental_type_id = r.rental_type_id
WHERE
    r.rental_status_id = 5
AND
    u.company_id
        IN (
        SELECT u.company_id
        FROM es_warehouse.public.users u
        WHERE u.user_id = {{ _user_attributes['user_id'] }}::numeric
        )
AND (
    u.user_id =
        CASE
            WHEN (
                SELECT security_level_id
                FROM es_warehouse.public.users u
                WHERE u.user_id = {{ _user_attributes['user_id'] }}::numeric
            )
            IN (1, 2)
            THEN u.user_id
            ELSE {{ _user_attributes['user_id'] }}::numeric
            END
            OR
            r.rental_id in (
            select r.rental_id
              from es_warehouse.public.rentals r
              join es_warehouse.public.orders o on o.order_id = r.order_id
              join es_warehouse.public.rental_location_assignments la on la.rental_id = r.rental_id
              join es_warehouse.public.geofences g on g.location_id = la.location_id
              join es_warehouse.public.organization_geofence_xref x on x.geofence_id = g.geofence_id
              join es_warehouse.public.organization_user_xref ux on ux.organization_id = x.organization_id
              where ux.user_id = {{ _user_attributes['user_id'] }}::numeric
            )
    )
    )
  ;;
  group_label: "Fleet"
  label: "Asset Rent/Own Health Info"
  case_sensitive: no
  persist_for: "30 minutes"

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

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

  join: asset_last_location {
    type: left_outer
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_last_location.asset_id} ;;
  }

  join: current_fuel_level {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${current_fuel_level.asset_id} ;;
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

  join: cameras {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.camera_id} = ${cameras.camera_id} ;;
  }

  join: tracker_state_cache {
    type: left_outer
    relationship: one_to_one
    sql_on: ${trackers.tracker_id} = ${tracker_state_cache.tracker_id} ;;
  }

  join: asset_battery_prev_week_trend {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_battery_prev_week_trend.asset_id} ;;
  }

  join: battery_voltage_types {
    type: left_outer
    relationship: many_to_one
    sql_on: ${assets.battery_voltage_type_id} = ${battery_voltage_types.battery_voltage_type_id} ;;
  }

  join: latest_asset_battery_voltage {
    type: left_outer
    relationship: one_to_one
    sql_on: ${latest_asset_battery_voltage.asset_id} = ${asset_last_location.asset_id} ;;
  }

  join: asset_filter_regen_status {
    type: inner
    relationship: one_to_one
    sql_on: ${asset_filter_regen_status.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_last_parked {
    type: inner
    relationship: one_to_one
    sql_on: ${assets.asset_id} = ${asset_last_parked.asset_id} ;;
  }

  join: tracker_unplugged_status {
    type: left_outer
    relationship: one_to_one
    sql_on: ${tracker_unplugged_status.asset_id} = ${assets.asset_id} ;;
  }

  join: cameras_last_contact_and_request {
    type: inner
    relationship: one_to_one
    sql_on: ${cameras_last_contact_and_request.camera_id} = ${cameras.camera_id}  ;;
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

  join: service_branch {
    from: markets
    type: left_outer
    relationship: many_to_one
    sql_on: ${service_branch.market_id} = ${assets.service_branch_id} ;;
  }

  join: last_gps_contact {
    type: left_outer
    relationship: one_to_one
    sql_on: ${last_gps_contact.asset_id} = ${assets.asset_id} ;;
  }

  join: maintenance_groups {
    type: left_outer
    relationship: many_to_one
    sql_on: ${maintenance_groups.maintenance_group_id} = ${assets.maintenance_group_id} ;;
  }

  join: tracker_install_date {
    type: left_outer
    relationship: many_to_one
    sql_on: ${tracker_install_date.tracker_id} = ${assets.tracker_id} ;;
  }

  join: asset_odometer_hour_information {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_odometer_hour_information.asset_id} = ${assets.asset_id} ;;
  }

  join: asset_camera_assignments {
    type: left_outer
    relationship: many_to_one
    sql_on: ${asset_camera_assignments.asset_id} = ${assets.asset_id} AND ${asset_camera_assignments.date_uninstalled_date} is null ;;
  }

}

explore: asset_run_time_with_battery_voltage_fuel_level {
  group_label: "Fleet"
  label: "Utilization with Battery Voltage and Fuel Level"
  case_sensitive: no
  persist_for: "10 minutes"

  join: assets {
    type: inner
    relationship: many_to_one
    sql_on: ${assets.asset_id} = ${asset_run_time_with_battery_voltage_fuel_level.asset_id} ;;
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

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${assets.inventory_branch_id} ;;
  }

  }
