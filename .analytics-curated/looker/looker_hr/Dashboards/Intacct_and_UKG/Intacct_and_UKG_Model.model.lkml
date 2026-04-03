connection: "es_snowflake_analytics"

include:      "/Dashboards/Intacct_and_UKG/department.view.lkml"
include:      "/Dashboards/Intacct_and_UKG/ukg_all_company_cost_centers.view.lkml"




explore: department{
  label: "Intacct missing from UKG"
  join: ukg_all_company_cost_centers {
    type: left_outer
    relationship: one_to_many
    sql_on:  to_varchar(${department.departmentid})=to_varchar(${ukg_all_company_cost_centers.intaact});;
  }
}



explore: ukg_all_company_cost_centers{
  label: "UKG Cost Centers missing from Intacct"
  join: department {
    type: left_outer
    relationship: many_to_one
    sql_on:  to_varchar(${ukg_all_company_cost_centers.intaact}) =  to_varchar(${department.departmentid});;
  }
}
