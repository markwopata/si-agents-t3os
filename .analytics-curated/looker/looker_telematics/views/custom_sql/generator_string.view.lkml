view: generator_string {

  derived_table: {
    sql:
     SELECT  askv.asset_id as asset_id, askv.NAME as name, askv.value as value, askv._ES_UPDATE_TIMESTAMP as last_updated, mkt.name as serviced_by,
   astat.street||', '||astat.city||', '||astat.zip_code AS current_location, comp.name as customer_name,
    CASE
WHEN askv.name = 'diesel_particles_filter_regen_status' and left(askv.value,1) = '0' THEN 'Normal'
WHEN askv.name = 'diesel_particles_filter_regen_status' and left(askv.value,1) = '1' THEN 'Alert'
WHEN askv.name = 'diesel_particles_filter_regen_status' and left(askv.value,1) = '2' THEN 'Alert'
WHEN askv.name = 'diesel_particles_filter_regen_status' and left(askv.value,1) = '3' THEN 'Warning' ELSE 'No Value' END AS regen_status,
CASE
WHEN askv.name = 'is_being_hauled' and askv.value = 'true' THEN 'Yes'
WHEN askv.name = 'is_being_hauled' and askv.value = 'false' THEN 'No'
ELSE 'No Value' END AS is_being_hauled,
CASE
WHEN askv.name = 'engine_active' and askv.value = 'true' THEN 'Yes'
WHEN askv.name = 'engine_active' and askv.value = 'false' THEN 'No'
ELSE 'No Value' END AS engine_active
from ES_WAREHOUSE.public.assets AS a
left join ES_WAREHOUSE.public.equipment_makes AS mk
on a.equipment_make_id = mk.equipment_make_id
left join ES_WAREHOUSE.public.equipment_classes_models_xref AS x
on a.equipment_model_id = x.equipment_model_id
left join ES_WAREHOUSE.public.equipment_models AS md
on a.equipment_model_id = md.equipment_model_id
left join ES_WAREHOUSE.public.equipment_classes AS cl
ON x.equipment_class_id = cl.equipment_class_id
LEFT JOIN ES_WAREHOUSE."PUBLIC".asset_status_key_values AS askv
ON a.asset_id = askv.ASSET_ID
left join ES_WAREHOUSE."PUBLIC".markets as mkt
on a.market_id = mkt.market_id
left join ES_WAREHOUSE."PUBLIC".asset_statuses as astat
on a.asset_id = astat.asset_id
left join ES_WAREHOUSE."PUBLIC".companies as comp
on a.company_id = comp.company_id
WHERE cl.company_division_id = 2
and askv.NAME in (
'asset_health_status',
'asset_inventory_status',
'asset_rental_status',
'battery_potential_power_input',
'battery_voltage',
'coolant_level_percent',
'coolant_temperature',
'diesel_exhaust_fluid_level',
'diesel_particles_filter_regen_status',
'engine_active',
'engine_oil_pressure',
'engine_rpm',
'generator_average_ac_frequency',
'generator_average_ac_rms_current',
'generator_average_line_line_ac_rms_voltage',
'generator_average_line_neutral_ac_rms_voltage',
'generator_excitation_field_current',
'generator_frequency_selection',
'generator_governing_speed_command',
'generator_overall_power_factor',
'generator_overall_power_factor_lagging',
'generator_phase_a_ac_frequency',
'generator_phase_a_ac_rms_current',
'generator_phase_a_line_neutral_ac_rms_voltage',
'generator_phase_ab_line_line_ac_rms_voltage',
'generator_phase_b_ac_rms_current',
'generator_phase_c_ac_rms_current',
'generator_total_apparent_power',
'generator_total_reactive_power',
'generator_total_real_power',
'hdop',
'hours',
'is_being_hauled',
'key_switch_battery_potential',
'last_address_update_timestamp',
'last_checkin_timestamp',
'last_engine_off_timestamp',
'last_engine_on_timestamp',
'last_location_timestamp',
'last_trip_end_timestamp',
'last_trip_type',
'location',
'odometer',
'rssi',
'speed',
'start_stale_gps_fix_timestamp',
'total_fuel_used_liters'
)
                         ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.name ;;
  }

  dimension: value {
    type: string
    sql: ${TABLE}.value ;;
  }

  dimension: last_updated {
    type: date_time
    sql: ${TABLE}.last_updated ;;
  }

  dimension: regen_status {
    type: string
    sql: ${TABLE}.regen_status ;;
  }

  dimension: is_being_hauled {
    type: string
    sql: ${TABLE}.is_being_hauled ;;
  }

  dimension: engine_active {
    type: string
    sql: ${TABLE}.engine_active ;;
  }

  dimension: serviced_by {
    type: string
    sql: ${TABLE}.serviced_by ;;
  }

  dimension: current_location {
    type: string
    sql: ${TABLE}.current_location ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}.customer_name ;;
  }


}
