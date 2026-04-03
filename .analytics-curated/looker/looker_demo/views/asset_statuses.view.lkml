view: asset_statuses {
  sql_table_name: "PUBLIC"."ASSET_STATUSES"
    ;;
  drill_fields: [asset_status_id]

  dimension: asset_status_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ASSET_STATUS_ID" ;;
  }

  dimension: asset_health_status {
    type: string
    sql: ${TABLE}."ASSET_HEALTH_STATUS" ;;
  }

  dimension_group: asset_health_status_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."ASSET_HEALTH_STATUS_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_inventory_status {
    type: string
    sql: ${TABLE}."ASSET_INVENTORY_STATUS" ;;
  }

  dimension_group: asset_inventory_status_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."ASSET_INVENTORY_STATUS_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_rental_status {
    type: string
    sql: ${TABLE}."ASSET_RENTAL_STATUS" ;;
  }

  dimension_group: asset_rental_status_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."ASSET_RENTAL_STATUS_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: average_fuel_economy {
    type: number
    sql: ${TABLE}."AVERAGE_FUEL_ECONOMY" ;;
  }

  dimension_group: average_fuel_economy_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."AVERAGE_FUEL_ECONOMY_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: battery_potential_power_input {
    type: number
    sql: ${TABLE}."BATTERY_POTENTIAL_POWER_INPUT" ;;
  }

  dimension: battery_state_of_charge {
    type: number
    sql: ${TABLE}."BATTERY_STATE_OF_CHARGE" ;;
  }

  dimension_group: battery_state_of_charge_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."BATTERY_STATE_OF_CHARGE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: battery_voltage {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE" ;;
  }

  dimension_group: battery_voltage_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."BATTERY_VOLTAGE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: ble_low_battery {
    type: yesno
    sql: ${TABLE}."BLE_LOW_BATTERY" ;;
  }

  dimension_group: ble_low_battery_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."BLE_LOW_BATTERY_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: charger_plugged_in {
    type: yesno
    sql: ${TABLE}."CHARGER_PLUGGED_IN" ;;
  }

  dimension_group: charger_plugged_in_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."CHARGER_PLUGGED_IN_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: coolant_level_percent {
    type: number
    sql: ${TABLE}."COOLANT_LEVEL_PERCENT" ;;
  }

  dimension_group: coolant_level_percent_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."COOLANT_LEVEL_PERCENT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: coolant_temperature {
    type: number
    sql: ${TABLE}."COOLANT_TEMPERATURE" ;;
  }

  dimension_group: coolant_temperature_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."COOLANT_TEMPERATURE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}."COUNTY" ;;
  }

  dimension: current_trip_id {
    type: number
    sql: ${TABLE}."CURRENT_TRIP_ID" ;;
  }

  dimension: diesel_exhaust_fluid_level {
    type: number
    sql: ${TABLE}."DIESEL_EXHAUST_FLUID_LEVEL" ;;
  }

  dimension_group: diesel_exhaust_fluid_level_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DIESEL_EXHAUST_FLUID_LEVEL_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: diesel_particles_filter_regen_status {
    type: number
    sql: ${TABLE}."DIESEL_PARTICLES_FILTER_REGEN_STATUS" ;;
  }

  dimension_group: diesel_particles_filter_regen_status_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DIESEL_PARTICLES_FILTER_REGEN_STATUS_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: direction {
    type: number
    sql: ${TABLE}."DIRECTION" ;;
  }

  dimension_group: driver_match_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DRIVER_MATCH_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: driver_user_id {
    type: number
    sql: ${TABLE}."DRIVER_USER_ID" ;;
  }

  dimension: emergency_air_status {
    type: string
    sql: ${TABLE}."EMERGENCY_AIR_STATUS" ;;
  }

  dimension: engine_active {
    type: yesno
    sql: ${TABLE}."ENGINE_ACTIVE" ;;
  }

  dimension: engine_oil_pressure {
    type: number
    sql: ${TABLE}."ENGINE_OIL_PRESSURE" ;;
  }

  dimension_group: engine_oil_pressure_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."ENGINE_OIL_PRESSURE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: engine_oil_temperature {
    type: number
    sql: ${TABLE}."ENGINE_OIL_TEMPERATURE" ;;
  }

  dimension_group: engine_oil_temperature_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."ENGINE_OIL_TEMPERATURE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: engine_rpm {
    type: number
    sql: ${TABLE}."ENGINE_RPM" ;;
  }

  dimension_group: engine_rpm_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."ENGINE_RPM_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: engine_speed_governor_droop {
    type: number
    sql: ${TABLE}."ENGINE_SPEED_GOVERNOR_DROOP" ;;
  }

  dimension: engine_speed_governor_gain_adjust {
    type: number
    sql: ${TABLE}."ENGINE_SPEED_GOVERNOR_GAIN_ADJUST" ;;
  }

  dimension: foot_switch {
    type: yesno
    sql: ${TABLE}."FOOT_SWITCH" ;;
  }

  dimension_group: foot_switch_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FOOT_SWITCH_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: fuel_consumption_rate_gph {
    type: number
    sql: ${TABLE}."FUEL_CONSUMPTION_RATE_GPH" ;;
  }

  dimension_group: fuel_consumption_rate_gph_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FUEL_CONSUMPTION_RATE_GPH_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: fuel_economy_instantaneous_mpg {
    type: number
    sql: ${TABLE}."FUEL_ECONOMY_INSTANTANEOUS_MPG" ;;
  }

  dimension_group: fuel_economy_instantaneous_mpg_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FUEL_ECONOMY_INSTANTANEOUS_MPG_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: fuel_economy_lifetime_mpg {
    type: number
    sql: ${TABLE}."FUEL_ECONOMY_LIFETIME_MPG" ;;
  }

  dimension_group: fuel_economy_lifetime_mpg_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FUEL_ECONOMY_LIFETIME_MPG_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: fuel_level {
    type: number
    sql: ${TABLE}."FUEL_LEVEL" ;;
  }

  dimension_group: fuel_level_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."FUEL_LEVEL_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: generator_alternator_efficiency {
    type: number
    sql: ${TABLE}."GENERATOR_ALTERNATOR_EFFICIENCY" ;;
  }

  dimension: generator_average_ac_frequency {
    type: number
    sql: ${TABLE}."GENERATOR_AVERAGE_AC_FREQUENCY" ;;
  }

  dimension: generator_average_ac_rms_current {
    type: number
    sql: ${TABLE}."GENERATOR_AVERAGE_AC_RMS_CURRENT" ;;
  }

  dimension: generator_average_line_line_ac_rms_voltage {
    type: number
    sql: ${TABLE}."GENERATOR_AVERAGE_LINE_LINE_AC_RMS_VOLTAGE" ;;
  }

  dimension: generator_average_line_neutral_ac_rms_voltage {
    type: number
    sql: ${TABLE}."GENERATOR_AVERAGE_LINE_NEUTRAL_AC_RMS_VOLTAGE" ;;
  }

  dimension: generator_circuit_breaker_status {
    type: number
    sql: ${TABLE}."GENERATOR_CIRCUIT_BREAKER_STATUS" ;;
  }

  dimension: generator_control_not_in_automatic_start_state {
    type: number
    sql: ${TABLE}."GENERATOR_CONTROL_NOT_IN_AUTOMATIC_START_STATE" ;;
  }

  dimension: generator_excitation_field_current {
    type: number
    sql: ${TABLE}."GENERATOR_EXCITATION_FIELD_CURRENT" ;;
  }

  dimension: generator_frequency_selection {
    type: number
    sql: ${TABLE}."GENERATOR_FREQUENCY_SELECTION" ;;
  }

  dimension: generator_governing_speed_command {
    type: number
    sql: ${TABLE}."GENERATOR_GOVERNING_SPEED_COMMAND" ;;
  }

  dimension: generator_not_ready_to_automatically_parallel_state {
    type: number
    sql: ${TABLE}."GENERATOR_NOT_READY_TO_AUTOMATICALLY_PARALLEL_STATE" ;;
  }

  dimension: generator_overall_power_factor {
    type: number
    sql: ${TABLE}."GENERATOR_OVERALL_POWER_FACTOR" ;;
  }

  dimension: generator_overall_power_factor_lagging {
    type: number
    sql: ${TABLE}."GENERATOR_OVERALL_POWER_FACTOR_LAGGING" ;;
  }

  dimension: generator_phase_a_ac_frequency {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_A_AC_FREQUENCY" ;;
  }

  dimension: generator_phase_a_ac_rms_current {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_A_AC_RMS_CURRENT" ;;
  }

  dimension: generator_phase_a_apparent_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_A_APPARENT_POWER" ;;
  }

  dimension: generator_phase_a_line_neutral_ac_rms_voltage {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_A_LINE_NEUTRAL_AC_RMS_VOLTAGE" ;;
  }

  dimension: generator_phase_a_power_factor {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_A_POWER_FACTOR" ;;
  }

  dimension: generator_phase_a_reactive_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_A_REACTIVE_POWER" ;;
  }

  dimension: generator_phase_a_real_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_A_REAL_POWER" ;;
  }

  dimension: generator_phase_ab_line_line_ac_rms_voltage {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_AB_LINE_LINE_AC_RMS_VOLTAGE" ;;
  }

  dimension: generator_phase_b_ac_frequency {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_B_AC_FREQUENCY" ;;
  }

  dimension: generator_phase_b_ac_rms_current {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_B_AC_RMS_CURRENT" ;;
  }

  dimension: generator_phase_b_apparent_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_B_APPARENT_POWER" ;;
  }

  dimension: generator_phase_b_line_neutral_ac_rms_voltage {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_B_LINE_NEUTRAL_AC_RMS_VOLTAGE" ;;
  }

  dimension: generator_phase_b_power_factor {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_B_POWER_FACTOR" ;;
  }

  dimension: generator_phase_b_reactive_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_B_REACTIVE_POWER" ;;
  }

  dimension: generator_phase_b_real_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_B_REAL_POWER" ;;
  }

  dimension: generator_phase_bc_line_line_ac_rms_voltage {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_BC_LINE_LINE_AC_RMS_VOLTAGE" ;;
  }

  dimension: generator_phase_c_ac_frequency {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_C_AC_FREQUENCY" ;;
  }

  dimension: generator_phase_c_ac_rms_current {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_C_AC_RMS_CURRENT" ;;
  }

  dimension: generator_phase_c_apparent_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_C_APPARENT_POWER" ;;
  }

  dimension: generator_phase_c_line_neutral_ac_rms_voltage {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_C_LINE_NEUTRAL_AC_RMS_VOLTAGE" ;;
  }

  dimension: generator_phase_c_power_factor {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_C_POWER_FACTOR" ;;
  }

  dimension: generator_phase_c_reactive_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_C_REACTIVE_POWER" ;;
  }

  dimension: generator_phase_c_real_power {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_C_REAL_POWER" ;;
  }

  dimension: generator_phase_ca_line_line_ac_rms_voltage {
    type: number
    sql: ${TABLE}."GENERATOR_PHASE_CA_LINE_LINE_AC_RMS_VOLTAGE" ;;
  }

  dimension: generator_total_apparent_power {
    type: number
    sql: ${TABLE}."GENERATOR_TOTAL_APPARENT_POWER" ;;
  }

  dimension: generator_total_kvar_hours_export {
    type: number
    sql: ${TABLE}."GENERATOR_TOTAL_KVAR_HOURS_EXPORT" ;;
  }

  dimension: generator_total_kw_hours_export {
    type: number
    sql: ${TABLE}."GENERATOR_TOTAL_KW_HOURS_EXPORT" ;;
  }

  dimension: generator_total_kw_hours_import {
    type: number
    sql: ${TABLE}."GENERATOR_TOTAL_KW_HOURS_IMPORT" ;;
  }

  dimension: generator_total_percent_kw {
    type: number
    sql: ${TABLE}."GENERATOR_TOTAL_PERCENT_KW" ;;
  }

  dimension: generator_total_reactive_power {
    type: number
    sql: ${TABLE}."GENERATOR_TOTAL_REACTIVE_POWER" ;;
  }

  dimension: generator_total_real_power {
    type: number
    sql: ${TABLE}."GENERATOR_TOTAL_REAL_POWER" ;;
  }

  dimension: hdop {
    type: number
    sql: ${TABLE}."HDOP" ;;
  }

  dimension_group: hdop_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."HDOP_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hours {
    type: number
    sql: ${TABLE}."HOURS" ;;
  }

  dimension: is_being_hauled {
    type: yesno
    sql: ${TABLE}."IS_BEING_HAULED" ;;
  }

  dimension_group: is_being_hauled_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."IS_BEING_HAULED_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: is_ble_node {
    type: yesno
    sql: ${TABLE}."IS_BLE_NODE" ;;
  }

  dimension: is_locked {
    type: yesno
    sql: ${TABLE}."IS_LOCKED" ;;
  }

  dimension: is_pending_keypad_code_update {
    type: yesno
    sql: ${TABLE}."IS_PENDING_KEYPAD_CODE_UPDATE" ;;
  }

  dimension_group: is_pending_keypad_code_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."IS_PENDING_KEYPAD_CODE_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: is_tracker_awake {
    type: yesno
    sql: ${TABLE}."IS_TRACKER_AWAKE" ;;
  }

  dimension: key_switch_battery_potential {
    type: number
    sql: ${TABLE}."KEY_SWITCH_BATTERY_POTENTIAL" ;;
  }

  dimension: key_switch_state {
    type: yesno
    sql: ${TABLE}."KEY_SWITCH_STATE" ;;
  }

  dimension_group: key_switch_state_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."KEY_SWITCH_STATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_address_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_ADDRESS_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_checkin_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_CHECKIN_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_engine_off_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_ENGINE_OFF_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_engine_on_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_ENGINE_ON_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_keypad_message_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_KEYPAD_MESSAGE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_location_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_LOCATION_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_tracker_sleep_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_TRACKER_SLEEP_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_tracker_wake_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_TRACKER_WAKE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: last_trip_end_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_TRIP_END_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: last_trip_id {
    type: number
    sql: ${TABLE}."LAST_TRIP_ID" ;;
  }

  dimension: last_trip_type {
    type: string
    sql: ${TABLE}."LAST_TRIP_TYPE" ;;
  }

  dimension_group: last_valid_tpms_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LAST_VALID_TPMS_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: latest_start_driving_incident_id {
    type: number
    sql: ${TABLE}."LATEST_START_DRIVING_INCIDENT_ID" ;;
  }

  dimension: latest_stop_driving_incident_id {
    type: number
    sql: ${TABLE}."LATEST_STOP_DRIVING_INCIDENT_ID" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension_group: lock_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."LOCK_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: machine_off_level {
    type: yesno
    sql: ${TABLE}."MACHINE_OFF_LEVEL" ;;
  }

  dimension_group: machine_off_level_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."MACHINE_OFF_LEVEL_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }

  dimension_group: out_of_lock_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."OUT_OF_LOCK_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: outrigger_status {
    type: string
    sql: ${TABLE}."OUTRIGGER_STATUS" ;;
  }

  dimension_group: outrigger_status_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."OUTRIGGER_STATUS_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: overload {
    type: yesno
    sql: ${TABLE}."OVERLOAD" ;;
  }

  dimension_group: overload_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."OVERLOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: platform_stowed {
    type: yesno
    sql: ${TABLE}."PLATFORM_STOWED" ;;
  }

  dimension_group: platform_stowed_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."PLATFORM_STOWED_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rcl_bridge_on_tracks {
    type: yesno
    sql: ${TABLE}."RCL_BRIDGE_ON_TRACKS" ;;
  }

  dimension: rcl_hydraulic_fluid_low {
    type: yesno
    sql: ${TABLE}."RCL_HYDRAULIC_FLUID_LOW" ;;
  }

  dimension: rcl_hydraulic_high_temp {
    type: yesno
    sql: ${TABLE}."RCL_HYDRAULIC_HIGH_TEMP" ;;
  }

  dimension: recent_driver_name {
    type: string
    sql: ${TABLE}."RECENT_DRIVER_NAME" ;;
  }

  dimension_group: recent_driver_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."RECENT_DRIVER_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: recent_driver_user_id {
    type: number
    sql: ${TABLE}."RECENT_DRIVER_USER_ID" ;;
  }

  dimension: requested_engine_control_mode {
    type: number
    sql: ${TABLE}."REQUESTED_ENGINE_CONTROL_MODE" ;;
  }

  dimension: rssi {
    type: number
    sql: ${TABLE}."RSSI" ;;
  }

  dimension_group: rssi_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."RSSI_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: service_brakes_status {
    type: string
    sql: ${TABLE}."SERVICE_BRAKES_STATUS" ;;
  }

  dimension: speed {
    type: number
    sql: ${TABLE}."SPEED" ;;
  }

  dimension_group: start_idle_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."START_IDLE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: start_stale_gps_fix_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."START_STALE_GPS_FIX_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: state_id {
    type: number
    sql: ${TABLE}."STATE_ID" ;;
  }

  dimension: stop_lamp_power_status {
    type: string
    sql: ${TABLE}."STOP_LAMP_POWER_STATUS" ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: total_fuel_used_liters {
    type: number
    sql: ${TABLE}."TOTAL_FUEL_USED_LITERS" ;;
  }

  dimension: total_idle_fuel_used_liters {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOTAL_IDLE_FUEL_USED_LITERS" ;;
  }

  dimension: total_idle_seconds {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOTAL_IDLE_SECONDS" ;;
  }

  dimension: tpms_high_pressure_status {
    type: string
    sql: ${TABLE}."TPMS_HIGH_PRESSURE_STATUS" ;;
  }

  dimension: tpms_high_temperature_status {
    type: string
    sql: ${TABLE}."TPMS_HIGH_TEMPERATURE_STATUS" ;;
  }

  dimension: tpms_low_pressure_status {
    type: string
    sql: ${TABLE}."TPMS_LOW_PRESSURE_STATUS" ;;
  }

  dimension_group: unlock_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."UNLOCK_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: unplugged {
    type: yesno
    sql: ${TABLE}."UNPLUGGED" ;;
  }

  dimension_group: unplugged_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."UNPLUGGED_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: utility_average_ac_frequency {
    type: number
    sql: ${TABLE}."UTILITY_AVERAGE_AC_FREQUENCY" ;;
  }

  dimension: utility_average_line_line_ac_rms_voltage {
    type: number
    sql: ${TABLE}."UTILITY_AVERAGE_LINE_LINE_AC_RMS_VOLTAGE" ;;
  }

  dimension: utility_average_line_neutral_ac_rms_voltage {
    type: number
    sql: ${TABLE}."UTILITY_AVERAGE_LINE_NEUTRAL_AC_RMS_VOLTAGE" ;;
  }

  dimension: utility_circuit_breaker_status {
    type: number
    sql: ${TABLE}."UTILITY_CIRCUIT_BREAKER_STATUS" ;;
  }

  dimension: utility_phase_a_ac_frequency {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_A_AC_FREQUENCY" ;;
  }

  dimension: utility_phase_a_line_neutral_ac_rms_voltage {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_A_LINE_NEUTRAL_AC_RMS_VOLTAGE" ;;
  }

  dimension: utility_phase_ab_line_line_ac_rms_voltage {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_AB_LINE_LINE_AC_RMS_VOLTAGE" ;;
  }

  dimension: utility_phase_b_ac_frequency {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_B_AC_FREQUENCY" ;;
  }

  dimension: utility_phase_b_line_neutral_ac_rms_voltage {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_B_LINE_NEUTRAL_AC_RMS_VOLTAGE" ;;
  }

  dimension: utility_phase_bc_line_line_ac_rms_voltage {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_BC_LINE_LINE_AC_RMS_VOLTAGE" ;;
  }

  dimension: utility_phase_c_ac_frequency {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_C_AC_FREQUENCY" ;;
  }

  dimension: utility_phase_c_line_neutral_ac_rms_voltage {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_C_LINE_NEUTRAL_AC_RMS_VOLTAGE" ;;
  }

  dimension: utility_phase_ca_line_line_ac_rms_voltage {
    type: number
    sql: ${TABLE}."UTILITY_PHASE_CA_LINE_LINE_AC_RMS_VOLTAGE" ;;
  }

  dimension: uts_pitch {
    type: number
    sql: ${TABLE}."UTS_PITCH" ;;
  }

  dimension_group: uts_pitch_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."UTS_PITCH_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: uts_roll {
    type: number
    sql: ${TABLE}."UTS_ROLL" ;;
  }

  dimension_group: uts_roll_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."UTS_ROLL_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: on_rent_status_count {
    type: count
    filters: [asset_inventory_status: "On Rent"]
    drill_fields: [asset_detail*]
  }

  measure: hard_down_status_count {
    type: count
    filters: [asset_inventory_status: "Hard Down"]
    drill_fields: [asset_detail*]
  }

  measure: soft_down_status_count {
    type: count
    filters: [asset_inventory_status: "Soft Down"]
    drill_fields: [asset_detail*]
  }

  measure: needs_inspection_status_count {
    type: count
    filters: [asset_inventory_status: "Needs Inspection"]
    drill_fields: [asset_detail*]
  }

  measure: ready_to_rent_status_count {
    type: count
    filters: [asset_inventory_status: "Ready To Rent"]
    drill_fields: [asset_detail*]
  }

  measure: pending_return_status_count {
    type: count
    filters: [asset_inventory_status: "Pending Return"]
    drill_fields: [asset_detail*]
  }

  measure: make_ready_status_count {
    type: count
    filters: [asset_inventory_status: "Make Ready"]
    drill_fields: [asset_detail*]
  }

  measure: non_rented_assets_count {
    type: count
    filters: [asset_inventory_status: "Hard Down",
      asset_inventory_status: "Soft Down",
      asset_inventory_status: "Needs Inspection",
      asset_inventory_status: "Ready To Rent",
      asset_inventory_status: "Pending Return",
      asset_inventory_status: "Make Ready"]
  }

  measure: non_rent_assets {
    type: number
    sql: ${non_rented_assets_count}*-1 ;;
  }

  set: asset_detail {
    fields: [asset_id,
      demo_assets_sv.asset_class,
      demo_assets_sv.category_name,
      demo_assets_sv.make,
      demo_assets_sv.model,
      demo_assets_sv.description,
      demo_assets_sv.serial_number]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      asset_status_id,
      driver_name,
      recent_driver_name,
      assets.asset_id,
      assets.name,
      assets.custom_name,
      assets.driver_name
    ]
  }
}
