include: "/_standard/es_warehouse/public/invoices.layer.lkml"
include: "/_standard/custom_sql/stg_es_warehouse_public__approvied_invoice_salespersons.view.lkml"
include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/es_warehouse/public/users.layer.lkml"
include: "/_standard/people_analytics/workday_raas/employee_disc_codes.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_fact_application_requisition_offer.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_candidate.layer.lkml"
include: "/_standard/people_analytics/greenhouse/v_dim_application.layer.lkml"

view: +employee_disc_codes {

  dimension: disc_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://www.discoveryreport.com/v/{{ disc_code | url_encode }}" target="_blank">DISC Link</a></font></u>;;
    sql: 'Link' ;;
  }
  dimension: scorecard_link {
    type: string
    html:
      <font color="blue "><u><a href = "https://app.greenhouse.io/people/{{ v_fact_application_requisition_offer.application_requisition_offer_candidate_key | url_encode }}/applications/{{ greenhouse_application_id | url_encode }}/redesign#scorecard" target="_blank">Scorecard Link</a></font></u>;;
    sql: 'Link' ;;
  }
}

view: +v_dim_candidate {

  measure: sum_scorecard_score {
    type: sum
    sql: ${candidate_custom_scorecard_score};;
    description: "The sum of all scorecard scores"
  }

  measure: average_scorecard_score {
    type: number
    sql: round(${sum_scorecard_score}/${unique_candidate_ids});;
    description: "The sum of all scorecard scores divided by the number of unique candidates"
    drill_fields: [tam_performance_previous_month.employee_id,
      tam_performance_previous_month.name,
      employee_disc_codes.employee_status,
      candidate_custom_scorecard_score]
  }
}

view: +stg_es_warehouse_public__approvied_invoice_salespersons{

  measure: average_total_revenue {
    type: number
    sql: sum(${stg_es_warehouse_public__approvied_invoice_salespersons.revenue})/count(distinct ${stg_es_warehouse_public__approvied_invoice_salespersons.salesperson_id});;
    link: {
      label: "TAM Performance Details"
      url: "https://equipmentshare.looker.com/dashboards/1612?Region=&Market=&District=&Application+Source+Name="
    }
    description: "The average total revenue."
  }
}

explore: invoices {
  label: "TAM Scorecard Performance"

  join: stg_es_warehouse_public__approvied_invoice_salespersons {
    type: inner
    relationship: many_to_many
    sql_on: ${invoices.invoice_id} = ${stg_es_warehouse_public__approvied_invoice_salespersons.invoice_id} ;;
  }
  join: users {
    type: inner
    relationship: one_to_one
    sql_on: try_to_number(${stg_es_warehouse_public__approvied_invoice_salespersons.salesperson_id}) = ${users.user_id} ;;
  }

  join: company_directory {
    type: inner
    relationship: one_to_one
    sql_on: try_to_number(${users.employee_id}) = ${company_directory.employee_id} and ${users.company_id} = 1854 and ${company_directory.employee_title} = 'Territory Account Manager';;
  }

  join: employee_disc_codes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.employee_id} = ${employee_disc_codes.employee_id} ;;
  }

  join: v_fact_application_requisition_offer {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory.greenhouse_application_id} = ${v_fact_application_requisition_offer.application_requisition_offer_application_key} ;;
  }

  join: v_dim_candidate {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_candidate_key} = ${v_dim_candidate.candidate_key} ;;
  }

  join: v_dim_application {
    type: left_outer
    relationship: one_to_one
    sql_on: ${v_fact_application_requisition_offer.application_requisition_offer_application_key} = ${v_dim_application.application_key} ;;
  }
}
