view: fleet_opt_nbv_by_month {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_AGG_ASSET_NBV_BY_MONTH" ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}.asset_id ;;
    value_format_name: id
  }

  dimension: total_estimated_nbv {
    type: number
    sql: ${TABLE}.total_estimated_nbv ;;
    value_format_name: usd
  }

  dimension_group: nbv_as_of_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    datatype: date
    sql: ${TABLE}.nbv_as_of_date ;;
  }

  measure: sum_total_estimated_nbv {
    type: sum
    sql: ${TABLE}.total_estimated_nbv ;;
    value_format_name: usd
  }
}
