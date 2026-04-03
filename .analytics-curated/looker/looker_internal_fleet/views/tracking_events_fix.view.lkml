view: tracking_events_fix {
  sql_table_name: "PUBLIC"."TRACKING_EVENTS_FIX"
    ;;

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
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: ble_signal_power {
    type: number
    sql: ${TABLE}."BLE_SIGNAL_POWER" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}."COUNTY" ;;
  }

  dimension: direction {
    type: number
    sql: ${TABLE}."DIRECTION" ;;
  }

  dimension: engine_active {
    type: yesno
    sql: ${TABLE}."ENGINE_ACTIVE" ;;
  }

  dimension_group: gps_fix_timestamp {
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
    sql: CAST(${TABLE}."GPS_FIX_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hdop {
    type: number
    sql: ${TABLE}."HDOP" ;;
  }

  dimension: location_lat {
    type: number
    sql: ${TABLE}."LOCATION_LAT" ;;
  }

  dimension: location_lon {
    type: number
    sql: ${TABLE}."LOCATION_LON" ;;
  }

  dimension: gps_location {
    type: string
    sql: concat('https://www.google.com/maps/search/?api=1&query=', ${location_lat}, ',' ,${location_lon}) ;;
  }

  dimension_group: report_timestamp {
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
    sql: CAST(${TABLE}."REPORT_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rssi {
    type: number
    sql: ${TABLE}."RSSI" ;;
  }

  dimension: satellites {
    type: number
    sql: ${TABLE}."SATELLITES" ;;
  }

  dimension: speed {
    type: number
    sql: ${TABLE}."SPEED" ;;
  }

  dimension: state_abb {
    type: string
    sql: ${TABLE}."STATE_ABB" ;;
  }

  dimension: state_id {
    type: number
    sql: ${TABLE}."STATE_ID" ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: tracker_id {
    type: number
    sql: ${TABLE}."TRACKER_ID" ;;
  }

  dimension: tracking_event_id {
    type: number
    sql: ${TABLE}."TRACKING_EVENT_ID" ;;
  }

  dimension: trip_id {
    type: number
    sql: ${TABLE}."TRIP_ID" ;;
  }

  dimension: trip_odo_miles {
    type: number
    sql: ${TABLE}."TRIP_ODO_MILES" ;;
  }

  dimension_group: vendor_timestamp {
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
    sql: CAST(${TABLE}."VENDOR_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # -----Set Fields for Drilling -----
  set: detail {
    fields: [
      asset_id
    ]
  }
}
