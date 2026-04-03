include: "/_base/people_analytics/docebo/v_dim_learning_plan_enrollment.view.lkml"


view: +v_dim_learning_plan_enrollment {

  dimension_group: learning_plan_completion_date{
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."LEARNING_PLAN_COMPLETION_DATE" ;;

  }

  dimension_group: learning_plan_enrollment_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql:${TABLE}."LEARNING_PLAN_ENROLLMENT_DATE" ;;

  }



}
