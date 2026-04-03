view: v_dim_course_enrollment {
  sql_table_name: "PEOPLE_ANALYTICS"."DOCEBO"."V_DIM_COURSE_ENROLLMENT" ;;

  dimension: course_completion_date {
    type: date_raw
    sql: ${TABLE}."COURSE_COMPLETION_DATE" ;;
  }
  dimension: course_enrollment_date {
    type: date_raw
    sql: ${TABLE}."COURSE_ENROLLMENT_DATE" ;;
  }
  dimension: course_enrollment_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."COURSE_ENROLLMENT_KEY" ;;
  }
  dimension: course_id {
    type: number
    sql: ${TABLE}."COURSE_ID" ;;
  }
  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }
  dimension: enrollment_status {
    type: string
    sql: ${TABLE}."ENROLLMENT_STATUS" ;;
  }
  dimension: enrollment_to_completion_hours {
    type: number
    sql: ${TABLE}."ENROLLMENT_TO_COMPLETION_HOURS" ;;
  }
  dimension: user_employee_id {
    type: string
    sql: ${TABLE}."USER_EMPLOYEE_ID" ;;
  }
  dimension: user_fullname {
    type: string
    sql: ${TABLE}."USER_FULLNAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [course_name, user_fullname]
  }
}
