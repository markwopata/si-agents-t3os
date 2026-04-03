include: "/_base/people_analytics/looker/cdl_headcount_optimization.view.lkml"

view: +cdl_headcount_optimization {


  ################ DATES ################
  dimension_group: month_date {
    type: time
    timeframes: [date]
    sql: ${month_date} ;;
  }


  ################ DIMENSIONS ################

  dimension: market_id {
    primary_key: yes
    value_format_name: id
  }

  dimension: market_avg_idle_minutes_per_week {
    value_format_name: decimal_2
  }

  dimension: market_avg_trip_minutes_per_week {
    value_format_name: decimal_2
  }

  dimension: vehicle_miles_traveled {
    value_format_name: decimal_4
  }

  dimension: environment_score {
    value_format_name: percent_2
  }

  dimension: average_rent_revenue {
    value_format_name: usd
  }

  dimension: predicted_rent {
    value_format_name: usd
  }

  dimension: benchmark_rent_per_cdl {
    value_format_name: usd
  }

  dimension: optimized_headcount {
    type: number
    value_format_name: decimal_0
    sql:
    CASE WHEN (-258700 +
    (13140 * ${active_customers}) +
    (200200 * ${headcount}) +
    (26 * ${market_avg_idle_minutes_per_week}) -
    (3.5749 * ${market_avg_trip_minutes_per_week}) -
    (48520 * ${environment_score}) ) / ${benchmark_rent_per_cdl} <= ${headcount}
    THEN ${headcount}
    ELSE (-258700 +
    (13140 * ${active_customers}) +
    (200200 * ${headcount}) +
    (26 * ${market_avg_idle_minutes_per_week}) -
    (3.5749 * ${market_avg_trip_minutes_per_week}) -
    (48520 * ${environment_score}) ) / ${benchmark_rent_per_cdl} END
      ;;
  }

  dimension: gap {
    type: number
    sql: ${optimized_headcount} - ${headcount};;
  }

  dimension: gap_corrected {
    type: number
    value_format_name: decimal_0
    sql: case when ${gap} <= 0 then 0 else ${gap} end ;;
  }

  ################ MEASURES ################

  measure: sum_of_gap {
    type: sum
    sql: ${gap_corrected};;
    description: "Total CDL Shortage"
  }

}
