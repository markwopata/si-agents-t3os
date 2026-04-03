view: dim_locations_fleet_opt {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_LOCATIONS_FLEET_OPT" ;;

  dimension: location_address_concatenated {
    type: string
    sql: ${TABLE}."LOCATION_ADDRESS_CONCATENATED" ;;
  }
  dimension: location_city {
    type: string
    sql: ${TABLE}."LOCATION_CITY" ;;
  }
  dimension: location_company_key {
    type: string
    sql: ${TABLE}."LOCATION_COMPANY_KEY" ;;
  }
  dimension: location_description {
    type: string
    sql: ${TABLE}."LOCATION_DESCRIPTION" ;;
  }
  dimension: location_id {
    type: number
    sql: ${TABLE}."LOCATION_ID" ;;
  }
  dimension: location_jobsite {
    type: yesno
    sql: ${TABLE}."LOCATION_JOBSITE" ;;
  }
  dimension: location_key {
    type: string
    sql: ${TABLE}."LOCATION_KEY" ;;
  }
  dimension: location_latitude {
    type: number
    sql: ${TABLE}."LOCATION_LATITUDE" ;;
  }
  dimension: location_longitude {
    type: number
    sql: ${TABLE}."LOCATION_LONGITUDE" ;;
  }
  dimension: location_needs_review {
    type: yesno
    sql: ${TABLE}."LOCATION_NEEDS_REVIEW" ;;
  }
  dimension: location_nickname {
    type: string
    sql: ${TABLE}."LOCATION_NICKNAME" ;;
  }
  dimension_group: location_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LOCATION_RECORDTIMESTAMP" ;;
  }
  dimension: location_source {
    type: string
    sql: ${TABLE}."LOCATION_SOURCE" ;;
  }
  dimension: location_street_1 {
    type: string
    sql: ${TABLE}."LOCATION_STREET_1" ;;
  }
  dimension: location_street_2 {
    type: string
    sql: ${TABLE}."LOCATION_STREET_2" ;;
  }
  dimension: location_user_key {
    type: string
    sql: ${TABLE}."LOCATION_USER_KEY" ;;
  }
  dimension: location_zip_code {
    type: string
    sql: ${TABLE}."LOCATION_ZIP_CODE" ;;
  }
  dimension: location_zip_code_extended {
    type: string
    sql: ${TABLE}."LOCATION_ZIP_CODE_EXTENDED" ;;
  }
  dimension: state_abbreviation {
    type: string
    sql: ${TABLE}."STATE_ABBREVIATION" ;;
  }
  measure: count {
    type: count
    drill_fields: [location_nickname]
  }
}
