connection: "es_snowflake_analytics"

include: "/views/ANALYTICS/docebo_courses.view.lkml"
include: "/views/ANALYTICS/docebo_enrollments.view.lkml"
include: "/views/ANALYTICS/docebo_users.view.lkml"

include: "/views/ANALYTICS/company_directory.view.lkml"

include: "/views/ES_WAREHOUSE/markets.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk.view.lkml"
include: "/views/ANALYTICS/market_region_xwalk_with_extensions.view.lkml"

include: "/views/ANALYTICS/docebo_historical_enrollment.view.lkml"

include: "/views/custom_sql/docebo_user_status.view.lkml"
include: "/views/ANALYTICS/docebo_learning_plans.view.lkml"

# Commented out due to low usage on 2026-03-26
# explore: company_directory{
#   label: "Docebo Enrollment Statistics"
#   case_sensitive: no
#   symmetric_aggregates: yes
#   sql_always_where: ${employee_status} in ('Active','External Payroll','Leave with Pay','Leave without Pay','Work Comp Leave','On Leave','Seasonal (Fixed Term) (Seasonal)','Apprentice','Military Intern')   ;;
#
#   join: docebo_users{
#      type: inner
#      relationship: one_to_one
#      sql_on: to_char(${company_directory.employee_id}) = ${docebo_users.username};;
#   }
#
#   join: markets {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${company_directory.market_id} = ${markets.market_id} ;;
#   }
#
#   join: market_region_xwalk {
#     relationship: many_to_one
#     sql_on: ${markets.market_id} = ${market_region_xwalk.market_id} ;;
#   }
#
#   join: market_region_xwalk_with_extensions {
#     type: left_outer
#     relationship: many_to_one
#     sql_on: ${market_region_xwalk.market_id} = ${market_region_xwalk_with_extensions.market_id} ;;
#   }
#
#   join: docebo_user_status {
#     type: inner
#     relationship: one_to_one
#     sql_on: ${docebo_users.username} = ${docebo_user_status.user_id} ;;
#   }
#
#   join: docebo_historical_enrollment {
#     type: left_outer
#     relationship: one_to_many
#     sql_on: ${docebo_users.username} = ${docebo_historical_enrollment.user_id};;
#   }
#
#   join: docebo_enrollments {
#     relationship: one_to_one
#     sql_on: ${docebo_historical_enrollment.course_uid} = ${docebo_enrollments.course_uid} and ${docebo_historical_enrollment.user_id} = ${docebo_enrollments.username};;
#   }
#
#   join: docebo_courses {
#     relationship: many_to_one
#     sql_on: ${docebo_enrollments.course_id} = ${docebo_courses.course_id};;
#   }
#
#   join: docebo_learning_plans {
#     relationship: one_to_one
#     sql_on: ${docebo_enrollments.course_id} = ${docebo_learning_plans.id} ;;
#   }
# }
