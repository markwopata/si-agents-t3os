include: "/_standard/people_analytics/workday_raas/employee_disc_codes.layer.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/analytics/public/disc_master.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_requisition_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"

view: +company_directory {

  dimension: tenure_months {
    type: number
    sql: datediff(months,${date_most_recent_hire_date},coalesce(${date_terminated_date},current_date)) ;;
    description: "Number of months from most recent hire date until current date."
  }
}

view: +v_dim_candidate {

  dimension: disc_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://www.discoveryreport.com/v/{{ employee_disc_codes.disc_code | url_encode }}" target="_blank">DISC Link</a></font></u>;;
    sql: 'Link' ;;
  }
}

explore: company_directory {
  label: "Employee Disc Analytics"

  join: employee_disc_codes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.employee_id}::varchar = ${employee_disc_codes.employee_id}::varchar ;;
  }

  join: disc_master {
    type: left_outer
    relationship: one_to_one
    sql_on: ${employee_disc_codes.disc_code}::varchar = ${disc_master.disc_code}::varchar ;;
  }

  join: v_fact_application_requisition_offer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.greenhouse_application_id}::varchar = ${v_fact_application_requisition_offer.application_requisition_offer_application_key}::varchar ;;
  }

  join: v_dim_candidate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_candidate_key}::varchar = ${v_dim_candidate.candidate_key}::varchar ;;
  }

  join: v_dim_application {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_application_key}::varchar = ${v_dim_application.application_key}::varchar ;;
  }
}
