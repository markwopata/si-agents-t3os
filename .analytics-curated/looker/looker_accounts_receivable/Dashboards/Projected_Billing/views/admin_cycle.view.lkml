view: admin_cycle {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."ADMIN_CYCLE";;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: make_and_model {
    type: string
    sql: CONCAT(${make}, ' ', ${model}) ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME";;
  }

  dimension: total_days_on_rent {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ON_RENT" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: price_per_day {
    label: "Day Rate"
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd_0
  }

  dimension: price_per_week {
    label: "Week Rate"
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd_0
  }

  dimension: price_per_month {
    label: "Month Rate"
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd_0
  }

  dimension_group: start_date {
    label: "Rental Start Date"
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
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension_group: end_date {
    label: "Scheduled Off Rent Date"
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
    sql: ${TABLE}."END_DATE"  ;;
  }

  dimension_group: next_cycle_date {
    label: "Next Cycle Date"
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."NEXT_CYCLE_INV_DATE" ;;
  }

 }
