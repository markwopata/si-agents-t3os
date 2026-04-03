view: generator_summary {

  derived_table: {
    sql:
      SELECT  COALESCE(a.serial_number,a.vin) AS serial_vin, a.YEAR AS asset_year, a.make AS asset_make, a.model AS asset_model,
a.description asset_description, cl.company_division_id AS company_division_id, m.name as serviced_by,
cl.NAME AS equipment_class_name, a.company_id AS company_id, askv.asset_status_key_value_id AS asset_status_key_value_id ,
askv.asset_id AS asset_id, askv.asset_status_value_type_id AS asset_status_value_type_id, askv.NAME AS asset_status_value_name,
askv.value AS asset_status_value, askv.value_timestamp AS value_timestamp, askv.updated AS updated,
askv."_ES_UPDATE_TIMESTAMP" AS created_timestamp,  em.email as email_address
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
left join ES_WAREHOUSE."PUBLIC".markets as m
on a.inventory_branch_id = m.market_id
left join ANALYTICS."PUBLIC".MARKET_REGION_XWALK as xwalk
on  m.market_id = xwalk.market_id
left join ANALYTICS."PUBLIC".FRONT_EMAILS as em
on xwalk.abbreviation = em.market_abbreviation
WHERE cl.company_division_id = 2
and askv.name in ('generator_total_apparent_power',
'generator_total_real_power',
'generator_total_reactive_power',
'coolant_temperature','total_fuel_used_liters',
'fuel_consumption_rate_gph',
'generator_average_ac_rms_current',
'generator_phase_c_ac_rms_current',
'generator_excitation_field_current',
'generator_phase_a_ac_rms_current',
'generator_phase_b_ac_rms_current',
'battery_voltage',
'generator_average_line_line_ac_rms_voltage',
'generator_average_line_neutral_ac_rms_voltage',
'generator_phase_a_line_neutral_ac_rms_voltage',
'generator_phase_ab_line_line_ac_rms_voltage',
'generator_average_ac_frequency',
'generator_phase_a_ac_frequency','engine_oil_pressure','engine_rpm','diesel_exhaust_fluid_level')
                         ;;
  }

  dimension: serial_vin {
    type: string
    sql: ${TABLE}.serial_vin ;;
  }

  dimension: serviced_by {
    type: string
    sql: ${TABLE}.serviced_by ;;
  }

  dimension:asset_year {
    type: number
    sql: ${TABLE}.asset_year ;;
  }

  dimension:asset_model {
    type: string
    sql: ${TABLE}.asset_model ;;
  }

  dimension:email_address {
    type: string
    sql: ${TABLE}.email_address ;;
  }

  dimension:asset_make {
    type: string
    sql: ${TABLE}.asset_make ;;
  }

  dimension:asset_description {
    type: string
    sql: ${TABLE}.asset_description ;;
  }

  dimension: company_division_id {
    type: string
    sql: ${TABLE}.company_division_id ;;
  }

  dimension: equipment_class_name{
    type: string
    sql: ${TABLE}.equipment_class_name ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}.company_id ;;
  }

  dimension: asset_status_key_value_id {
    type: number
    sql: ${TABLE}.asset_status_key_value_id ;;
  }

  dimension: asset_id {
    type: number
    html:  <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/166?Asset%20ID={{ asset_id._filterable_value | url_encode }}" target="_blank">{{ asset_id._value }}</a></font></u>;;
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_id_generator {
    type: number
    html:  <font color="blue "><u><a href = "https://equipmentshare.looker.com/dashboards/257?Asset%20ID={{ asset_id._filterable_value | url_encode }}" target="_blank">{{ asset_id._value }}</a></font></u>;;
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_status_value_type_id {
    type: number
    sql: ${TABLE}.asset_status_value_type_id ;;
  }

  dimension: asset_status_value_name {
    type: string
    sql: ${TABLE}.asset_status_value_name ;;
  }

  dimension: asset_status_value {
    type: number
    sql: ${TABLE}.asset_status_value ;;
  }

  dimension: value_timestamp {
    type: date_time
    sql: ${TABLE}.value_timestamp ;;
  }

  dimension: updated {
    type: date_time
    sql: ${TABLE}.updated ;;
  }

  dimension: created_timestamp {
    type: date_time
    sql: ${TABLE}.created_timestamp ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}.source ;;
  }

  measure: total_apparent_power {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_total_apparent_power"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value}/1000 ;;
  }

  measure: total_real_power {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_total_real_power"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value}/1000 ;;
  }

  measure: total_reactive_power {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_total_reactive_power"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value}/1000 ;;
  }

  measure: coolant_temperature {
    type: average
    filters: {
      field: asset_status_value_name
      value: "coolant_temperature"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value} ;;
  }

  measure: total_fuel_used_gallons {
    type: average
    filters: {
      field: asset_status_value_name
      value: "total_fuel_used_liters"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value} * 0.264172 ;;
  }

  measure: fuel_consumption_rate_gph {
    type: average
    filters: {
      field: asset_status_value_name
      value: "fuel_consumption_rate_gph"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_average_ac_rms_current {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_average_ac_rms_current"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_phase_c_ac_rms_current {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_phase_c_ac_rms_current"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_excitation_field_current {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_excitation_field_current"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_phase_a_ac_rms_current {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_phase_a_ac_rms_current"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_phase_b_ac_rms_current {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_phase_b_ac_rms_current"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: battery_voltage {
    type: average
    filters: {
      field: asset_status_value_name
      value: "battery_voltage"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_average_line_line_ac_rms_voltage {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_average_line_line_ac_rms_voltage"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_average_line_neutral_ac_rms_voltage {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_average_line_neutral_ac_rms_voltage"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_phase_a_line_neutral_ac_rms_voltage {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_phase_a_line_neutral_ac_rms_voltage"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_phase_ab_line_line_ac_rms_voltage {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_phase_ab_line_line_ac_rms_voltage"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_average_ac_frequency {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_average_ac_frequency"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: generator_phase_a_ac_frequency {
    type: average
    filters: {
      field: asset_status_value_name
      value: "generator_phase_a_ac_frequency"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: engine_oil_pressure {
    type: average
    filters: {
      field: asset_status_value_name
      value: "engine_oil_pressure"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: engine_rpm {
    type: average
    filters: {
      field: asset_status_value_name
      value: "engine_rpm"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  measure: def_level {
    type: average
    filters: {
      field: asset_status_value_name
      value: "diesel_exhaust_fluid_level"
    }
    drill_fields: [generators_details*]
    sql: ${asset_status_value};;
  }

  set: generators_details {
    fields: [asset_id, serial_vin]
  }

}
