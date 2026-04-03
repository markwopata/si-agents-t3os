include: "/_standard/explores/docebo_base.explore"
include: "/_standard/analytics/docebo/courses.layer.lkml"
include: "/_standard/analytics/docebo/enrollment_history.layer.lkml"
include: "/_standard/analytics/docebo/enrollments.layer.lkml"

explore: +company_directory {
  label: "PA Docebo Courses"


  join: users {
    type: inner
    relationship: one_to_one
    sql_on: to_varchar(${company_directory.employee_id}) = ${users.employee_id_corrected};;

  }

  join: markets {
    type: left_outer
    relationship: many_to_one
    sql_on: ${company_directory.market_id} = ${markets.market_id} ;;
  }

  join: market_region_xwalk {
    type: left_outer
    relationship: many_to_one
    sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
  }

  join: enrollment_history {
    type: left_outer
    relationship: one_to_one
    sql_on: ${users.encoded_username} = ${enrollment_history.user_userid} ;;
  }

  join: enrollments {
    type: left_outer
    relationship: one_to_one
    sql_on: ${enrollment_history.course_uidcourse} = ${enrollments.course_uid} and ${enrollment_history.user_userid} = ${enrollments.username};;
  }

  join: courses {
    type: left_outer
    relationship: many_to_one
    sql_on: ${enrollments.course_id} = ${courses.id_course} ;;
  }
}
