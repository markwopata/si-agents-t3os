view: vsg_reservations_daily_vehicle_status {
  sql_table_name: "VEHICLE_SOLUTIONS"."VSG_RESERVATIONS_DAILY_VEHICLE_STATUS" ;;

  dimension_group: as_of {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."AS_OF_DATE" ;;
  }

  dimension_group: collected {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COLLECTED_AT" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: vin {
    type: string
    sql: ${TABLE}."VIN" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: platform {
    type: string
    sql: ${TABLE}."PLATFORM" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension_group: latest_return {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LATEST_RETURN_DATE" ;;
  }

  dimension: days_since_last_return {
    type: number
    sql: ${TABLE}."DAYS_SINCE_LAST_RETURN" ;;
  }

  dimension: total_vins {
    type: number
    sql: ${TABLE}."TOTAL_VINS" ;;
  }

  measure: count {
    type: count
    drill_fields: [vin, region_name, model, platform, status, notes]
  }
  measure: count_vehicles {
    type: count_distinct
    sql: ${vin} ;;
    drill_fields: [vin, region_name, model, platform, status, notes]
  }
}
