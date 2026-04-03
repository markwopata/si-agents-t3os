view: vehicle_tracking_trip_data {
  sql_table_name: "LOOKER"."VEHICLE_TRACKING_TRIP_DATA" ;;

  dimension: approval {
    type: date_raw
    sql: ${TABLE}."APPROVAL_DATE" ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
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
  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }
  dimension: lower_bound {
    type: date_raw
    sql: ${TABLE}."LOWER_BOUND" ;;
  }
  dimension: report_end {
    type: date_raw
    sql: ${TABLE}."REPORT_END" ;;
  }
  dimension: report_start {
    type: date_raw
    sql: ${TABLE}."REPORT_START" ;;
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
  dimension: trip_classification {
    type: string
    sql: ${TABLE}."TRIP_CLASSIFICATION" ;;
  }
  dimension: trip {
    type: date_raw
    sql: ${TABLE}."TRIP_DATE" ;;
  }
  dimension: trip_distance_miles {
    type: number
    sql: ${TABLE}."TRIP_DISTANCE_MILES" ;;
  }
  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }
  dimension: trip_tax_classification_id {
    type: number
    sql: ${TABLE}."TRIP_TAX_CLASSIFICATION_ID" ;;
  }
  dimension: upper_bound {
    type: date_raw
    sql: ${TABLE}."UPPER_BOUND" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [full_name]
  }
}
