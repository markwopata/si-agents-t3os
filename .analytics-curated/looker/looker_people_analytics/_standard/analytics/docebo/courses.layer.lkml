include: "/_base/analytics/docebo/courses.view.lkml"


view: +courses {

  ############### DIMENSIONS ###############
  dimension: id_course {
    value_format_name: id
  }

  ############### DATES ###############
  dimension_group: date_last_updated {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${date_last_updated} ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${_es_update_timestamp} ;;
  }
}
