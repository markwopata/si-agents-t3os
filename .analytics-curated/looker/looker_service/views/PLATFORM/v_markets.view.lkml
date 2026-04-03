view: v_markets {
  sql_table_name: "PLATFORM"."GOLD"."V_MARKETS" ;;

  dimension: market_abbreviation {
    type: string
    sql: ${TABLE}."MARKET_ABBREVIATION" ;;
  }
  dimension: market_active {
    type: yesno
    sql: ${TABLE}."MARKET_ACTIVE" ;;
  }
  dimension: market_active_reporting {
    type: yesno
    sql: ${TABLE}."MARKET_ACTIVE_REPORTING" ;;
  }
  dimension: market_area_code {
    type: string
    sql: ${TABLE}."MARKET_AREA_CODE" ;;
  }
  dimension_group: market_branch_earnings_start_month {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."MARKET_BRANCH_EARNINGS_START_MONTH" ;;
  }
  dimension: market_company_id {
    type: number
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
  }
  dimension: market_district {
    type: string
    sql: ${TABLE}."MARKET_DISTRICT" ;;
  }
  dimension: market_division_name {
    type: string
    sql: ${TABLE}."MARKET_DIVISION_NAME" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_is_dealership {
    type: yesno
    sql: ${TABLE}."MARKET_IS_DEALERSHIP" ;;
  }
  dimension: market_is_public_msp {
    type: yesno
    sql: ${TABLE}."MARKET_IS_PUBLIC_MSP" ;;
  }
  dimension: market_is_public_rsp {
    type: yesno
    sql: ${TABLE}."MARKET_IS_PUBLIC_RSP" ;;
  }
  dimension: market_key {
    type: string
    sql: ${TABLE}."MARKET_KEY" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_number {
    type: number
    sql: ${TABLE}."MARKET_NUMBER" ;;
  }
  dimension: market_number_months_open {
    type: number
    sql: ${TABLE}."MARKET_NUMBER_MONTHS_OPEN" ;;
  }
  dimension: market_open_greater_than_12_months {
    type: yesno
    sql: ${TABLE}."MARKET_OPEN_GREATER_THAN_12_MONTHS" ;;
  }
  dimension: market_parent_child_district {
    type: string
    sql: ${TABLE}."MARKET_PARENT_CHILD_DISTRICT" ;;
  }
  dimension: market_parent_child_market_id {
    type: string
    sql: ${TABLE}."MARKET_PARENT_CHILD_MARKET_ID" ;;
  }
  dimension: market_parent_child_market_name {
    type: string
    sql: ${TABLE}."MARKET_PARENT_CHILD_MARKET_NAME" ;;
  }
  dimension: market_parent_child_region {
    type: number
    sql: ${TABLE}."MARKET_PARENT_CHILD_REGION" ;;
  }
  dimension: market_parent_child_region_name {
    type: string
    sql: ${TABLE}."MARKET_PARENT_CHILD_REGION_NAME" ;;
  }
  dimension_group: market_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."MARKET_RECORDTIMESTAMP" ;;
  }
  dimension: market_region {
    type: number
    sql: ${TABLE}."MARKET_REGION" ;;
  }
  dimension: market_region_name {
    type: string
    sql: ${TABLE}."MARKET_REGION_NAME" ;;
  }
  dimension: market_source {
    type: string
    sql: ${TABLE}."MARKET_SOURCE" ;;
  }
  dimension: market_state {
    type: string
    sql: ${TABLE}."MARKET_STATE" ;;
  }
  dimension: market_type {
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_division_name, market_name, market_parent_child_market_name, market_region_name, market_parent_child_region_name]
  }
}
