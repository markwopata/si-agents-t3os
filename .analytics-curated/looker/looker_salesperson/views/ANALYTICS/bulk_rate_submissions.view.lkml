view: bulk_rate_submissions {
  sql_table_name: "ANALYTICS"."RATE_ACHIEVEMENT"."BULK_RATE_SUBMISSIONS" ;;
  drill_fields: [bulk_rate_submission_id]

  dimension: bulk_rate_submission_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."BULK_RATE_SUBMISSION_ID" ;;
  }
  dimension: cat_class {
    type: string
    sql: ${TABLE}."CAT_CLASS" ;;
  }
  dimension_group: date_submitted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_SUBMITTED" ;;
  }
  dimension_group: date_uploaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPLOADED" ;;
  }
  dimension_group: date_voided {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_VOIDED" ;;
  }
  dimension: price_per_day {
    type: number
    sql: ${TABLE}."PRICE_PER_DAY" ;;
  }
  dimension: price_per_hour {
    type: number
    sql: ${TABLE}."PRICE_PER_HOUR" ;;
  }
  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }
  dimension: price_per_week {
    type: number
    sql: ${TABLE}."PRICE_PER_WEEK" ;;
  }
  dimension: rate_type_id {
    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }
  dimension: region_id {
    type: number
    sql: ${TABLE}."REGION_ID" ;;
  }
  dimension: submitted_by_user_id {
    type: string
    sql: ${TABLE}."SUBMITTED_BY_USER_ID" ;;
  }
  dimension: upload_job_id {
    type: number
    sql: ${TABLE}."UPLOAD_JOB_ID" ;;
  }
  dimension: upload_status {
    type: string
    sql: ${TABLE}."UPLOAD_STATUS" ;;
  }
  dimension: voided_by_user_id {
    type: string
    sql: ${TABLE}."VOIDED_BY_USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [bulk_rate_submission_id]
  }
}
