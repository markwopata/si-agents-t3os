view: market {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."MARKET" ;;
  drill_fields: [market_id]

  dimension: market_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: _id_dist {
    type: number
    sql: ${TABLE}."_ID_DIST" ;;
  }
  dimension: abbreviation {
    type: string
    sql: ${TABLE}."ABBREVIATION" ;;
  }
  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }
  dimension: area_code {
    type: string
    sql: ${TABLE}."AREA_CODE" ;;
  }
  dimension: branch_earnings_start_month {
    type: date_raw
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
  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }
  dimension: date_updated {
    type: date_raw
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
  dimension: market_start_month {
    type: date_raw
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
  dimension: state_abbreviation {
    type: string
    sql: ${TABLE}."STATE_ABBREVIATION" ;;
  }
  dimension: street_1 {
    type: string
    sql: ${TABLE}."STREET_1" ;;
  }
  dimension: street_2 {
    type: string
    sql: ${TABLE}."STREET_2" ;;
  }
  dimension: zip_code {
    type: zipcode
    sql: ${TABLE}."ZIP_CODE" ;;
  }
  measure: count {
    type: count
    drill_fields: [market_id, child_market_name, market_name, general_manager_name, region_name]
  }
}
