include: "/_standard/organizational_summary/ee_company_directory_12_month.view.lkml"

view: +ee_company_directory_12_month {
  label: "Operational Company Directory 12 Month"


measure: headcount_with_drill {
  type: count
  drill_fields: [regional_totals*]
}

measure: region_headcount {
  type: count
  drill_fields: [district_totals*]
}

measure: district_headcount {
 type: count
# filters: [district_ind: "yes"]
 drill_fields: [headcount_details*]
}

set: regional_totals {
  fields: [region2,
        region_headcount]
}

set: district_totals {
  fields: [district,
    count]
}

set: headcount_details {
  fields: [division,
    region2,
    district,
    department,
    exempt_status,
    remote,
    last_name,
    first_name,
    employee_title,
    direct_manager_name,
    date_hired_date,
    date_rehired_date,
    disc_link]
}
}
