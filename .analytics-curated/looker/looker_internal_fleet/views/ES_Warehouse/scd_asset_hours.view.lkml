view: scd_asset_hours {
  sql_table_name: "ES_WAREHOUSE"."SCD"."SCD_ASSET_HOURS" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_scd_hours_id {
    type: number
    sql: ${TABLE}."ASSET_SCD_HOURS_ID" ;;
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
  dimension: hours {
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}."HOURS" ;;
  }
  measure: count {
    type: count
  }
}
