include: "/_base/people_analytics/looker/cdl_headcount_optimization_temporary.view.lkml"

view: +cdl_headcount_optimization_temporary {



  ################ DIMENSIONS ################

  dimension: market_id {
    primary_key: yes
    value_format_name: id
  }

  dimension: average_daily_idle_duration {
    value_format_name: decimal_2
  }

  dimension: average_daily_trip_time {
    value_format_name: decimal_2
  }

  dimension: vmt {
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

  dimension: predicted_cdls {
    value_format_name: decimal_0
  }

  dimension: gap_corrected {
    type: number
    value_format_name: decimal_1
    sql: case when ${gap} <= 0 then 0 else ${gap} end ;;
  }

  ################ MEASURES ################

  measure: sum_of_gap {
    type: sum
    sql: ${gap_corrected};;
    description: "Total CDL Shortage"
  }

}
