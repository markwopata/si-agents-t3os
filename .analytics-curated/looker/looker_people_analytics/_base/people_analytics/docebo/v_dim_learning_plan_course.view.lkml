view: v_dim_learning_plan_course {
  sql_table_name: "DOCEBO"."V_DIM_LEARNING_PLAN_COURSE" ;;

  dimension: course_id {
    type: number
    sql: ${TABLE}."COURSE_ID" ;;
  }
  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }
  dimension: learning_plan_key {
    primary_key: yes
    type: number
    sql: ${TABLE}."LEARNING_PLAN_KEY" ;;
  }
  dimension: learning_plan_name {
    type: string
    sql: ${TABLE}."LEARNING_PLAN_NAME" ;;
  }
  dimension: lp_course_count {
    type: number
    sql: ${TABLE}."LP_COURSE_COUNT" ;;
  }
  measure: count {
    type: count
    drill_fields: [course_name, learning_plan_name]
  }
}
