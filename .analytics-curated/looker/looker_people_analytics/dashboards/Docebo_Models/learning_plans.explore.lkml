include: "/_standard/people_analytics/docebo/v_dim_learning_plan_course_enrollment.layer.lkml"
include: "/_standard/people_analytics/docebo/v_dim_learning_plan_course.layer.lkml"
include: "/_standard/people_analytics/docebo/v_dim_course.layer.lkml"
include: "/_standard/people_analytics/docebo/users.layer.lkml"
include: "/_standard/people_analytics/docebo/learning_plan.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/people_analytics/docebo/v_dim_learning_plan_enrollment.layer.lkml"

explore: v_dim_learning_plan_course_enrollment{

  case_sensitive: no


  join: v_dim_learning_plan_course{
    relationship: many_to_one
    type: left_outer
    sql_on: ${v_dim_learning_plan_course_enrollment.course_id}::varchar = ${v_dim_learning_plan_course.course_id}::varchar ;;

  }

  join: v_dim_course{
    type: left_outer
    relationship: one_to_many
    sql_on: ${v_dim_learning_plan_course.course_id}::varchar=  ${v_dim_course.course_key}::varchar ;;
  }


  join: users {
    type: left_outer
    relationship: many_to_one
    sql_on: ${v_dim_learning_plan_course_enrollment.username}::varchar =  ${users.name}::varchar;;
  }

  join: company_directory {
    type: left_outer
    relationship: many_to_one
    sql_on: REPLACE( ${users.employee_id},'CW')::varchar =  ${company_directory.employee_id}::varchar;;
  }

  join: learning_plan {
    relationship: many_to_one
    type: left_outer
    sql_on: ${v_dim_learning_plan_course_enrollment.learning_plan_key}::varchar = ${learning_plan.id}}::varchar ;;

  }

  join: v_dim_learning_plan_enrollment {
    relationship: many_to_one
    type: left_outer
    sql_on: ${v_dim_learning_plan_course_enrollment.learning_plan_key}::varchar = ${v_dim_learning_plan_enrollment.learning_plan_key}::varchar and ${v_dim_learning_plan_course_enrollment.user_id}::varchar = ${v_dim_learning_plan_enrollment.user_id}::varchar;;

  }
}
