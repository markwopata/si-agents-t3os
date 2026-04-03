include: "/_base/analytics/payroll/company_directory_dsm.view.lkml"

view: +company_directory_dsm {
  label: "company_directory_dsm"

  dimension: account_id {
    primary_key: yes
  }
  dimension_group: date_hired {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: date(${date_hired}) ;;
  }
  dimension_group: date_rehired {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: date(${date_rehired}) ;;
  }
  dimension_group: date_terminated {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: date(${date_terminated}) ;;
  }
  dimension_group: date_most_recent_hire {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: CASE WHEN date(${date_rehired}) IS NOT NULL THEN date(${date_rehired}) ELSE date(${date_hired}) END ;;
  }
  dimension_group: position_effective_date {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: date(${position_effective_date});;
  }
  # dimension: default_cost_centers_full_path {
  #   type: string
  #   sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  # }
  dimension: direct_manager_employee_id {
    value_format_name: id
  }
  dimension: division {
    type: string
    sql: split_part(${default_cost_centers_full_path},'/',1) ;;
  }
  dimension: district {
    type: string
    sql: split_part(${default_cost_centers_full_path},'/', 3) ;;
  }
  dimension: cost_center_location {
    type: string
    sql: split_part(${default_cost_centers_full_path},'/', 4) ;;
  }
  dimension: department {
    type: string
    sql: split_part(${default_cost_centers_full_path},'/', 4) ;;
  }
  dimension: region {
    type: string
    sql: case when contains(split_part(${default_cost_centers_full_path},'/', 2),'R1') then 'R1 Pacific'
          when contains(split_part(${default_cost_centers_full_path},'/', 2),'R2') then 'R2 Mountain West'
          when contains(split_part(${default_cost_centers_full_path},'/', 2),'R3') then 'R3 Southwest'
          when contains(split_part(${default_cost_centers_full_path},'/', 2),'R4') then 'R4 Midwest'
          when contains(split_part(${default_cost_centers_full_path},'/', 2),'R5') then 'R5 Southeast'
          when contains(split_part(${default_cost_centers_full_path},'/', 2),'R6') then 'R6 Northeast'
          when contains(split_part(${default_cost_centers_full_path},'/', 2),'R7') then 'R7 Industrial'
          else null end;;
  }
  dimension: subdepartment {
    type: string
    sql: split_part(${default_cost_centers_full_path},'/', 5) ;;
  }
  # dimension: direct_manager_name {
  #   type: string
  #   sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  # }
  # dimension: doc_uname {
  #   type: string
  #   sql: ${TABLE}."DOC_UNAME" ;;
  # }
  # dimension: ee_state {
  #   type: string
  #   sql: ${TABLE}."EE_STATE" ;;
  # }
  dimension: employee_id {
    value_format_name: id
  }
  dimension: employee_name {
    type: string
    sql: ${first_name}||' '||${last_name} ;;
  }
  # dimension: employee_status {
  #   type: string
  #   sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  # }
  # dimension: employee_title {
  #   type: string
  #   sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  # }
  # dimension: employee_type {
  #   type: string
  #   sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  # }
  # dimension: first_name {
  #   type: string
  #   sql: ${TABLE}."FIRST_NAME" ;;
  # }
  # dimension: greenhouse_application_id {
  #   type: number
  #   sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  # }
  # dimension: home_phone {
  #   type: string
  #   sql: ${TABLE}."HOME_PHONE" ;;
  # }
  # dimension: labor_distribution_profile {
  #   type: string
  #   sql: ${TABLE}."LABOR_DISTRIBUTION_PROFILE" ;;
  # }
  # dimension: last_name {
  #   type: string
  #   sql: ${TABLE}."LAST_NAME" ;;
  # }
  dimension_group: last_updated_date {
    type: time
    timeframes: [date,week,month,quarter,year]
    sql: ${last_updated_date} ;;
  }
  # dimension: location {
  #   type: string
  #   sql: ${TABLE}."LOCATION" ;;
  # }
  dimension: market_id {
    value_format_name: id
  }
  # dimension: nickname {
  #   type: string
  #   sql: ${TABLE}."NICKNAME" ;;
  # }
  # dimension: pay_calc {
  #   type: string
  #   sql: ${TABLE}."PAY_CALC" ;;
  # }
  # dimension: personal_email {
  #   type: string
  #   sql: ${TABLE}."PERSONAL_EMAIL" ;;
  # }
  # dimension: tax_location {
  #   type: string
  #   sql: ${TABLE}."TAX_LOCATION" ;;
  # }
  # dimension: work_email {
  #   type: string
  #   sql: ${TABLE}."WORK_EMAIL" ;;
  # }
  # dimension: work_phone {
  #   type: string
  #   sql: ${TABLE}."WORK_PHONE" ;;
  # }
  measure: count_distinct {
    type: count_distinct
    drill_fields: [last_name, direct_manager_name, first_name]
  }
  dimension: is_market_management {
    type: yesno
    sql:${employee_title} in ('Area General Manager', 'Area Sales Developer', 'Business Development Manager',
               'District Operations Manager', 'Facility Administrator', 'General Manager - Industrial Tooling',
               'Market Consultant Manager', 'Operations Manager', 'Parts & Service Administrator',
               'Regional Manager - Industrial Services', 'Rental Coordinator - Industrial Tooling', 'Retail Parts Manager',
               'Tool Trailer Manager','Assistant General Manager','Service Manager','General Manager',
               'Parts Manager') ;;
  }
  dimension: key_ops_jobs {
    type: string
    sql: CASE WHEN CONTAINS(${employee_title}, 'General Manager') AND NOT CONTAINS(${employee_title}, 'Assistant General Manager') THEN 'General Managers'
          WHEN CONTAINS(${employee_title}, 'Assistant General Manager') THEN 'Assistant General Managers'
          WHEN (CONTAINS(${employee_title}, 'CDL') AND CONTAINS(${employee_title}, 'Driver') AND NOT CONTAINS(${employee_title}, 'non-CDL') AND NOT CONTAINS(${employee_title}, 'Non-CDL')) THEN 'Drivers (CDL)'
          WHEN CONTAINS(${employee_title}, 'Driver') THEN 'Drivers'
          WHEN CONTAINS(${employee_title}, 'Field Technician') THEN 'Field Technicians'
          WHEN CONTAINS(${employee_title}, 'Shop Technician') THEN 'Shop Technicians'
          WHEN CONTAINS(${employee_title}, 'Yard Technician') THEN 'Yard Technician'
          WHEN CONTAINS(${employee_title}, 'Rental Coordinator') THEN 'Rental Coordinators'
          WHEN CONTAINS(${employee_title}, 'Service Manager') THEN 'Service Managers'
          WHEN CONTAINS(${employee_title}, 'Parts Assistant') THEN 'Parts Assistants'
          WHEN CONTAINS(${employee_title}, 'Parts Manager') THEN 'Parts Managers'
          WHEN CONTAINS(${employee_title}, 'Dispatcher') THEN 'Dispatchers'
          WHEN CONTAINS(${employee_title}, 'Regional Manager') THEN 'Regional Managers'
          WHEN CONTAINS(${employee_title}, 'District Manager') THEN 'District Managers'
          WHEN CONTAINS(${employee_title}, 'Telematics Installer') THEN 'Telematics Installers'
          WHEN CONTAINS(${employee_title}, 'Territory Account Manager') THEN 'Territory Account Managers'
          ELSE 'Other' END ;;
  }
  dimension: tenure_months {
    type: number
    sql: datediff(months,coalesce(${position_effective_date_date},${date_most_recent_hire_date}),coalesce(${date_terminated_date},current_date)) ;;
    description: "Number of months from effective date date until current date."
  }
  dimension: tenure_buckets {
    type: string
    sql: CASE WHEN ${tenure_months} >= 0 and ${tenure_months} <= 2 then '0-3 Months'
          WHEN ${tenure_months} >= 3 and ${tenure_months} <= 5 then '4-6 Months'
          WHEN ${tenure_months} >= 6 and ${tenure_months} <= 11 then '6-12 Months'
          WHEN ${tenure_months} >= 12 and ${tenure_months} <= 23 then '12-24 Months'
          ELSE '24+ Months' END;;
  }
  dimension: tenure_buckets_order {
    type: number
    sql: CASE WHEN ${tenure_buckets} = '0-3 Months' then 1
          WHEN ${tenure_buckets} = '4-6 Months' then 2
          WHEN ${tenure_buckets} = '6-12 Months' then 3
          WHEN ${tenure_buckets} = '12-24 Months' then 4
          ELSE 5 END;;
  }
  measure: employee_count {
    type: count
    drill_fields: [employee_id,
      first_name,
      last_name,
      employee_title,
      location,
      default_cost_centers_full_path,
      date_hired_date,
      date_rehired_date,
      date_terminated_date]
  }
}
