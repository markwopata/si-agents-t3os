view: dim_markets_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_MARKETS_FLEET_OPT" ;;

  dimension_group: estimated_market_open {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ESTIMATED_MARKET_OPEN_DATE" ;;
  }
  dimension: is_ideal_fleet_market_currently {
    type: yesno
    sql: ${TABLE}."IS_IDEAL_FLEET_MARKET_CURRENTLY" ;;
  }
  dimension: is_ideal_fleet_market_for_past_four_quarters {
    type: yesno
    sql: ${TABLE}."IS_IDEAL_FLEET_MARKET_FOR_PAST_FOUR_QUARTERS" ;;
  }
  dimension: is_ideal_fleet_market_previous_quarter {
    type: yesno
    sql: ${TABLE}."IS_IDEAL_FLEET_MARKET_PREVIOUS_QUARTER" ;;
  }
  dimension: is_uptime_center_market {
    type: yesno
    sql: ${TABLE}."IS_UPTIME_CENTER_MARKET" ;;
  }
  dimension: location_key {
    type: string
    sql: ${TABLE}."LOCATION_KEY" ;;
  }
  dimension: market_abbreviation {
    type: string
    sql: ${TABLE}."MARKET_ABBREVIATION" ;;
  }
  dimension: market_active {
    type: yesno
    sql: ${TABLE}."MARKET_ACTIVE" ;;
  }
  dimension: market_area_code {
    type: string
    sql: ${TABLE}."MARKET_AREA_CODE" ;;
  }
  dimension: market_company_id {
    type: number
    sql: ${TABLE}."MARKET_COMPANY_ID" ;;
    value_format_name: id
  }
  dimension: market_district {
    type: string
    sql: ${TABLE}."MARKET_DISTRICT" ;;
  }
  dimension: market_division_name {
    type: string
    sql: ${TABLE}."MARKET_DIVISION_NAME" ;;
  }
  dimension: market_gm_email {
    type: string
    sql: ${TABLE}."MARKET_GM_EMAIL" ;;
  }
  dimension: market_gm_name {
    type: string
    sql: ${TABLE}."MARKET_GM_NAME" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
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
    primary_key: yes
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
  dimension: market_sales_email {
    type: string
    sql: ${TABLE}."MARKET_SALES_EMAIL" ;;
  }
  dimension: market_service_email {
    type: string
    sql: ${TABLE}."MARKET_SERVICE_EMAIL" ;;
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
  dimension: reporting_market {
    type: yesno
    sql: ${TABLE}."REPORTING_MARKET" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
  market_region_name,
  market_parent_child_market_name,
  market_parent_child_region_name,
  market_gm_name,
  market_name,
  market_division_name
  ]
  }

}
