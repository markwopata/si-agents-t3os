{{ config(
    materialized='table'
    , unique_key=['tracker_key']
) }}

-- only keep vbus events that occur after the tracker installation date for logical accuracy
WITH vbus_event_validation AS (
    SELECT 
        tracker_key
        , tracker_source
        , tracker_id_trackersdb
        , tracker_id_esdb
        , tracker_device_serial
        , tracker_date_installed
        , IFF(tracker_date_installed < average_fuel_economy_latest_event_time, 
              average_fuel_economy, 
              NULL
            ) AS average_fuel_economy
        , IFF(tracker_date_installed < average_fuel_economy_latest_event_time, 
              average_fuel_economy_latest_event_time, 
              NULL
            ) AS average_fuel_economy_latest_event_time
        , IFF(tracker_date_installed < battery_voltage_latest_event_time, 
              battery_voltage, 
              NULL
            ) AS battery_voltage
        , IFF(tracker_date_installed < battery_voltage_latest_event_time, 
              battery_voltage_latest_event_time, 
              NULL
            ) AS battery_voltage_latest_event_time
        , IFF(tracker_date_installed < coolant_level_percent_latest_event_time, 
              coolant_level_percent, 
              NULL
            ) AS coolant_level_percent
        , IFF(tracker_date_installed < coolant_level_percent_latest_event_time, 
              coolant_level_percent_latest_event_time, 
              NULL
            ) AS coolant_level_percent_latest_event_time
        , IFF(tracker_date_installed < coolant_temperature_latest_event_time, 
              coolant_temperature, 
              NULL
            ) AS coolant_temperature
        , IFF(tracker_date_installed < coolant_temperature_latest_event_time, 
              coolant_temperature_latest_event_time, 
              NULL
            ) AS coolant_temperature_latest_event_time
        , IFF(tracker_date_installed < engine_active_latest_event_time, 
              engine_active, 
              NULL
            ) AS engine_active
        , IFF(tracker_date_installed < engine_active_latest_event_time, 
              engine_active_latest_event_time, 
              NULL
            ) AS engine_active_latest_event_time
        , IFF(tracker_date_installed < engine_oil_pressure_latest_event_time, 
              engine_oil_pressure, 
              NULL
            ) AS engine_oil_pressure
        , IFF(tracker_date_installed < engine_oil_pressure_latest_event_time, 
              engine_oil_pressure_latest_event_time, 
              NULL
            ) AS engine_oil_pressure_latest_event_time
        , IFF(tracker_date_installed < engine_oil_temperature_latest_event_time, 
              engine_oil_temperature, 
              NULL
            ) AS engine_oil_temperature
        , IFF(tracker_date_installed < engine_oil_temperature_latest_event_time, 
              engine_oil_temperature_latest_event_time, 
              NULL
            ) AS engine_oil_temperature_latest_event_time
        , IFF(tracker_date_installed < engine_rpm_latest_event_time, 
              engine_rpm, 
              NULL
            ) AS engine_rpm
        , IFF(tracker_date_installed < engine_rpm_latest_event_time, 
              engine_rpm_latest_event_time, 
              NULL
            ) AS engine_rpm_latest_event_time
        , IFF(tracker_date_installed < fuel_consumption_rate_gph_latest_event_time, 
              fuel_consumption_rate_gph, 
              NULL
            ) AS fuel_consumption_rate_gph
        , IFF(tracker_date_installed < fuel_consumption_rate_gph_latest_event_time, 
              fuel_consumption_rate_gph_latest_event_time, 
              NULL
            ) AS fuel_consumption_rate_gph_latest_event_time
        , IFF(tracker_date_installed < fuel_economy_instantaneous_mpg_latest_event_time, 
              fuel_economy_instantaneous_mpg, 
              NULL
            ) AS fuel_economy_instantaneous_mpg
        , IFF(tracker_date_installed < fuel_economy_instantaneous_mpg_latest_event_time, 
              fuel_economy_instantaneous_mpg_latest_event_time, 
              NULL
            ) AS fuel_economy_instantaneous_mpg_latest_event_time
        , IFF(tracker_date_installed < fuel_level_latest_event_time, 
              fuel_level, 
              NULL
            ) AS fuel_level
        , IFF(tracker_date_installed < fuel_level_latest_event_time, 
              fuel_level_latest_event_time, 
              NULL
            ) AS fuel_level_latest_event_time
        , IFF(tracker_date_installed < max_speed_mph_latest_event_time, 
              max_speed_mph, 
              NULL
            ) AS max_speed_mph
        , IFF(tracker_date_installed < max_speed_mph_latest_event_time, 
              max_speed_mph_latest_event_time, 
              NULL
            ) AS max_speed_mph_latest_event_time
        , IFF(tracker_date_installed < odometer_latest_event_time, 
              odometer, 
              NULL
            ) AS odometer
        , IFF(tracker_date_installed < odometer_latest_event_time, 
              odometer_latest_event_time, 
              NULL
            ) AS odometer_latest_event_time
        , IFF(tracker_date_installed < total_engine_hours_latest_event_time, 
              total_engine_hours, 
              NULL
            ) AS total_engine_hours
        , IFF(tracker_date_installed < total_engine_hours_latest_event_time, 
              total_engine_hours_latest_event_time, 
              NULL
            ) AS total_engine_hours_latest_event_time
        , IFF(tracker_date_installed < total_fuel_used_liters_latest_event_time, 
              total_fuel_used_liters, 
              NULL
            ) AS total_fuel_used_liters
        , IFF(tracker_date_installed < total_fuel_used_liters_latest_event_time, 
              total_fuel_used_liters_latest_event_time, 
              NULL
            ) AS total_fuel_used_liters_latest_event_time
        , IFF(tracker_date_installed < total_idle_fuel_used_liters_latest_event_time, 
              total_idle_fuel_used_liters, 
              NULL
            ) AS total_idle_fuel_used_liters
        , IFF(tracker_date_installed < total_idle_fuel_used_liters_latest_event_time, 
              total_idle_fuel_used_liters_latest_event_time, 
              NULL
            ) AS total_idle_fuel_used_liters_latest_event_time
        , IFF(tracker_date_installed < total_idle_hours_latest_event_time, 
              total_idle_hours, 
              NULL
            ) AS total_idle_hours
        , IFF(tracker_date_installed < total_idle_hours_latest_event_time, 
              total_idle_hours_latest_event_time, 
              NULL
            ) AS total_idle_hours_latest_event_time
        , IFF(tracker_date_installed < vbus_speed_latest_event_time, 
              vbus_speed, 
              NULL
            ) AS vbus_speed
        , IFF(tracker_date_installed < vbus_speed_latest_event_time, 
              vbus_speed_latest_event_time, 
              NULL
            ) AS vbus_speed_latest_event_time
        , IFF(tracker_date_installed < vin_latest_event_time, 
              vin, 
              NULL
            ) AS vin
        , IFF(tracker_date_installed < vin_latest_event_time, 
              vin_latest_event_time, 
              NULL
            ) AS vin_latest_event_time
    FROM {{ ref('int_tracker_latest_vbus_events') }}
)

SELECT 
    tracker_key
    , (
        (CASE WHEN average_fuel_economy IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN battery_voltage IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN coolant_level_percent IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN coolant_temperature IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN engine_active IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN engine_oil_pressure IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN engine_oil_temperature IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN engine_rpm IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN fuel_consumption_rate_gph IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN fuel_economy_instantaneous_mpg IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN fuel_level IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN max_speed_mph IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN odometer IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN total_engine_hours IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN total_fuel_used_liters IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN total_idle_fuel_used_liters IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN total_idle_hours IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN vbus_speed IS NOT NULL THEN 1 ELSE 0 END) +
        (CASE WHEN vin IS NOT NULL THEN 1 ELSE 0 END)
    ) AS event_count
    , average_fuel_economy
    , average_fuel_economy_latest_event_time
    , battery_voltage
    , battery_voltage_latest_event_time
    , coolant_level_percent
    , coolant_level_percent_latest_event_time
    , coolant_temperature
    , coolant_temperature_latest_event_time
    , engine_active
    , engine_active_latest_event_time
    , engine_oil_pressure
    , engine_oil_pressure_latest_event_time
    , engine_oil_temperature
    , engine_oil_temperature_latest_event_time
    , engine_rpm
    , engine_rpm_latest_event_time
    , fuel_consumption_rate_gph
    , fuel_consumption_rate_gph_latest_event_time
    , fuel_economy_instantaneous_mpg
    , fuel_economy_instantaneous_mpg_latest_event_time
    , fuel_level
    , fuel_level_latest_event_time
    , max_speed_mph
    , max_speed_mph_latest_event_time
    , odometer
    , odometer_latest_event_time
    , total_engine_hours
    , total_engine_hours_latest_event_time
    , total_fuel_used_liters
    , total_fuel_used_liters_latest_event_time
    , total_idle_fuel_used_liters
    , total_idle_fuel_used_liters_latest_event_time
    , total_idle_hours
    , total_idle_hours_latest_event_time
    , vbus_speed
    , vbus_speed_latest_event_time
    , vin
    , vin_latest_event_time
FROM vbus_event_validation
WHERE event_count > 0