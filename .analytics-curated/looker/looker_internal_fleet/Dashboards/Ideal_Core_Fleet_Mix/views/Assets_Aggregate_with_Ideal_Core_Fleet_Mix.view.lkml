#
# The purpose of this view is to pull out logic specific to Ideal Core Fleet Mix from the primary
# assets_aggregate view using refinement structure.
#

include: "/views/assets_aggregate.view.lkml"

view: +assets_aggregate {
  view_label: "Assets Aggregate with Ideal Core Fleet Mix"

  dimension: ideal_class{
    type:  string
    sql:
      CASE
      WHEN ${ideal_core_fleet_mix.equipment_class_id} IS NOT NULL THEN 'Yes' ELSE 'No' END;;
  }

  dimension: ideal_market{
    type:  string
    sql:
      CASE
      WHEN ${ideal_markets.market_id} IS NOT NULL THEN 'Yes' ELSE 'No' END;;
  }

  dimension: acceptable_range {
    type:  number
    sql: 0;;
  }

  # dimension: oec_in_average_size_yard {
  #   type:  number
  #   sql: 0;;
  # }

  # dimension: count_in_average_size_yard {
  #   type:  number
  #   sql: 0;;
  # }


  # dimension: pct_per_market {
  #   type:  number
  #   sql: 0;;
  # }

  # dimension: current_pct_allocated {
  #   type:  number
  #   sql: 0;;
  # }

  # dimension: variance {
  #   type:  number
  #   sql: 0;;
  # }

  # dimension: current_time_ute {
  #   type:  number
  #   sql: 0;;
  # }

  dimension: current_fin_ute {
    type:  number
    sql: 0;;
  }

  dimension: ideal_oec_pct {
    type:  number
    value_format: "0.00%"
    sql: COALESCE(${ideal_core_fleet_mix.oec_percentage},0) ;;
  }


  measure: ideal_oec_pct_sum {
    type:  sum
    value_format: "0.00%"
    sql: COALESCE(${ideal_core_fleet_mix.oec_percentage},0) ;;
  }

}
