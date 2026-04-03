view: driver_performance_coaching_recs_testing {
  sql_table_name: "BI_OPS"."DRIVER_PERFORMANCE_COACHING_RECS_TESTING" ;;

  dimension: band_points {
    type: number
    sql: ${TABLE}."BAND_POINTS" ;;
  }
  dimension: coaching_score_simple {
    type: number
    sql: ${TABLE}."COACHING_SCORE_SIMPLE" ;;
  }
  dimension: driver_safety_score_100 {
    type: number
    sql: ${TABLE}."DRIVER_SAFETY_SCORE_100" ;;
  }
  dimension_group: last_coaching {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_COACHING" ;;
  }
  dimension: list_name {
    type: string
    sql: ${TABLE}."LIST_NAME" ;;
  }
  dimension: list_rank {
    type: number
    sql: ${TABLE}."LIST_RANK" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: n_high_categories {
    type: number
    sql: ${TABLE}."N_HIGH_CATEGORIES" ;;
  }
  dimension: operator_id {
    type: string
    sql: ${TABLE}."OPERATOR_ID" ;;
  }
  dimension: operator_name {
    type: string
    sql: ${TABLE}."OPERATOR_NAME" ;;
  }
  dimension: overall_driver_band {
    type: string
    sql: ${TABLE}."OVERALL_DRIVER_BAND" ;;
  }
  dimension: primary_contributing_event {
    type: string
    sql: ${TABLE}."PRIMARY_CONTRIBUTING_EVENT" ;;
  }
  dimension: primary_risk_persona {
    type: string
    sql: ${TABLE}."PRIMARY_RISK_PERSONA" ;;
  }
  dimension: safety_bucket_0_to10 {
    type: number
    sql: ${TABLE}."SAFETY_BUCKET_0TO10" ;;
  }
  dimension: secondary_contributing_event {
    type: string
    sql: ${TABLE}."SECONDARY_CONTRIBUTING_EVENT" ;;
  }
  dimension: tier4_events_rw {
    type: number
    sql: ${TABLE}."TIER4_EVENTS_RW" ;;
  }
  dimension: tier5_events_rw {
    type: number
    sql: ${TABLE}."TIER5_EVENTS_RW" ;;
  }
  dimension: total_drive_time {
    type: number
    sql: ${TABLE}."TOTAL_DRIVE_TIME" ;;
  }
  dimension: total_miles_driven {
    type: number
    sql: ${TABLE}."TOTAL_MILES_DRIVEN" ;;
  }
  dimension: trend_against_4_wk_avg {
    type: string
    sql: ${TABLE}."TREND_AGAINST_4WK_AVG" ;;
  }
  dimension_group: week_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."WEEK_START" ;;
  }
  dimension: worsening_flag {
    type: number
    sql: ${TABLE}."WORSENING_FLAG" ;;
  }

  dimension: operator_name_link {
    group_label: "Operator Name Link"
    label: "Driver"
    type: string
    sql: ${operator_name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/2227?Driver={{ operator_name._filterable_value | url_encode}}"target="_blank">
    {{rendered_value}} ➔</a></font>;;
  }

  measure: last_week_drive_time {
    type: max
    sql: ${total_drive_time} ;;
    value_format_name: decimal_1
  }

  measure: last_week_miles_driven {
    type: max
    sql: ${total_miles_driven} ;;
    value_format_name: decimal_1
  }

  dimension: weeks_critical_last_8 {
    type: number
    sql: ${TABLE}."WEEKS_CRITICAL_LAST_8" ;;
  }

  dimension: weeks_at_risk_last_8 {
    type: number
    sql: ${TABLE}."WEEKS_AT_RISK_LAST_8" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name, operator_name, list_name]
  }
}
