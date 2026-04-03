view: geozones {
  sql_table_name: "LOOKER"."GEOZONES" ;;

  dimension: city {
    type: string
    sql: ${TABLE}."CITY" ;;
  }
  dimension: city_state {
    type: string
    sql: ${TABLE}."CITY_STATE" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: geozone_name {
    type: string
    sql: ${TABLE}."GEOZONE_NAME" ;;
  }
  dimension: geozone_rate {
    type: string
    sql: ${TABLE}."GEOZONE_RATE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_location {
    type: yesno
    sql: ${TABLE}."MARKET_LOCATION" ;;
  }
  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }
  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [geozone_name]
  }
}
