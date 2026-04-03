view: enrollments {
  sql_table_name: "ANALYTICS"."DOCEBO"."ENROLLMENTS" ;;

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: course_begin {
    type: date_raw
    sql: ${TABLE}."COURSE_BEGIN_DATE" ;;
  }
  dimension: course_code {
    type: string
    sql: ${TABLE}."COURSE_CODE" ;;
  }
  dimension: course_end {
    type: date_raw
    sql: ${TABLE}."COURSE_END_DATE" ;;
  }
  dimension: course_id {
    type: number
    sql: ${TABLE}."COURSE_ID" ;;
  }
  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }
  dimension: course_type {
    type: string
    sql: ${TABLE}."COURSE_TYPE" ;;
  }
  dimension: course_uid {
    type: string
    sql: ${TABLE}."COURSE_UID" ;;
  }
  dimension: enrollment_completion {
    type: date_raw
    sql: ${TABLE}."ENROLLMENT_COMPLETION_DATE" ;;
  }
  dimension: enrollment_created_at {
    type: date_raw
    sql: case when ${TABLE}."ENROLLMENT_CREATED_AT" = '0000-00-00 00:00:00' then null else ${TABLE}."ENROLLMENT_CREATED_AT" end;;
  }
  dimension: enrollment_created_by {
    type: number
    sql: ${TABLE}."ENROLLMENT_CREATED_BY" ;;
  }
  dimension: enrollment_date_last_updated {
    type: date_raw
    sql: ${TABLE}."ENROLLMENT_DATE_LAST_UPDATED" ;;
  }
  dimension: enrollment_level {
    type: string
    sql: ${TABLE}."ENROLLMENT_LEVEL" ;;
  }
  dimension: enrollment_score {
    type: number
    sql: ${TABLE}."ENROLLMENT_SCORE" ;;
  }
  dimension: enrollment_status {
    type: string
    sql: ${TABLE}."ENROLLMENT_STATUS" ;;
  }
  dimension: enrollment_validity_begin {
    type: date_raw
    sql: ${TABLE}."ENROLLMENT_VALIDITY_BEGIN_DATE" ;;
  }
  dimension: enrollment_validity_end {
    type: date_raw
    sql: ${TABLE}."ENROLLMENT_VALIDITY_END_DATE" ;;
  }
  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [username, course_name]
  }
}
