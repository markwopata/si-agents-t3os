view: comp_geocode {
  sql_table_name: "ANALYTICS"."PUBLIC"."COMP_GEOCODE"
    ;;

  dimension: accuracy_score {
    type: number
    sql: ${TABLE}."ACCURACY_SCORE" ;;
  }

  dimension: accuracy_type {
    type: string
    sql: ${TABLE}."ACCURACY_TYPE" ;;
  }

  dimension: address {
    type: string
    sql: ${TABLE}."ADDRESS" ;;
  }

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }

  dimension: city_1 {
    type: string
    sql: ${TABLE}."CITY.1" ;;
  }

  dimension: competitor {
    type: string
    sql: ${TABLE}."COMPETITOR" ;;
  }

  dimension: country {
    type: string
    map_layer_name: countries
    sql: ${TABLE}."COUNTRY" ;;
  }

  dimension: county {
    type: string
    sql: ${TABLE}."COUNTY" ;;
  }

  dimension: latitude {
    type: string
    sql: ${TABLE}."LATITUDE" ;;
  }

  dimension: longitude {
    type: string
    sql: ${TABLE}."LONGITUDE" ;;
  }

  dimension: number {
    type: string
    sql: ${TABLE}."NUMBER" ;;
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: state_1 {
    type: string
    sql: ${TABLE}."STATE.1" ;;
  }

  dimension: street {
    type: string
    sql: ${TABLE}."STREET" ;;
  }

  dimension: unit_number {
    type: string
    sql: ${TABLE}."UNIT_NUMBER" ;;
  }

  dimension: unit_type {
    type: string
    sql: ${TABLE}."UNIT_TYPE" ;;
  }

  dimension: zip {
    type: zipcode
    sql: ${TABLE}."ZIP" ;;
  }

  dimension: zip_1 {
    type: number
    sql: ${TABLE}."ZIP.1" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
