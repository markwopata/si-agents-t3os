view: market {
  sql_table_name: "BRANCH_EARNINGS"."MARKET" ;;
  drill_fields: [market_id]

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

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

  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: general_manager_disc_code {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_DISC_CODE" ;;
  }

  dimension: general_manager_email {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_EMAIL" ;;
  }

  dimension: general_manager_employee_id {
    type: number
    sql: ${TABLE}."GENERAL_MANAGER_EMPLOYEE_ID" ;;
  }

  dimension: general_manager_environment_style {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_ENVIRONMENT_STYLE" ;;
  }

  dimension: general_manager_name {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_NAME" ;;
  }

  dimension: general_manager_title {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_TITLE" ;;
  }

  dimension: general_manager_url_disc {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_URL_DISC" ;;
  }

  dimension: general_manager_url_greenhouse {
    type: string
    sql: ${TABLE}."GENERAL_MANAGER_URL_GREENHOUSE" ;;
  }

  dimension: is_dealership {
    type: yesno
    sql: ${TABLE}."IS_DEALERSHIP" ;;
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
    drill_fields: [market_id, market_name, general_manager_name, child_market_name, region_name]
  }
}
