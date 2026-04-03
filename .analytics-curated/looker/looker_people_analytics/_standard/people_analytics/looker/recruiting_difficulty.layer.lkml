include: "/_base/people_analytics/looker/recruiting_difficulty.view.lkml"

view: +recruiting_difficulty{


  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${_es_update_timestamp};;

  }

  measure: average_difficulty {
    type: average
    sql: ${difficulty_quartile} ;;

  }


}
