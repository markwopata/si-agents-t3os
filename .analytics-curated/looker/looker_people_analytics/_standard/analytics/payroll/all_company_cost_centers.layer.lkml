include: "/_base/analytics/payroll/all_company_cost_centers.view.lkml"

view: +all_company_cost_centers {
  view_label: "All Company Cost Centers"

  # dimension: abbrev {
  #   type: string
  #   sql: ${TABLE}."ABBREV" ;;
  # }
  dimension: full_name {
    label: "Cost Center Full Path"
  }
  dimension: intaact {
    label: "Intacct"
    value_format_name: id
  }
  # dimension: location {
  # }

  dimension: name {
    label: "Cost Center"
  }
  # measure: count {
  #   type: count
  #   drill_fields: [name, full_name]
  # }
  dimension: division {
    sql: split_part(${full_name},'/',1) ;;
  }
  dimension: region {
    sql: split_part(${full_name},'/',2) ;;
  }
  dimension: district {
    sql: split_part(${full_name},'/',3) ;;
  }
  dimension: location {
    sql: split_part(${full_name},'/',4) ;;
  }
  dimension: cost_center {
    sql: split_part(${full_name},'/',5) ;;
  }
}
