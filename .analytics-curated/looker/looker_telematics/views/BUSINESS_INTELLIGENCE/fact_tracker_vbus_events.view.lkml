view: fact_tracker_vbus_events {
  derived_table: {
    sql:
      SELECT
         DT.TRACKER_DEVICE_SERIAL,
         DT.TRACKER_ID_ESDB,
         DT.TRACKER_ID_TRACKERSDB,
         FTVE.*
      FROM BUSINESS_INTELLIGENCE.GOLD.FACT_TRACKER_VBUS_EVENTS FTVE
           LEFT JOIN PLATFORM.GOLD.DIM_TRACKERS DT
                     ON DT.TRACKER_KEY = FTVE.TRACKER_KEY;;
  }

  dimension: tracker_device_serial {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRACKER_DEVICE_SERIAL" ;;
  }
  dimension: tracker_id_esdb {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRACKER_ID_ESDB" ;;
  }
  dimension: tracker_id_trackersdb {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRACKER_ID_TRACKERSDB" ;;
  }
  dimension: average_fuel_economy {
    type: number
    sql: ${TABLE}."AVERAGE_FUEL_ECONOMY" ;;
  }
  dimension_group: average_fuel_economy_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."AVERAGE_FUEL_ECONOMY_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: battery_voltage {
    type: number
    sql: ${TABLE}."BATTERY_VOLTAGE" ;;
  }
  dimension_group: battery_voltage_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."BATTERY_VOLTAGE_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: coolant_level_percent {
    type: number
    sql: ${TABLE}."COOLANT_LEVEL_PERCENT" ;;
  }
  dimension_group: coolant_level_percent_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."COOLANT_LEVEL_PERCENT_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: coolant_temperature {
    type: number
    sql: ${TABLE}."COOLANT_TEMPERATURE" ;;
  }
  dimension_group: coolant_temperature_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."COOLANT_TEMPERATURE_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: engine_active {
    type: yesno
    sql: ${TABLE}."ENGINE_ACTIVE" ;;
  }
  dimension_group: engine_active_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ENGINE_ACTIVE_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: engine_oil_pressure {
    type: number
    sql: ${TABLE}."ENGINE_OIL_PRESSURE" ;;
  }
  dimension_group: engine_oil_pressure_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ENGINE_OIL_PRESSURE_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: engine_oil_temperature {
    type: number
    sql: ${TABLE}."ENGINE_OIL_TEMPERATURE" ;;
  }
  dimension_group: engine_oil_temperature_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ENGINE_OIL_TEMPERATURE_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: engine_rpm {
    type: number
    sql: ${TABLE}."ENGINE_RPM" ;;
  }
  dimension_group: engine_rpm_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ENGINE_RPM_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: event_count {
    label: "VBUS event count"
    description: "Count of VBUS events logged since the most recent tracker install date"
    type: number
    #drill_fields: [vbus_details*] --Drill fields in Looker seem to be broken as of 12/12/2025 PB
    sql: ${TABLE}."EVENT_COUNT" ;;
  }
  dimension: fuel_consumption_rate_gph {
    type: number
    sql: ${TABLE}."FUEL_CONSUMPTION_RATE_GPH" ;;
  }
  dimension_group: fuel_consumption_rate_gph_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."FUEL_CONSUMPTION_RATE_GPH_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: fuel_economy_instantaneous_mpg {
    type: number
    sql: ${TABLE}."FUEL_ECONOMY_INSTANTANEOUS_MPG" ;;
  }
  dimension_group: fuel_economy_instantaneous_mpg_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."FUEL_ECONOMY_INSTANTANEOUS_MPG_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: fuel_level {
    type: number
    sql: ${TABLE}."FUEL_LEVEL" ;;
  }
  dimension_group: fuel_level_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."FUEL_LEVEL_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: max_speed_mph {
    type: number
    sql: ${TABLE}."MAX_SPEED_MPH" ;;
  }
  dimension_group: max_speed_mph_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."MAX_SPEED_MPH_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }
  dimension_group: odometer_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."ODOMETER_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: total_engine_hours {
    type: number
    sql: ${TABLE}."TOTAL_ENGINE_HOURS" ;;
  }
  dimension_group: total_engine_hours_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TOTAL_ENGINE_HOURS_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: total_fuel_used_liters {
    type: number
    sql: ${TABLE}."TOTAL_FUEL_USED_LITERS" ;;
  }
  dimension_group: total_fuel_used_liters_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TOTAL_FUEL_USED_LITERS_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: total_idle_fuel_used_liters {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOTAL_IDLE_FUEL_USED_LITERS" ;;
  }
  dimension_group: total_idle_fuel_used_liters_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TOTAL_IDLE_FUEL_USED_LITERS_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: total_idle_hours {
    type: number
    value_format_name: id
    sql: ${TABLE}."TOTAL_IDLE_HOURS" ;;
  }
  dimension_group: total_idle_hours_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TOTAL_IDLE_HOURS_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: tracker_key {
    type: string
    sql: ${TABLE}."TRACKER_KEY" ;;
  }
  dimension: vbus_speed {
    type: number
    sql: ${TABLE}."VBUS_SPEED" ;;
  }
  dimension_group: vbus_speed_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."VBUS_SPEED_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }
  dimension_group: vin_latest_event {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."VIN_LATEST_EVENT_TIME" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
  }
  set: vbus_details {
    fields: [
    average_fuel_economy,
    average_fuel_economy_latest_event_raw,
    battery_voltage,
    battery_voltage_latest_event_raw,
    coolant_level_percent,
    coolant_level_percent_latest_event_raw,
    coolant_temperature,
    coolant_temperature_latest_event_raw,
    engine_active,
    engine_active_latest_event_raw,
    engine_oil_pressure,
    engine_oil_pressure_latest_event_raw,
    engine_oil_temperature,
    engine_oil_temperature_latest_event_raw,
    engine_rpm,
    engine_rpm_latest_event_raw,
    fuel_consumption_rate_gph,
    fuel_consumption_rate_gph_latest_event_raw,
    fuel_economy_instantaneous_mpg,
    fuel_economy_instantaneous_mpg_latest_event_raw,
    fuel_level,
    fuel_level_latest_event_raw,
    max_speed_mph,
    max_speed_mph_latest_event_raw,
    odometer,
    odometer_latest_event_raw,
    total_engine_hours,
    total_engine_hours_latest_event_raw,
    total_fuel_used_liters,
    total_fuel_used_liters_latest_event_raw,
    total_idle_fuel_used_liters,
    total_idle_fuel_used_liters_latest_event_raw,
    total_idle_hours,
    total_idle_hours_latest_event_raw,
    tracker_key,
    vbus_speed,
    vbus_speed_latest_event_raw,
    vin,
    vin_latest_event_raw]
  }
}
