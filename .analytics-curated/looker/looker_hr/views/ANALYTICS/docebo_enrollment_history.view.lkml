view: enrollment_history {
  sql_table_name: "DOCEBO"."ENROLLMENT_HISTORY" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: course_code {
    type: string
    sql: ${TABLE}."COURSE_CODE" ;;
  }
  dimension: course_course_type {
    type: string
    sql: ${TABLE}."COURSE_COURSE_TYPE" ;;
  }
  dimension: course_coursescategory_translation {
    type: string
    sql: ${TABLE}."COURSE_COURSESCATEGORY_TRANSLATION" ;;
  }
  dimension: course_credits {
    type: string
    sql: ${TABLE}."COURSE_CREDITS" ;;
  }
  dimension_group: course_date_begin {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COURSE_DATE_BEGIN" ;;
  }
  dimension_group: course_date_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COURSE_DATE_END" ;;
  }
  dimension: course_expired {
    type: string
    sql: ${TABLE}."COURSE_EXPIRED" ;;
  }
  dimension: course_has_esignature_enabled {
    type: string
    sql: ${TABLE}."COURSE_HAS_ESIGNATURE_ENABLED" ;;
  }
  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }
  dimension: course_signature {
    type: string
    sql: ${TABLE}."COURSE_SIGNATURE" ;;
  }
  dimension: course_status {
    type: string
    sql: ${TABLE}."COURSE_STATUS" ;;
  }
  dimension: course_uidcourse {
    type: string
    sql: ${TABLE}."COURSE_UIDCOURSE" ;;
  }
  dimension: enrollment_course_completion_percentage {
    type: string
    sql: ${TABLE}."ENROLLMENT_COURSE_COMPLETION_PERCENTAGE" ;;
  }
  dimension_group: enrollment_date_begin_validity {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ENROLLMENT_DATE_BEGIN_VALIDITY" ;;
  }
  dimension_group: enrollment_date_complete {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ENROLLMENT_DATE_COMPLETE" ;;
  }
  dimension_group: enrollment_date_expire_validity {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ENROLLMENT_DATE_EXPIRE_VALIDITY" ;;
  }
  dimension_group: enrollment_date_first_access {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ENROLLMENT_DATE_FIRST_ACCESS" ;;
  }
  dimension_group: enrollment_date_inscr {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."ENROLLMENT_DATE_INSCR" ;;
  }
  dimension: enrollment_level {
    type: string
    sql: ${TABLE}."ENROLLMENT_LEVEL" ;;
  }
  dimension: enrollment_number_of_sessions {
    type: string
    sql: ${TABLE}."ENROLLMENT_NUMBER_OF_SESSIONS" ;;
  }
  dimension: enrollment_score_given {
    type: string
    sql: ${TABLE}."ENROLLMENT_SCORE_GIVEN" ;;
  }
  dimension: enrollment_status {
    type: string
    sql: ${TABLE}."ENROLLMENT_STATUS" ;;
  }
  dimension: enrollment_total_time_in_course {
    type: string
    sql: ${TABLE}."ENROLLMENT_TOTAL_TIME_IN_COURSE" ;;
  }
  dimension: enrollment_total_time_in_s4_bdp_sessions {
    type: string
    sql: ${TABLE}."ENROLLMENT_TOTAL_TIME_IN_S4BDP_SESSIONS" ;;
  }
  dimension: user_email {
    type: string
    sql: ${TABLE}."USER_EMAIL" ;;
  }
  dimension: user_firstname {
    type: string
    sql: ${TABLE}."USER_FIRSTNAME" ;;
  }
  dimension: user_lastname {
    type: string
    sql: ${TABLE}."USER_LASTNAME" ;;
  }
  dimension_group: user_register {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."USER_REGISTER_DATE" ;;
  }
  dimension_group: user_suspend {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."USER_SUSPEND_DATE" ;;
  }
  dimension: user_userid {
    type: string
    sql: ${TABLE}."USER_USERID" ;;
  }
  dimension: user_valid {
    type: string
    sql: ${TABLE}."USER_VALID" ;;
  }
  measure: count {
    type: count
    drill_fields: [user_lastname, user_firstname, course_name]
  }

  measure: sum_enrollment_hours {
    type: sum
    sql: ${enrollment_total_time_in_course} ;;
  }
}
