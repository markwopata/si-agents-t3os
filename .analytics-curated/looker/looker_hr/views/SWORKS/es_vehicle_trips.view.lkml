view: es_vehicle_trips {

    derived_table: {
      sql:
SELECT trips.*,
       tax.trip_classification_type_id,
       types.name AS trip_classification_type_name,
       tax.date_approved_by_driver
  FROM sworks.vehicle_usage_tracker.es_vehicle_trips trips
       INNER JOIN sworks.vehicle_usage_tracker.trip_tax_classifications tax
                  ON trips.trip_id = tax.trip_id
       INNER JOIN sworks.vehicle_usage_tracker.trip_classification_types types
                  ON tax.trip_classification_type_id = types.trip_classification_type_id
      ;;
    }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_updated {
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
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: end_address {
    type: string
    sql: CONCAT(${end_address_street}, ', ', ${end_address_city}, ', ', ${end_address_state_abbreviation}, ' ', ${end_address_zip}) ;;
  }

  dimension: end_address_city {
    type: string
    sql: ${TABLE}."END_ADDRESS_CITY" ;;
  }

  dimension: end_address_state_abbreviation {
    type: string
    sql: ${TABLE}."END_ADDRESS_STATE_ABBREVIATION" ;;
  }

  dimension: end_address_street {
    type: string
    sql: ${TABLE}."END_ADDRESS_STREET" ;;
  }

  dimension: end_address_zip {
    type: string
    sql: ${TABLE}."END_ADDRESS_ZIP" ;;
  }

  dimension: end_location {
    type: string
    sql: ${TABLE}."END_LOCATION" ;;
  }

  dimension_group: end_timestamp {
    label: "Trip End"
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
    sql: CAST(${TABLE}."END_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: start_address {
    type: string
    sql: CONCAT(${start_address_street}, ', ', ${start_address_city}, ', ', ${start_address_state_abbreviation}, ' ', ${start_address_zip}) ;;
  }

  dimension: start_address_city {
    type: string
    sql: ${TABLE}."START_ADDRESS_CITY" ;;
  }

  dimension: start_address_state_abbreviation {
    type: string
    sql: ${TABLE}."START_ADDRESS_STATE_ABBREVIATION" ;;
  }

  dimension: start_address_street {
    type: string
    sql: ${TABLE}."START_ADDRESS_STREET" ;;
  }

  dimension: start_address_zip {
    type: string
    sql: ${TABLE}."START_ADDRESS_ZIP" ;;
  }

  dimension: start_location {
    type: string
    sql: ${TABLE}."START_LOCATION" ;;
  }

  dimension_group: start_timestamp {
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
    sql: CAST(${TABLE}."START_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: trip_distance_miles {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
  }

  dimension: trip_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  # These dimensions are coming from trip_tax_classifications
  dimension: trip_classification_type_id {
    type: number
    # 1 - Business, 2 - Personal
    sql: ${TABLE}."TRIP_CLASSIFICATION_TYPE_ID" ;;
  }
  dimension: trip_classification_type_name {
    type: string
    sql: ${TABLE}."TRIP_CLASSIFICATION_TYPE_NAME" ;;
  }
  dimension_group: date_approved_by_driver {
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
    sql: CAST(${TABLE}."DATE_APPROVED_BY_DRIVER" AS TIMESTAMP_NTZ) ;;
  }
  # ----------

  # - - - - - MEASURES - - - - -

  measure: total_trip_miles {
    type: sum
    value_format_name: decimal_2
    sql: ${trip_distance_miles} ;;
    drill_fields: [trip_detail*]
  }

  measure: total_business_miles {
    type: sum
    value_format_name: decimal_2
    sql: ${trip_distance_miles} ;;
    filters: [trip_classification_type_id: "1"]
    drill_fields: [trip_detail*]
  }

  measure: total_personal_miles {
    type: sum
    value_format_name: decimal_2
    sql: ${trip_distance_miles} ;;
    filters: [trip_classification_type_id: "2"]
    drill_fields: [trip_detail*]
  }

  measure: personal_use_percentage {
    type: number
    value_format_name: percent_2
    sql: ${total_personal_miles} / NULLIFZERO(${total_miles}) ;;
  }

  measure: total_miles {
    type: number
    value_format_name: decimal_2
    sql: ${total_business_miles} + ${total_personal_miles} ;;
    drill_fields: [trip_detail*]
  }

  measure: personal_use_fuel {
    type: number
    value_format_name: decimal_2
    sql: ${total_personal_miles} * 0.055 ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  # - - - - - SETS - - - - -

  set: trip_detail {
    fields: [
      end_timestamp_date,
      trip_tax_classifications.date_approved_by_driver_date,
      trip_id,
      users.full_name,
      asset_id,
      start_address,
      end_address,
      trip_distance_miles,
      trip_classification_types.name
    ]
  }

}
