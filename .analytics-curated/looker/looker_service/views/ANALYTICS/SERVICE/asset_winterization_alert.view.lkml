view: asset_winterization_alert {
  sql_table_name: "ANALYTICS"."SERVICE"."ASSET_WINTERIZATION_ALERT" ;;

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_zip_code {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ZIP_CODE" ;;
  }
  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }
  dimension_group: forecast_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FORECAST_START_DATE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: min1 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN1" ;;
  }
  dimension: min10 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN10" ;;
  }
  dimension: min11 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN11" ;;
  }
  dimension: min12 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN12" ;;
  }
  dimension: min13 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN13" ;;
  }
  dimension: min14 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN14" ;;
  }
  dimension: min2 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN2" ;;
  }
  dimension: min3 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN3" ;;
  }
  dimension: min4 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN4" ;;
  }
  dimension: min5 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN5" ;;
  }
  dimension: min6 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN6" ;;
  }
  dimension: min7 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN7" ;;
  }
  dimension: min8 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN8" ;;
  }
  dimension: min9 {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."MIN9" ;;
  }
  dimension: weather_zip_code {
    type: number
    value_format_name: id
    sql: ${TABLE}."WEATHER_ZIP_CODE" ;;
  }
  measure: count {
    type: count
    # drill_fields: [equipment_class_name]
  }
}
