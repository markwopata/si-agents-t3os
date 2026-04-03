view: remaining_rental_cost {
  sql_table_name: "PUBLIC"."REMAINING_RENTAL_COST"
    ;;

  dimension: rental_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: cheapest_option {
    label: "Estimated Rental Cost if Rental Ended Today"
    type: number
    sql: ${TABLE}."CHEAPEST_OPTION" ;;
    value_format_name: usd
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
    label: "Price Per Day"
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
    value_format_name: usd
  }

  dimension: price_per_month {
    label: "Price Per Month"
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
    value_format_name: usd
  }

  dimension: price_per_week {
    label: "Price Per Week"
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
    value_format_name: usd
  }

  dimension: round_down_week_plus_days {
    type: number
    sql: ${TABLE}."ROUND_DOWN_WEEK_PLUS_DAYS" ;;
  }

  dimension: round_up_week {
    type: number
    sql: ${TABLE}."ROUND_UP_WEEK" ;;
  }

  measure: sum_cheapest_option {
    type: sum
    sql: ${cheapest_option} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  measure: to_date_rental {
    #Used for Delek don't change name
    type: number
    sql: ${line_items.rental_revenue}+${sum_cheapest_option} ;;
    value_format_name: usd_0
  }

  measure: to_date_rental_spend {
    type: number
    sql: ${line_items.rental_revenue}+${sum_cheapest_option} ;;
    value_format_name: usd_0
  }

  measure: count {
    type: count
    drill_fields: []
  }

  set: detail {
    fields: [
      rental_id,
      assets.custom_name,
      assets.asset_class,
      price_per_day,
      price_per_week,
      price_per_month,
      cheapest_option
    ]
  }
}
