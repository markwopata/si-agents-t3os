select
     tracker_key
    , event_count
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
    
from {{ ref('fact_tracker_vbus_events') }}