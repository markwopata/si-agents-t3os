view: mobile_tool_rental_logs {
  sql_table_name: "MOBILE_TOOLS"."MOBILE_TOOL_RENTAL_LOGS" ;;

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: asset_status {
    type: string
    sql: ${TABLE}."ASSET_STATUS" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }
  dimension_group: end_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: equipment_class_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: full_name_with_id {
    type: string
    sql: ${TABLE}."FULL_NAME_WITH_ID" ;;
  }
  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }
  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: rental_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension_group: start_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."START_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [company_name]
  }
}
