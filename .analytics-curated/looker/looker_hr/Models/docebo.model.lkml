connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/docebo_courses.view.lkml"
include: "/views/ANALYTICS/docebo_lp.view.lkml"
include: "/views/ANALYTICS/ukg_employee_details.view.lkml"
include: "/views/ANALYTICS/ukg_employees.view.lkml"
include: "/views/ANALYTICS/docebo_user_data.view.lkml"
#include: "/views/ANALYTICS/docebo_enrollment_history.view.lkml"
include: "/views/ANALYTICS/courses.view.lkml"
include: "/views/custom_sql/enrollment_history.view.lkml"

explore: courses {
  label: "Employee Training"

  join: enrollment_history {
    type: left_outer
    relationship: many_to_many
    sql_on: ${courses.uidcourse} = ${enrollment_history.course_uidcourse} ;;
  }

  join: docebo_user_data {
    type: left_outer
    relationship: many_to_many
    sql_on: ${enrollment_history.user_userid} = ${docebo_user_data.employee_number} ;;
  }
}

explore: docebo_courses {
  case_sensitive: no
  persist_for: "24 hours"

  join: ukg_employee_details {
    type: left_outer
    relationship: many_to_one
    sql_on: ${docebo_courses.employee_number}=${ukg_employee_details.employee_id} ;;
  }}

explore: docebo_lp {
  case_sensitive: no
  persist_for: "24 hours"

  join: ukg_employee_details {
    type: left_outer
    relationship: many_to_one
    sql_on: ${docebo_lp.employee_number}=${ukg_employee_details.employee_id} ;;
  }}

  explore: ukg_employees {
    case_sensitive: no
    persist_for: "24 hours"
    sql_always_where: ${hire_date} <= current_timestamp ;;
    }
