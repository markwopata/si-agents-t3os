include: "/_base/people_analytics/docebo/learning_plan.view.lkml"


view: +learning_plan{



  dimension_group: create {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."CREATE_DATE" ;;

  }
  dimension_group: date_last_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_LAST_UPDATED" ;;

  }

}
