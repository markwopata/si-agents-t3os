view: generators_charts {

  derived_table: {
    sql:
      SELECT ASSET_ID AS ASSET_ID, NAME AS NAME, VALUE AS VALUE , VALUE_TIMESTAMP AS TIMESTAMP
FROM ES_WAREHOUSE.history.asset_status_key_values_history
WHERE VALUE_TIMESTAMP   >= DATE(current_timestamp, '-1 days')
AND NAME in (
'generator_total_apparent_power',
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

  dimension: asset_id {
    type: number
    sql: ${TABLE}.ASSET_ID ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}.NAME ;;
  }

  dimension: value {
    type: number
    sql: ${TABLE}.VALUE ;;
  }

  dimension: timestamp {
    type: date_time
    sql: ${TABLE}.TIMESTAMP ;;
  }

  measure: def_level {
    type: average
    filters: {
      field: name
      value: "diesel_exhaust_fluid_level"
    }
    sql: ${value};;
  }


  measure: total_apparent_power {
    type: average
    filters: {
      field: name
      value: "generator_total_apparent_power"   }

    sql: ${value}/1000 ;;
  }

  measure: total_real_power {
    type: average
    filters: {
      field: name
      value: "generator_total_real_power"
    }

    sql: ${value}/1000 ;;
  }

  measure: total_reactive_power {
    type: average
    filters: {
      field:name
      value: "generator_total_reactive_power"
    }

    sql: ${value}/1000 ;;
  }

  measure: coolant_temperature {
    type: average
    filters: {
      field: name
      value: "coolant_temperature"
    }

    sql: ${value} ;;
  }

  measure: total_fuel_used_gallons {
    type: average
    filters: {
      field: name
      value: "total_fuel_used_liters"
    }
    sql: ${value} * 0.264172 ;;
  }

  measure: fuel_consumption_rate_gph {
    type: average
    filters: {
      field: name
      value: "fuel_consumption_rate_gph"
    }

    sql: ${value};;
  }

  measure: generator_average_ac_rms_current {
    type: average
    filters: {
      field: name
      value: "generator_average_ac_rms_current"
    }

    sql: ${value};;
  }

  measure: generator_phase_c_ac_rms_current {
    type: average
    filters: {
      field: name
      value: "generator_phase_c_ac_rms_current"
    }

    sql: ${value};;
  }

  measure: generator_excitation_field_current {
    type: average
    filters: {
      field: name
      value: "generator_excitation_field_current"
    }

    sql: ${value};;
  }

  measure: generator_phase_a_ac_rms_current {
    type: average
    filters: {
      field: name
      value: "generator_phase_a_ac_rms_current"
    }

    sql: ${value};;
  }

  measure: generator_phase_b_ac_rms_current {
    type: average
    filters: {
      field: name
      value: "generator_phase_b_ac_rms_current"
    }

    sql: ${value};;
  }

  measure: battery_voltage {
    type: average
    filters: {
      field: name
      value: "battery_voltage"
    }

    sql: ${value};;
  }

  measure: generator_average_line_line_ac_rms_voltage {
    type: average
    filters: {
      field:  name
      value: "generator_average_line_line_ac_rms_voltage"
    }

    sql: ${value};;
  }

  measure: generator_average_line_neutral_ac_rms_voltage {
    type: average
    filters: {
      field: name
      value: "generator_average_line_neutral_ac_rms_voltage"
    }

    sql: ${value};;
  }

  measure: generator_phase_a_line_neutral_ac_rms_voltage {
    type: average
    filters: {
      field: name
      value: "generator_phase_a_line_neutral_ac_rms_voltage"
    }

    sql: ${value};;
  }

  measure: generator_phase_ab_line_line_ac_rms_voltage {
    type: average
    filters: {
      field: name
      value: "generator_phase_ab_line_line_ac_rms_voltage"
    }

    sql: ${value};;
  }

  measure: generator_average_ac_frequency {
    type: average
    filters: {
      field: name
      value: "generator_average_ac_frequency"
    }

    sql: ${value};;
  }

  measure: generator_phase_a_ac_frequency {
    type: average
    filters: {
      field: name
      value: "generator_phase_a_ac_frequency"
    }

    sql: ${value};;
  }

  measure: engine_oil_pressure {
    type: average
    filters: {
      field: name
      value: "engine_oil_pressure"
    }

    sql: ${value};;
  }

  measure: engine_rpm {
    type: average
    filters: {
      field: name
      value: "engine_rpm"
    }

    sql: ${value};;
  }



  }
