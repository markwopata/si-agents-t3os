view: v_dim_learning_plan_enrollment {
  sql_table_name: "DOCEBO"."V_DIM_LEARNING_PLAN_ENROLLMENT_RAW_API" ;;

  dimension: courses_completed {
    type: number
    sql: ${TABLE}."COURSES_COMPLETED" ;;
  }
  dimension: courses_enrolled {
    type: number
    sql: ${TABLE}."COURSES_ENROLLED" ;;
  }
  dimension: courses_in_progress {
    type: number
    sql: ${TABLE}."COURSES_IN_PROGRESS" ;;
  }
  dimension: courses_total {
    type: number
    sql: ${TABLE}."COURSES_TOTAL" ;;
  }

  dimension: key {
    type: number
    sql: ${TABLE}."KEY" ;;
  }
  dimension: learning_plan_completed {
    type: yesno
    sql: ${TABLE}."LEARNING_PLAN_COMPLETED" ;;
  }
  dimension: learning_plan_completion_date {
    type: date_raw
    sql: ${TABLE}."LEARNING_PLAN_COMPLETION_DATE" ;;
    hidden:  yes
  }
  dimension: learning_plan_enrollment_date {
    type: date_raw
    sql: ${TABLE}."LEARNING_PLAN_ENROLLMENT_DATE" ;;
    hidden:  yes
  }
  dimension: learning_plan_key {
    type: string
    sql: ${TABLE}."LEARNING_PLAN_KEY" ;;
  }
  dimension: learning_plan_name {
    type: string
    sql: ${TABLE}."LEARNING_PLAN_NAME" ;;
  }
  dimension: learning_plan_user {
    type: string
    sql: ${TABLE}."LEARNING_PLAN_USER" ;;
  }
  dimension: learning_plan_user_key {
    primary_key:  yes
    type: string
    sql: ${TABLE}."LEARNING_PLAN_USER_KEY" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [learning_plan_name]
  }
}
