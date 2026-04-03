include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/people_analytics/looker/performance_improvement_plan.layer.lkml"
include: "/_standard/people_analytics/looker/performance_reviews.layer.lkml"


explore:  company_directory {

  join: performance_reviews {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.employee_id}::varchar = ${performance_reviews.employee_id}::varchar;;
  }

  join: performance_improvement_plan{
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.employee_id}::varchar = ${performance_improvement_plan.employee_id}::varchar;;
  }
}
