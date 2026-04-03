view: fuel_rates {
  derived_table: {
    sql:

    SELECT
        state,
        start_date,
        end_date,
        MAX(CASE WHEN fuel_type_id = 129 AND rate_type_id = 3 THEN price_per_gallon END) AS clear_diesel_floor,
        MAX(CASE WHEN fuel_type_id = 129 AND rate_type_id = 1 THEN price_per_gallon END) AS clear_diesel_book,
        MAX(CASE WHEN fuel_type_id = 130 AND rate_type_id = 3 THEN price_per_gallon END) AS dyed_diesel_floor,
        MAX(CASE WHEN fuel_type_id = 130 AND rate_type_id = 1 THEN price_per_gallon END) AS dyed_diesel_book,
        MAX(CASE WHEN fuel_type_id = 131 AND rate_type_id = 3 THEN price_per_gallon END) AS regular_gas_floor,
        MAX(CASE WHEN fuel_type_id = 131 AND rate_type_id = 1 THEN price_per_gallon END) AS regular_gas_book
    FROM analytics.rate_achievement.FUEL_RATES
    --where current_date() BETWEEN start_date and end_date
    GROUP BY 1,2,3
            ;;
  }

  dimension: clear_diesel_floor {
    type: number
    value_format_name: usd
    sql: ${TABLE}."CLEAR_DIESEL_FLOOR" ;;
  }


  dimension_group: start {
    type: time
    timeframes: [
      date
    ]
    sql: CAST(${TABLE}.start_date AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: end {
    type: time
    timeframes: [
      date
    ]
    sql: CAST(${TABLE}.end_date AS TIMESTAMP_NTZ) ;;
  }


  dimension: current_fuel_rate {
    type: yesno
    sql: current_date() between ${start_date} and ${end_date} ;;
  }
  # dimension: clear_diesel_benchmark {
  #   type: number
  #   value_format_name: usd
  #   sql: ${TABLE}."CLEAR_DIESEL_BENCHMARK" ;;
  # }
  dimension: clear_diesel_book {
    type: number
    value_format_name: usd
    sql: ${TABLE}."CLEAR_DIESEL_BOOK" ;;
  }
  dimension: dyed_diesel_floor {
    type: number
    value_format_name: usd
    sql: ${TABLE}."DYED_DIESEL_FLOOR" ;;
  }
  # dimension: dyed_diesel_benchmark {
  #   type: number
  #   value_format_name: usd
  #   sql: ${TABLE}."DYED_DIESEL_BENCHMARK" ;;
  # }
  dimension: dyed_diesel_book {
    type: number
    value_format_name: usd
    sql: ${TABLE}."DYED_DIESEL_BOOK" ;;
  }
  dimension: regular_gas_floor {
    type: number
    value_format_name: usd
    sql: ${TABLE}."REGULAR_GAS_FLOOR" ;;
  }
  # dimension: regular_gas_benchmark {
  #   type: number
  #   value_format_name: usd
  #   sql: ${TABLE}."REGULAR_GAS_BENCHMARK" ;;
  # }
  dimension: regular_gas_book {
    type: number
    value_format_name: usd
    sql: ${TABLE}."REGULAR_GAS_BOOK" ;;
  }
  dimension: state {
    type: string
    primary_key: yes
    sql: ${TABLE}."STATE" ;;
  }

  measure: count {
    type: count
  }

}
