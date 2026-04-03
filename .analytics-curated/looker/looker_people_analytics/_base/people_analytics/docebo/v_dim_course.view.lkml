view: v_dim_course {
  sql_table_name: "PEOPLE_ANALYTICS"."DOCEBO"."V_DIM_COURSE" ;;

  dimension: can_self_enroll {
    type: yesno
    sql: ${TABLE}."CAN_SELF_ENROLL" ;;
  }
  dimension: course_category {
    type: string
    sql: ${TABLE}."COURSE_CATEGORY" ;;
  }
  dimension: course_code {
    type: string
    sql: ${TABLE}."COURSE_CODE" ;;
  }
  dimension: course_duration {
    type: number
    sql: ${TABLE}."COURSE_DURATION" ;;
  }
  dimension: course_key {
    primary_key:  yes
    type: number
    sql: ${TABLE}."COURSE_KEY" ;;
  }
  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }
  dimension: course_status {
    type: string
    sql: ${TABLE}."COURSE_STATUS" ;;
  }
  measure: count {
    type: count
    drill_fields: [course_name]
  }
}
