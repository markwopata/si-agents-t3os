view: rate_refresh_overrides {
  sql_table_name: "ANALYTICS"."RATE_ACHIEVEMENT"."RATE_REFRESH_OVERRIDES" ;;

  dimension_group: approval {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."APPROVAL_DATE" ;;
  }
  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }
  dimension: approved_by_user {
    type: string
    sql: ${TABLE}."APPROVED_BY_USER" ;;
  }
  dimension_group: date_submitted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_SUBMITTED" ;;
  }
  dimension_group: date_voided {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_VOIDED" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }
  dimension: override_submission_id {
    type: number
    sql: ${TABLE}."OVERRIDE_SUBMISSION_ID" ;;
  }
  dimension: price_per_month {
    type: number
    sql: ${TABLE}."PRICE_PER_MONTH" ;;
  }
  dimension: rate_type_id {
    type: number
    sql: ${TABLE}."RATE_TYPE_ID" ;;
  }
  dimension: region_id {
    type: number
    sql: ${TABLE}."REGION_ID" ;;
  }
  dimension: submitted_by_user {
    type: string
    sql: ${TABLE}."SUBMITTED_BY_USER" ;;
  }
  dimension: voided_by_user {
    type: string
    sql: ${TABLE}."VOIDED_BY_USER" ;;
  }
  measure: count {
    type: count
  }
}
