include: "/_base/people_analytics/docebo/v_dim_learning_plan_course_enrollment.view.lkml"


view: +v_dim_learning_plan_course_enrollment {

  dimension_group: course_completion{
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."COURSE_COMPLETION_DATE" ;;

  }

  dimension_group: course_enrollment_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql:${TABLE}."COURSE_ENROLLMENT_DATE" ;;

  }



}
