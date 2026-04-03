view: driver_performance {
  derived_table: {
    sql:
    select
    *
    from
    business_intelligence.triage.stg_t3__driver_performance
    ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: date {
    type: date
    sql: ${TABLE}."DATE" ;;
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

  dimension: run_time_utc_seconds {
    type: string
    sql: ${TABLE}."RUN_TIME_UTC_SECONDS" ;;
  }

  dimension: miles_driven_utc {
    type: string
    sql: ${TABLE}."MILES_DRIVEN_UTC" ;;
  }

  dimension: speeding_violations {
    type: string
    sql: ${TABLE}."SPEEDING_VIOLATIONS" ;;
  }

  dimension: cornering_violations {
    type: string
    sql: ${TABLE}."CORNERING_VIOLATIONS" ;;
  }

  dimension: acceleration_decceleration_violations {
    type: string
    sql: ${TABLE}."ACCELERATION_DECCELERATION_VIOLATIONS" ;;
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

  dimension: assignment_start_date {
    type: date
    sql: ${TABLE}."ASSIGNMENT_START_DATE" ;;
  }

  dimension: assignment_end_date {
    type: date
    sql: ${TABLE}."ASSIGNMENT_END_DATE" ;;
  }

  dimension: total_days_assigned {
    type: number
    sql: ${TABLE}."TOTAL_DAYS_ASSIGNED" ;;
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

  set: detail {
    fields: [
      date,
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
      speeding_violations,
      cornering_violations,
      acceleration_decceleration_violations,
      total_violations,
      severe_violations,
      ten_mph_over,
      debug_weekly_violations,
      debug_weekly_days,
      debug_monthly_violations,
      debug_monthly_days,
      assignment_start_date,
      assignment_end_date,
      total_days_assigned,
      total_days_used,
      total_days_not_used,
      assignment_duration_days,
      weekly_score,
      monthly_score,
      safety_score_percent
    ]
  }
}
