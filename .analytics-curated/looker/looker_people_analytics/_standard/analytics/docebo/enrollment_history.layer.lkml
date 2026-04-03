include: "/_base/analytics/docebo/enrollment_history.view.lkml"


view: +enrollment_history {

  ############### DIMENSIONS ###############
  dimension: overdue {
    type:  yesno
    sql:  ${enrollment_date_expire_validity_date} < CURRENT_DATE() and ${enrollment_status} != 'Completed' ;;
  }

  dimension_group: since_course_expire {
    type: duration
    intervals: [day,hour]
    sql_start: COALESCE(${enrollment_date_expire_validity},${course_date_end}) ;;
    sql_end: CURRENT_DATE() ;;
  }

  ############### DATES ###############
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${_es_update_timestamp} ;;
  }
  dimension_group: course_date_begin {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${course_date_begin} ;;
  }
  dimension_group: course_date_end {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${course_date_end} ;;
  }
  dimension_group: enrollment_date_begin_validity {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_date_begin_validity} ;;
  }
  dimension_group: enrollment_date_complete {
    label: "Enrollment Completion"
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${enrollment_date_complete} ;;
  }
  dimension_group: enrollment_date_expire_validity {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_date_expire_validity} ;;
  }
  dimension_group: enrollment_date_first_access {
    label: "First Access"
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_date_first_access} ;;
  }
  dimension_group: enrollment_date_inscr {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${enrollment_date_complete} ;;
  }
  dimension_group: user_register {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${user_register} ;;
  }
  dimension_group: user_suspend {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${user_suspend} ;;
  }

  ############### MEASURES ###############
  measure: days_overdue {
    type: average
    sql: CASE WHEN ${overdue} THEN ${days_since_course_expire} ELSE 0 END;;
  }
  measure: completed_count {
    type: count
    filters: [enrollment_status: "Completed"]
    drill_fields: [enrollment_details*]
  }
  measure: unique_completed_count {
    type: count_distinct
    filters: [enrollment_status: "Completed"]
    sql: ${user_userid} || ${course_uidcourse} ;;
    drill_fields: [enrollment_details*]
  }
  measure: subscribed_count {
    type: count
    filters: [enrollment_status: "Enrolled"]
    drill_fields: [enrollment_details*]
  }
  measure: unique_subscribed_count {
    type: count_distinct
    filters: [enrollment_status: "Enrolled"]
    sql: ${user_userid} || ${course_uidcourse} ;;
    drill_fields: [enrollment_details*]
  }
  measure: in_progress_count {
    type: count
    filters: [enrollment_status: "In Progress"]
    drill_fields: [enrollment_details*]
  }
  measure: unique_in_progress_count {
    type: count_distinct
    filters: [enrollment_status: "In Progress"]
    sql: ${user_userid} || ${course_uidcourse} ;;
    drill_fields: [enrollment_details*]
  }
  measure: overdue_count {
    type: sum
    filters: [overdue: "Yes"]
    sql: CASE WHEN ${overdue} THEN 1 ELSE 0 END;;
    drill_fields: [enrollment_details*, days_overdue]
  }
  measure: course_count {
    type: count
    drill_fields: [enrollment_details*]
  }
  measure: percent_complete {
    type: percent_of_total
    drill_fields: [user_details*]
    sql: ${completed_count} ;;
  }

  set: enrollment_details {
    fields: [user_userid, user_firstname, user_lastname, company_directory.employee_title, company_directory.date_hired_date, enrollments.enrollment_created_at_date, enrollment_date_complete_date, market_region_xwalk.market_name,users.name, market_region_xwalk.district_extend, user_email, users.manager_email, course_name, enrollment_status, enrollments.self_enrolled, archived_enrollment]
  }
  set: user_details {
    fields: [user_userid, user_firstname, user_lastname, company_directory.employee_title, company_directory.date_hired_date, enrollments.enrollment_created_at_date, enrollment_date_complete_date, market_region_xwalk.market_name, users.name, market_region_xwalk.district_extend, user_email, users.manager_email, percent_complete, course_count, completed_count, overdue_count]
  }
}
