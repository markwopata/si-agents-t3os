include: "/_base/people_analytics/docebo/v_dim_course_enrollment.view.lkml"


view: +v_dim_course_enrollment {
  label: "Dim Course Enrollment"

  ############### DATES ###############

  dimension_group: course_enrollment_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${course_enrollment_date} ;;
  }

  dimension_group: course_completion_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${course_completion_date} ;;
  }

  ############### MEASURES ###############

  set: enrollments {
    fields: [users.id,
      users.fullname,
      users.employee_title,
      users.location_name,
      users.email,
      users.manager_email,
      course_name,
      enrollment_status]
  }

  measure: enrolled_count_distinct {
    type: count_distinct
    sql: ${course_enrollment_key} ;;
    filters: [enrollment_status: "Enrolled"]
    drill_fields: [enrollments*]
  }

  measure: in_progress_count_distinct {
    type: count_distinct
    sql: ${course_enrollment_key} ;;
    filters: [enrollment_status: "In Progress"]
    drill_fields: [enrollments*]
  }

  measure: completed_count_distinct {
    type: count_distinct
    sql: ${course_enrollment_key} ;;
    filters: [enrollment_status: "Completed"]
    drill_fields: [enrollments*]
  }

  measure: total_enrollments_count_distinct {
    type: count_distinct
    sql: ${course_enrollment_key} ;;
    drill_fields: [enrollments*]
  }

}
