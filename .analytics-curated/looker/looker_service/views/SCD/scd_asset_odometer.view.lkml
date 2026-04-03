view: scd_asset_odometer {
  sql_table_name: "ES_WAREHOUSE"."SCD"."SCD_ASSET_ODOMETER" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_scd_odometer_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."ASSET_SCD_ODOMETER_ID" ;;
  }
  dimension: current_flag {
    type: number
    sql: ${TABLE}."CURRENT_FLAG" ;;
  }
  dimension_group: date_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_END" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_START" AS TIMESTAMP_NTZ) ;;
  }
  dimension: odometer {
    type: number
    sql: ${TABLE}."ODOMETER" ;;
  }
  measure: current_odometer {
    type: sum
    filters: [current_flag: "1"]
    sql: ${odometer} ;;
  }
  measure: count {
    type: count
  }
}
