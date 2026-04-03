{{ config(
    materialized='table'
    , unique_key=['tracker_key']
) }}

WITH trackers AS (
    SELECT
         tracker_key
        , tracker_source
        , tracker_id_trackersdb
        , tracker_id_esdb
        , tracker_device_serial
        , tracker_date_installed
    FROM {{ ref("platform", "dim_trackers") }}
),

    vbus_events AS (
        SELECT 
            t.tracker_key
            , t.tracker_source
            , t.tracker_id_trackersdb
            , t.tracker_id_esdb
            , t.tracker_device_serial
            , t.tracker_date_installed
            , afe.average_fuel_economy
            , afe.start_source_event_time_clean   AS average_fuel_economy_latest_event_time
            , bv.battery_voltage
            , bv.start_source_event_time_clean    AS battery_voltage_latest_event_time
            , clp.coolant_level_percent
            , clp.start_source_event_time_clean   AS coolant_level_percent_latest_event_time
            , ct.coolant_temperature
            , ct.start_source_event_time_clean    AS coolant_temperature_latest_event_time
            , ea.engine_active
            , ea.start_source_event_time_clean    AS engine_active_latest_event_time
            , eop.engine_oil_pressure
            , eop.start_source_event_time_clean   AS engine_oil_pressure_latest_event_time
            , eot.engine_oil_temperature
            , eot.start_source_event_time_clean   AS engine_oil_temperature_latest_event_time
            , erpm.engine_rpm
            , erpm.start_source_event_time_clean  AS engine_rpm_latest_event_time
            , fcr.fuel_consumption_rate_gph
            , fcr.start_source_event_time_clean   AS fuel_consumption_rate_gph_latest_event_time
            , fei.fuel_economy_instantaneous_mpg
            , fei.start_source_event_time_clean   AS fuel_economy_instantaneous_mpg_latest_event_time
            , fl.fuel_level
            , fl.start_source_event_time_clean    AS fuel_level_latest_event_time
            , msm.max_speed_mph
            , msm.start_source_event_time_clean   AS max_speed_mph_latest_event_time
            , od.odometer
            , od.start_source_event_time_clean    AS odometer_latest_event_time
            , teh.total_engine_hours
            , teh.start_source_event_time_clean   AS total_engine_hours_latest_event_time
            , tful.total_fuel_used_liters
            , tful.start_source_event_time_clean  AS total_fuel_used_liters_latest_event_time
            , tiful.total_idle_fuel_used_liters
            , tiful.start_source_event_time_clean AS total_idle_fuel_used_liters_latest_event_time
            , tih.total_idle_hours
            , tih.start_source_event_time_clean   AS total_idle_hours_latest_event_time
            , vs.vbus_speed
            , vs.start_source_event_time_clean    AS vbus_speed_latest_event_time
            , vin.vin
            , vin.start_source_event_time_clean   AS vin_latest_event_time
        FROM trackers t
        LEFT JOIN {{ ref('platform', 'engine_rpm_pit') }} erpm
            ON t.tracker_device_serial = erpm.device_serial
            AND erpm.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'total_fuel_used_liters_pit') }} tful
            ON t.tracker_device_serial = tful.device_serial
            AND tful.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'total_idle_fuel_used_liters_pit') }} tiful
            ON t.tracker_device_serial = tiful.device_serial
            AND tiful.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'total_idle_hours_pit') }} tih
            ON t.tracker_device_serial = tih.device_serial
            AND tih.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'battery_voltage_pit') }} bv
            ON t.tracker_device_serial = bv.device_serial
            AND bv.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'engine_active_pit') }} ea
            ON t.tracker_device_serial = ea.device_serial
            AND ea.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'coolant_temperature_pit') }} ct
            ON t.tracker_device_serial = ct.device_serial
            AND ct.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'fuel_level_pit') }} fl
            ON t.tracker_device_serial = fl.device_serial
            AND fl.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'fuel_economy_instantaneous_mpg_pit') }} fei
            ON t.tracker_device_serial = fei.device_serial
            AND fei.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'engine_oil_pressure_pit') }} eop
            ON t.tracker_device_serial = eop.device_serial
            AND eop.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'coolant_level_percent_pit') }} clp
            ON t.tracker_device_serial = clp.device_serial
            AND clp.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'total_engine_hours_pit') }} teh
            ON t.tracker_device_serial = teh.device_serial
            AND teh.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'average_fuel_economy_pit') }} afe
            ON t.tracker_device_serial = afe.device_serial
            AND afe.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'fuel_consumption_rate_gph_pit') }} fcr
            ON t.tracker_device_serial = fcr.device_serial
            AND fcr.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'engine_oil_temperature_pit') }} eot
            ON t.tracker_device_serial = eot.device_serial
            AND eot.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'max_speed_mph_pit') }} msm
            ON t.tracker_device_serial = msm.device_serial
            AND msm.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'odometer_pit') }} od
            ON t.tracker_device_serial = od.device_serial
            AND od.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'vbus_speed_pit') }} vs
            ON t.tracker_device_serial = vs.device_serial
            AND vs.most_current_record = TRUE
        LEFT JOIN {{ ref('platform', 'vin_pit') }} vin
            ON t.tracker_device_serial = vin.device_serial
            AND vin.most_current_record = TRUE
)

SELECT 
    tracker_key
    , tracker_source
    , tracker_id_trackersdb
    , tracker_id_esdb
    , tracker_device_serial
    , tracker_date_installed
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
FROM vbus_events
WHERE event_count > 0 