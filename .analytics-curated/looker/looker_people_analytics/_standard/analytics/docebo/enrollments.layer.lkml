include: "/_base/analytics/docebo/enrollments.view.lkml"


view: +enrollments {

  ############### DIMENSIONS ###############
  dimension: user_id {
    value_format_name: id
  }
  dimension: course_id {
    value_format_name: id
  }
  dimension: self_enrolled {
    type:  yesno
    sql:  ${enrollment_created_by} = ${user_id} ;;
  }

  ############### DATES ###############
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${_es_update_timestamp} ;;
  }
  dimension_group: course_begin_date {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${course_begin} ;;
  }
  dimension_group: course_end_date {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${course_end} ;;
  }
  dimension_group: enrollment_created_at {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_created_at} ;;
  }
  dimension_group: enrollment_validity_begin_date {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_validity_begin} ;;
  }
  dimension_group: enrollment_validity_end_date {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_validity_end} ;;
  }
  dimension_group: enrollment_date_last_updated {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_date_last_updated} ;;
  }
  dimension_group: enrollment_completion_date {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_completion} ;;
  }
}
