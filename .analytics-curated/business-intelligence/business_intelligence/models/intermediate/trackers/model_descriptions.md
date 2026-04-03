{% docs int_tracker_latest_vbus_events %}
This consolidates all VBUS-specific events and the most recent event timestamp for each event. 
Only trackers with at least one VBUS event are included.

VBUS is a communication protocol used to connect and control devices. The protocol enables the communication between different devices and manufacturers. VBUS allows devices to be connected in a network and to exchange data, such as measurement values, configuration parameters and status information.
List of VBUS events:
- average_fuel_economy
- battery_voltage
- coolant_level_percent
- coolant_temperature
- engine_rpm
- engine_active
- engine_oil_pressure
- engine_oil_temperature
- fuel_consumption_rate_gph
- fuel_economy_instantaneous_mpg
- fuel_level
- max_speed_mph
- odometer
- total_engine_hours
- total_fuel_used_liters
- total_idle_fuel_used_liters
- total_idle_hours
- vbus_speed
- vin
{% enddocs %}