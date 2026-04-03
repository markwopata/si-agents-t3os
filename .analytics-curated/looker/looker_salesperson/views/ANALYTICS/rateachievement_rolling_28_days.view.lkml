view: rateachievement_rolling_28_days {
  sql_table_name: "PUBLIC"."RATEACHIEVEMENT_ROLLING_28_DAYS"
    ;;

  dimension: count_of_invoices {
    type: number
    sql: ${TABLE}."COUNT_OF_INVOICES" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: prim_key {
    primary_key: yes
    type: number
    sql: ${TABLE}."PRIM_KEY" ;;
  }

  dimension_group: rental_day {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RENTAL_DAY" ;;
  }

  dimension: salesperson {
    type: string
    sql: ${TABLE}."SALESPERSON" ;;
  }

  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: total_benchmark {
    type: number
    sql: ${TABLE}."TOTAL_BENCHMARK" ;;
  }

  dimension: total_book {
    type: number
    sql: ${TABLE}."TOTAL_BOOK" ;;
  }

  dimension: total_inv_amt {
    type: number
    sql: ${TABLE}."TOTAL_INV_AMT" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }

  measure: perc_of_bench {
    type: average
    sql: (${TABLE}."PERC_OF_BENCH")*100 ;;
    #sql_distinct_key:${TABLE}."salesperson_user_id" ;;
    value_format: "0"
  }

  measure: perc_of_book {
    type: average
    sql: (${TABLE}."PERC_OF_BOOK")*100 ;;
    #sql_distinct_key:${TABLE}."salesperson_user_id" ;;
    value_format: "0"
  }

  measure: rolling_28_day_perc_of_bench {
    type: average
    sql: (${TABLE}."ROLLING_28_DAY_PERC_OF_BENCH")*100 ;;
    #sql_distinct_key:${TABLE}."salesperson_user_id" ;;
    value_format: "0"
    drill_fields: [detail*]
  }

  measure: rolling_28_day_perc_of_bench_by_market_drill {
    type: average
    sql: (${TABLE}."ROLLING_28_DAY_PERC_OF_BENCH")*100 ;;
    #sql_distinct_key:${TABLE}."salesperson_user_id" ;;
    value_format: "0"
    drill_fields: [market_region_xwalk.market_name, rolling_28_day_perc_of_bench]
  }

  measure: rolling_28_day_perc_of_book {
    type: average
    sql: (${TABLE}."ROLLING_28_DAY_PERC_OF_BOOK")*100 ;;
    #sql_distinct_key:${TABLE}."salesperson_user_id" ;;
    value_format: "0"
    drill_fields: [detail*]
  }

  measure: rolling_28_day_perc_of_book_by_market_drill {
    type: average
    sql: (${TABLE}."ROLLING_28_DAY_PERC_OF_BOOK")*100 ;;
    #sql_distinct_key:${TABLE}."salesperson_user_id" ;;
    value_format: "0"
    drill_fields: [market_region_xwalk.market_name, rolling_28_day_perc_of_bench]
  }

  set: detail {
    fields: [rental_day_raw, salesperson_user_id, salesperson,market_id,market_name, perc_of_bench]
  }
}
