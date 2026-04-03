view: v_dim_learning_plan_course_enrollment {
  sql_table_name: "DOCEBO"."V_DIM_LEARNING_PLAN_COURSE_ENROLLMENT" ;;


  dimension: course_completion{
    type: date_raw
    sql: ${TABLE}."COURSE_COMPLETION_DATE" ;;
    hidden: yes
  }

  dimension: course_enrollment_date {
    type: date_raw
    sql:${TABLE}."COURSE_ENROLLMENT_DATE" ;;
    hidden: yes
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
  dimension: learning_plan_key {
    type: number
    sql: ${TABLE}."LEARNING_PLAN_KEY" ;;
  }
  dimension: learning_plan_name {
    type: string
    sql: ${TABLE}."LEARNING_PLAN_NAME" ;;
  }
  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }
  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }
  dimension: user_learningplan_course_enrollment_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."USER_LEARNINGPLAN_COURSE_ENROLLMENT_KEY" ;;
  }
  measure: count {
    type: count
    drill_fields: [learning_plan_name, course_name]
  }
}
