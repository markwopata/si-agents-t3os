view: remaining_rental_cost {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."REMAINING_RENTAL_COST"
    ;;

  dimension: cheapest_option {
    type: number
    sql: ${TABLE}."CHEAPEST_OPTION" ;;
  }

  dimension: day_cost {
    type: number
    sql: ${TABLE}."DAY_COST" ;;
  }

  dimension: month_cost {
    type: number
    sql: ${TABLE}."MONTH_COST" ;;
  }

  dimension: num_days {
    type: number
    sql: ${TABLE}."NUM_DAYS" ;;
  }

  dimension: num_weeks {
    type: number
    sql: ${TABLE}."NUM_WEEKS" ;;
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

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: round_down_week_plus_days {
    type: number
    sql: ${TABLE}."ROUND_DOWN_WEEK_PLUS_DAYS" ;;
  }

  dimension: round_up_week {
    type: number
    sql: ${TABLE}."ROUND_UP_WEEK" ;;
  }

  measure: total_projection {
    type: sum
    value_format: "$#,##0"
    sql: ${cheapest_option} ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
