view: v_rentals {
  sql_table_name: "PLATFORM"."GOLD"."V_RENTALS" ;;

  dimension: rental_delivery_city {
    type: string
    sql: ${TABLE}."RENTAL_DELIVERY_CITY" ;;
  }
  dimension: rental_delivery_latitude {
    type: number
    sql: ${TABLE}."RENTAL_DELIVERY_LATITUDE" ;;
  }
  dimension: rental_delivery_longitude {
    type: number
    sql: ${TABLE}."RENTAL_DELIVERY_LONGITUDE" ;;
  }
  dimension: rental_delivery_state {
    type: string
    sql: ${TABLE}."RENTAL_DELIVERY_STATE" ;;
  }
  dimension: rental_delivery_state_abbreviation {
    type: string
    sql: ${TABLE}."RENTAL_DELIVERY_STATE_ABBREVIATION" ;;
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rental_key {
    type: string
    sql: ${TABLE}."RENTAL_KEY" ;;
  }
  dimension: rental_purchase_option_id {
    type: number
    sql: ${TABLE}."RENTAL_PURCHASE_OPTION_ID" ;;
  }
  dimension: rental_purchase_option_name {
    type: string
    sql: ${TABLE}."RENTAL_PURCHASE_OPTION_NAME" ;;
  }
  dimension_group: rental_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."RENTAL_RECORDTIMESTAMP" ;;
  }
  dimension: rental_source {
    type: string
    sql: ${TABLE}."RENTAL_SOURCE" ;;
  }
  dimension: rental_status_id {
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }
  dimension: rental_status_name {
    type: string
    sql: ${TABLE}."RENTAL_STATUS_NAME" ;;
  }
  dimension: rental_type_id {
    type: number
    sql: ${TABLE}."RENTAL_TYPE_ID" ;;
  }
  dimension: rental_type_name {
    type: string
    sql: ${TABLE}."RENTAL_TYPE_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [rental_status_name, rental_purchase_option_name, rental_type_name]
  }
}
