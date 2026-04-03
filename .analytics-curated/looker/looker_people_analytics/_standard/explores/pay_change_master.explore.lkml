include: "/_standard/custom_sql/job_changes.view.lkml"
include: "/_standard/custom_sql/pay_changes.view.lkml"
include: "/_standard/organizational_summary/ee_company_directory_12_month.view.lkml"
# include: "/_standard/recruiting_kpis_standard/ukg_cost_center_market_id_mapping_standard.view.lkml"



explore: ee_company_directory_12_month {
  label: "Pay Change Master"
  case_sensitive: no

  join: job_changes {
    type:  left_outer
    relationship:  many_to_many
    sql_on:  ${job_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }

  join: pay_changes {
    type: left_outer
    relationship: many_to_many
    sql_on: ${pay_changes.employee_id} = ${ee_company_directory_12_month.employee_id} ;;
  }
}

##may need to add ukg_cost_center_market_id_mapping_standard in eventually. Need to investigate use case for this view and if needed before adding.
