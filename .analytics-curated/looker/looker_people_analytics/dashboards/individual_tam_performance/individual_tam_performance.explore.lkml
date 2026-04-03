include: "/_standard/people_analytics/workday_raas/employee_disc_codes.layer.lkml"
include: "/dashboards/individual_tam_performance/company_directory_tam_performance.view"



view: +employee_disc_codes {

  dimension: disc_link {
    type: string
    html:
      <font color="blue " ><u><a href = "https://www.discoveryreport.com/v/{{ employee_disc_codes.disc_code | url_encode }}" target="_blank" style="font-size: 20px;">DISC Link</a></font></u>;;
    sql: 'Link' ;;
  }

  dimension: disc_link2 {
    type: string
    html:
      <font color="blue " ><u><a href = "https://www.discoveryreport.com/v/{{ employee_disc_codes.disc_code | url_encode }}" target="_blank"; >DISC Link</a></font></u>;;
    sql: 'Link' ;;
  }
}


explore: company_directory_tam_performance {
  group_label: "TAM Performance DISC"
  label: "Employee Disc Analytics for TAMs"

  join: employee_disc_codes {
    type: left_outer
    relationship: one_to_one
    sql_on: ${company_directory_tam_performance.employee_id} = ${employee_disc_codes.employee_id} ;;
  }



}
