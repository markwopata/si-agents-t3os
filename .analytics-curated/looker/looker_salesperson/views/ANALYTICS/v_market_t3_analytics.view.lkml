view: v_market_t3_analytics {
  sql_table_name: "ANALYTICS"."PUBLIC"."V_MARKET_T3_ANALYTICS" ;;

  dimension: _id_dist {
    type: number
    value_format_name: id
    sql: ${TABLE}."_ID_DIST" ;;
  }
  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }
  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }
  dimension_group: branch_earnings_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BRANCH_EARNINGS_START_MONTH" ;;
  }
  dimension: child_market_id {
    type: number
    sql: ${TABLE}."CHILD_MARKET_ID" ;;
  }
  dimension: child_market_name {
    type: string
    sql: ${TABLE}."CHILD_MARKET_NAME" ;;
  }
  dimension: current_months_open {
    type: number
    sql: ${TABLE}."CURRENT_MONTHS_OPEN" ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: is_current_months_open_greater_than_twelve {
    type: yesno
    sql: ${TABLE}."IS_CURRENT_MONTHS_OPEN_GREATER_THAN_TWELVE" ;;
  }
  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension_group: market_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MARKET_START_MONTH" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  dimension: market_type_id {
    type: number
    sql: ${TABLE}."MARKET_TYPE_ID" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }
  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [region_name, child_market_name, market_name]
  }
}
