view: driver_performance {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__DRIVER_PERFORMANCE";;

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  dimension: year {
    type: number
    sql: ${TABLE}."YEAR" ;;
  }

  dimension: month {
    type: string
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: week_num {
    type: string
    sql: ${TABLE}."WEEK_NUM" ;;
  }

  dimension: year_month {
    type: string
    sql: ${TABLE}."YEAR_MONTH" ;;
  }

  dimension: year_week {
    type: string
    sql: ${TABLE}."YEAR_WEEK" ;;
  }

  # identity / grouping
  dimension: driver_name {
    type: string
    sql: ${TABLE}."DRIVER_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_name {
    type: string
    sql: ${TABLE}."ASSET_NAME" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: incident_source {
    type: string
    sql: ${TABLE}."INCIDENT_SOURCE" ;;
  }

  dimension: groups {
    type: string
    sql: ${TABLE}."GROUPS" ;;
  }

  dimension: run_time_utc_seconds {
    type: number
    sql: ${TABLE}."RUN_TIME_UTC_SECONDS" ;;
  }

  dimension: miles_driven_utc {
    type: number
    sql: ${TABLE}."MILES_DRIVEN_UTC" ;;
  }

  dimension: weekly_run_time_utc_seconds {
    type: number
    sql: ${TABLE}."WEEKLY_RUN_TIME_UTC_SECONDS" ;;
  }

  dimension: weekly_miles_driven_utc {
    type: number
    sql: ${TABLE}."WEEKLY_MILES_DRIVEN_UTC" ;;
  }

  dimension: monthly_run_time_utc_seconds {
    type: number
    sql: ${TABLE}."MONTHLY_RUN_TIME_UTC_SECONDS" ;;
  }

  dimension: monthly_miles_driven_utc {
    type: number
    sql: ${TABLE}."MONTHLY_MILES_DRIVEN_UTC" ;;
  }

  # violation counts (per-type)
  dimension: speeding_violations {
    type: number
    sql: ${TABLE}."SPEEDING_VIOLATIONS" ;;
  }

  dimension: cornering_violations {
    type: number
    sql: ${TABLE}."CORNERING_VIOLATIONS" ;;
  }

  dimension: acceleration_decceleration_violations {
    type: number
    sql: ${TABLE}."ACCELERATION_DECCELERATION_VIOLATIONS" ;;
  }

  dimension: impact_violations {
    type: number
    sql: ${TABLE}."IMPACT_VIOLATIONS" ;;
  }

  dimension: total_violations {
    type: number
    sql: ${TABLE}."TOTAL_VIOLATIONS" ;;
  }

  dimension: severe_violations {
    type: number
    sql: ${TABLE}."SEVERE_VIOLATIONS" ;;
  }

  dimension: ten_mph_over {
    type: number
    sql: ${TABLE}."TEN_MPH_OVER" ;;
  }

  dimension: driver_weekly_total_violations {
    type: number
    sql: ${TABLE}."DRIVER_WEEKLY_TOTAL_VIOLATIONS" ;;
  }

  dimension: driver_monthly_total_violations {
    type: number
    sql: ${TABLE}."DRIVER_MONTHLY_TOTAL_VIOLATIONS" ;;
  }

  dimension: free_violations_per_week {
    type: number
    sql: ${TABLE}."FREE_VIOLATIONS_PER_WEEK" ;;
  }

  dimension: free_violations_per_month {
    type: number
    sql: ${TABLE}."FREE_VIOLATIONS_PER_MONTH" ;;
  }

  dimension: weekly_violations_per_hour {
    type: number
    sql: ${TABLE}."WEEKLY_VIOLATIONS_PER_HOUR" ;;
  }

  dimension: weekly_violations_per_mile {
    type: number
    sql: ${TABLE}."WEEKLY_VIOLATIONS_PER_MILE" ;;
  }

  dimension: monthly_violations_per_hour {
    type: number
    sql: ${TABLE}."MONTHLY_VIOLATIONS_PER_HOUR" ;;
  }

  dimension: monthly_violations_per_mile {
    type: number
    sql: ${TABLE}."MONTHLY_VIOLATIONS_PER_MILE" ;;
  }

  dimension: weekly_score {
    type: number
    sql: ${TABLE}."WEEKLY_SCORE" ;;
  }

  dimension: monthly_score {
    type: number
    sql: ${TABLE}."MONTHLY_SCORE" ;;
  }

  dimension: safety_score_percent {
    type: number
    sql: ${TABLE}."SAFETY_SCORE_PERCENT" ;;
  }

  dimension: total_days_used {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_USED" ;;
  }

  dimension: total_days_not_used {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_NOT_USED" ;;
  }

  dimension: assignment_duration_days {
    type: number
    sql: ${TABLE}."ASSIGNMENT_DURATION_DAYS" ;;
  }

  dimension: debug_weekly_violations {
    type: number
    sql: ${TABLE}."DEBUG_WEEKLY_VIOLATIONS" ;;
  }

  dimension: debug_weekly_days {
    type: number
    sql: ${TABLE}."DEBUG_WEEKLY_DAYS" ;;
  }

  dimension: debug_monthly_violations {
    type: number
    sql: ${TABLE}."DEBUG_MONTHLY_VIOLATIONS" ;;
  }

  dimension: debug_monthly_days {
    type: number
    sql: ${TABLE}."DEBUG_MONTHLY_DAYS" ;;
  }

  set: detail {
    fields: [
      date,
      start_date,
      end_date,
      year,
      month,
      week_num,
      year_month,
      year_week,
      driver_name,
      company_id,
      asset_id,
      asset_name,
      branch,
      incident_source,
      groups,
      run_time_utc_seconds,
      miles_driven_utc,
      weekly_run_time_utc_seconds,
      weekly_miles_driven_utc,
      monthly_run_time_utc_seconds,
      monthly_miles_driven_utc,
      speeding_violations,
      cornering_violations,
      acceleration_decceleration_violations,
      impact_violations,
      total_violations,
      severe_violations,
      ten_mph_over,
      driver_weekly_total_violations,
      driver_monthly_total_violations,
      free_violations_per_week,
      free_violations_per_month,
      weekly_violations_per_hour,
      weekly_violations_per_mile,
      monthly_violations_per_hour,
      monthly_violations_per_mile,
      debug_weekly_violations,
      debug_weekly_days,
      debug_monthly_violations,
      debug_monthly_days,
      total_days_used,
      total_days_not_used,
      assignment_duration_days,
      weekly_score,
      monthly_score,
      safety_score_percent
    ]
  }
}
