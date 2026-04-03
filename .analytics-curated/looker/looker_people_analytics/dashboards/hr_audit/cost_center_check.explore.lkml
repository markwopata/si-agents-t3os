include: "/_standard/analytics/payroll/company_directory.layer.lkml"
include: "/_standard/analytics/payroll/all_company_cost_centers.layer.lkml"

view: +company_directory {
  measure: mismatched_cc_count {
    description: "Count of employees with a cost center that does not match company defined cost centers."
    type: count
    drill_fields: [employee_id,employee_name,date_hired,default_cost_centers_full_path,all_company_cost_centers.full_name]
  }
  dimension: default_cc_division {
    group_label: "Cost Center Breakdown"
    type: string
    sql: split_part(${default_cost_centers_full_path},'/',1);;
  }
  dimension: default_cc_region {
    group_label: "Cost Center Breakdown"
    type: string
    sql: split_part(${default_cost_centers_full_path},'/',2);;
  }
  dimension: default_cc_district {
    group_label: "Cost Center Breakdown"
    type: string
    sql: split_part(${default_cost_centers_full_path},'/',3);;
  }
  dimension: default_cc_location {
    group_label: "Cost Center Breakdown"
    type: string
    sql: split_part(${default_cost_centers_full_path},'/',4);;
  }
  dimension: default_cc_cost_center {
    group_label: "Cost Center Breakdown"
    type: string
    sql: split_part(${default_cost_centers_full_path},'/',5);;
  }
}

explore: company_directory {
  label: "Company Directory Cost Center Check"
  case_sensitive: no

  join: all_company_cost_centers {
    relationship: many_to_one
    type: left_outer
    sql_on: ${company_directory.market_id} = ${all_company_cost_centers.intaact} and ${company_directory.subdepartment} = ${all_company_cost_centers.name} ;;
  }
}
