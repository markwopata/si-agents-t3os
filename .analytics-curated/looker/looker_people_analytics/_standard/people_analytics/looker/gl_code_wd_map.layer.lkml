include: "/_base/people_analytics/looker/gl_code_wd_map.view.lkml"

view: +gl_code_wd_map {


  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${_es_update_timestamp};;

  }


}
