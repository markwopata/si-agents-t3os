view: rental_rate_by_company {
  sql_table_name: "PUBLIC"."RENTAL_RATE_BY_COMPANY"
    ;;

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: day_benchmark {
    type: number
    sql: ${TABLE}."DAY_BENCHMARK" ;;
  }

  dimension: day_book_rate {
    type: number
    sql: ${TABLE}."DAY_BOOKRATE" ;;
  }

  dimension: day_volume {
    type: number
    sql: ${TABLE}."DAY_VOLUME" ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."END_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: equipment_category {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY" ;;
  }

  dimension: final_equipment_class_id {
    type: number
    sql: ${TABLE}."FINAL_EQUIPMENT_CLASS_ID" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_length {
    type: number
    sql: ${TABLE}."INVOICE_LENGTH" ;;
  }

  dimension: invoice_volume {
    type: string
    sql: ${TABLE}."INVOICE_VOLUME" ;;
  }

  dimension: jobsite {
    type: string
    sql: ${TABLE}."JOBSITE" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: model_name {
    type: string
    sql: ${TABLE}."MODEL_NAME" ;;
  }

  dimension: month_benchmark {
    type: number
    sql: ${TABLE}."MONTH_BENCHMARK" ;;
  }

  dimension: month_book_rate {
    type: number
    sql: ${TABLE}."MONTH_BOOKRATE" ;;
  }

  dimension: month_volume {
    type: number
    sql: ${TABLE}."MONTH_VOLUME" ;;
  }

  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }

  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }

  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }

  dimension: purchase_price {
    type: number
    sql: ${TABLE}."PURCHASE_PRICE" ;;
  }

  dimension: rate_region {
    type: string
    sql: ${TABLE}."RATE_REGION" ;;
  }

  dimension: region_index {
    type: number
    sql: ${TABLE}."REGION_INDEX" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: rental_year_quarter {
    type: string
    sql: ${TABLE}."RENTAL_YEAR_QUARTER" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension_group: start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."START_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: true_price_per_day {
    type: number
    sql: ${TABLE}."TRUE_PRICE_PER_DAY" ;;
  }

  dimension: true_price_per_month {
    type: number
    sql: ${TABLE}."TRUE_PRICE_PER_MONTH" ;;
  }

  dimension: true_price_per_week {
    type: number
    sql: ${TABLE}."TRUE_PRICE_PER_WEEK" ;;
  }

  dimension: week_benchmark {
    type: number
    sql: ${TABLE}."WEEK_BENCHMARK" ;;
  }

  dimension: week_book_rate {
    type: number
    sql: ${TABLE}."WEEK_BOOKRATE" ;;
  }

  dimension: week_volume {
    type: number
    sql: ${TABLE}."WEEK_VOLUME" ;;
  }

  dimension: jobsite_link {
    type: string
    sql: ${jobsite} ;;

    link: {
      label: "View Google Maps"
      url: "https://www.google.com/maps/place/{{ value | url_encode }}"
    }
  }

  dimension: view_active_rental_contracts {
    type: string
    sql: CASE WHEN ${rental_id} is not null THEN 'View Active Rental Contracts' END ;;

    link: {
      label: "View Rental Rates by Customer"
      url: "https://equipmentshare.looker.com/dashboards-next/238"
    }
  }

  measure: count {
    type: count
    drill_fields: [company_name, market_name, model_name]
  }
}
