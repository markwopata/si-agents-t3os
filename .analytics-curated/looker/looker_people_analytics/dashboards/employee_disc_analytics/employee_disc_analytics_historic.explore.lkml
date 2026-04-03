include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/people_analytics/talent_acquisition/disc_master_historic.layer.lkml"
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
      <font color="blue "><u><a href = "https://www.discoveryreport.com/v/{{ disc_master_historic.disc_code | url_encode }}" target="_blank">DISC Link</a></font></u>;;
    sql: 'Link' ;;
  }
}

explore: company_directory {
  label: "Employee Disc Analytics Historic"

  join: disc_master_historic {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.work_email} = ${disc_master_historic.email_address} or ${company_directory.personal_email} = ${disc_master_historic.email_address} ;;
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
