view: dra_monthly_new {
  sql_table_name: "PUBLIC"."DRA_MONTHLY_NEW"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }

  dimension: asset_type_id {
    type: number
    sql: ${TABLE}."ASSET_TYPE_ID" ;;
  }

  dimension: class_id {
    type: number
    sql: ${TABLE}."CLASS_ID" ;;
  }

  dimension: class_name {
    type: string
    sql: ${TABLE}."CLASS_NAME" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ);;
  }

  dimension_group: dra {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DRA_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: dra_report_ind {
    type: string
    sql: ${TABLE}."DRA_REPORT_IND" ;;
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  }

  dimension: first_rental_start_date {
    type: string
    sql: ${TABLE}."FIRST_RENTAL_START_DATE" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: month_ {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."MONTH_" AS TIMESTAMP_NTZ) ;;
  }


  dimension: purchase_date {
    type: string
    sql: ${TABLE}."PURCHASE_DATE" ;;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }

  dimension: service_to_rental {
    type: number
    sql: ${TABLE}."SERVICE_TO_RENTAL" ;;
  }

  measure: count {
    type: count
    drill_fields: [class_name]
  }
}
