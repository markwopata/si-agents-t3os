include: "/_base/analytics/payroll/ee_company_directory_12_month.view.lkml"

view: +ee_company_directory_12_month {
  label: "EE Company Directory 12 Month"

  dimension: primary_key {
    primary_key: yes
    type: string
    sql:  concat(${employee_id},${_es_update_timestamp_date}) ;;
  }

  dimension_group: _es_update_timestamp {
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${_es_update_timestamp_date} ;;
  }

  dimension_group: position_effective {
    timeframes: [date,week,month,quarter,year]
    sql: ${position_effective} ;;
  }

  dimension: last_12_month {
    description: "Indicator to filter records that fall within the last full 12 months. Using this would exclude current month data."
    type: yesno
    sql: ${_es_update_timestamp_raw} >= dateadd('second',1,(dateadd('month',-12,(dateadd('second',-1,date_trunc('month',current_date))))))
      and ${_es_update_timestamp_raw} <= dateadd('second',-1,date_trunc('month',current_date));;
  }

  dimension_group: date_hired {
    hidden: yes
  }

  dimension_group: date_hired2 {
    label: "Date Hired"
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${date_hired};;
  }

  dimension_group: date_rehired {
    hidden: yes
  }

  dimension_group: date_rehired2 {
    label: "Date Rehired"
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${date_rehired} ;;
  }

  dimension_group: most_recent_hire_date {
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: CASE
            WHEN ${date_rehired} IS NOT NULL THEN ${date_rehired} ELSE ${date_hired} END ;;
  }

  dimension_group: date_terminated {
    hidden: yes
  }

  dimension_group: date_terminated2 {
    label: "Date Terminated"
    type: time
    timeframes: [raw,time,date,week,month,quarter,year]
    sql: ${date_terminated};;
  }

  # dimension: default_cost_centers_full_path {
  #   type: string
  #   sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  # }

  dimension: department {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${default_cost_centers_full_path},'/','3')
      ELSE SPLIT_PART(${default_cost_centers_full_path},'/','4') END;;
  }

  dimension: direct_manager_employee_id {
    value_format_name: id
  }

  # dimension: direct_manager_name {
  #   type: string
  #   sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  # }

  # dimension: disc_code{
  #   type: string
  #   sql: ${TABLE}."DISC_CODE" ;;
  # }

  dimension: disc_link {
    type: string
    sql: CASE WHEN ${disc_code} IS NOT NULL THEN CONCAT('https://www.discoveryreport.com/v/', ${disc_code}) ELSE 'No DISC' END;;
    html: <font color="blue "><u><a href="{{ value }}" target="_blank" title="Link to DISC"> {{rendered_value}}</a> ;;
  }

  dimension: district {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${default_cost_centers_full_path},'/','2')
      ELSE SPLIT_PART(${default_cost_centers_full_path},'/','3') END;;
  }

  dimension: division {
    type: string
    sql: CASE WHEN (${_es_update_timestamp_date} < TO_DATE('2023-01-01') AND startswith(${default_cost_centers_full_path},'R')) THEN 'Rental'
      ELSE SPLIT_PART(${default_cost_centers_full_path},'/','1') END;;
  }

  dimension: district_ind {
    description: "Indicator for primary districts only to filter out other non-district employees such as Corporate"
    type: yesno
    sql: CASE
      WHEN try_to_number(replace("ee_company_directory_12_month.district",'-','')) is not null THEN true
      ELSE false END;;
  }

  dimension: division {
    type: string
    sql: CASE WHEN (${_es_update_timestamp_date} < TO_DATE('2023-01-01') AND startswith(${default_cost_centers_full_path},'R')) THEN 'Rental'
      ELSE SPLIT_PART(${default_cost_centers_full_path},'/','1') END;;
  }

##we need to rename this!
  dimension: division_2 {
    type: string
    sql: CASE
          WHEN CONTAINS(${employee_title}, 'Sales') THEN 'Sales'
          WHEN ${division}='Corp'  THEN 'Corporate'
          WHEN ${division}='Manufacturing'  THEN 'Ops'
          WHEN ${division}='Materials'  THEN 'Ops'
          WHEN ${division}='Rental'  THEN 'Ops'
          WHEN ${division}='T3'  THEN 'Corporate'
          ELSE ${division} END ;;
  }

  # dimension: doc_uname {
  #   type: string
  #   sql: ${TABLE}."DOC_UNAME" ;;
  # }

  dimension: ee_state {
    label: "State"
    map_layer_name: us_states
    sql: ${ee_state} ;;
  }

  dimension: employee_id {
    value_format_name: id
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

  dimension: exempt_status {
    type: string
    sql: CASE WHEN CONTAINS(${pay_calc}, 'Hourly') THEN 'Non-exempt'
          WHEN CONTAINS(${pay_calc}, ' Exempt') THEN 'Exempt'
          WHEN CONTAINS(${pay_calc}, 'Salary') THEN 'Exempt'
          ELSE 'Other' END ;;
  }

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

  # dimension: last_name {
  #   type: string
  #   sql: ${TABLE}."LAST_NAME" ;;
  # }

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

  dimension: region {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${default_cost_centers_full_path},'/','1')
      ELSE SPLIT_PART(${default_cost_centers_full_path},'/','2') END;;
  }

##we need to rename this!
  dimension: region2 {
    type: string
    sql: CASE WHEN startswith(${region}, 'R1') THEN '1'
            WHEN startswith(${region}, 'R2') THEN '2'
            WHEN startswith(${region}, 'R3') THEN '3'
            WHEN startswith(${region}, 'R4') THEN '4'
            WHEN startswith(${region}, 'R5') THEN '5'
            WHEN startswith(${region}, 'R6') THEN '6'
            WHEN startswith(${region}, 'R7') THEN '7'
            Else ${region} END;;
  }

  dimension: region_ind {
    description: "Indicator for primary Regions only to filter out other non-regional employees such as Corporate"
    type: yesno
    sql: CASE WHEN try_to_number(${region2}) is not null THEN true
      ELSE false END;;
  }

  dimension: remote {
    type: string
    sql: CASE WHEN CONTAINS(${tax_location}, 'Remote') THEN 'Remote'
      ELSE 'Not Remote' END;;
    hidden: yes
  }

##can we delete this???
  dimension: company_tenure {
    type: string
    sql: CASE WHEN ${date_terminated_date} is not null THEN DATEDIFF(month, ${most_recent_hire_date_date},${date_terminated_date})
      ELSE DATEDIFF(month, ${most_recent_hire_date_date},${_es_update_timestamp_date}) END;;
  }

  dimension: subdepartment {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${default_cost_centers_full_path},'/','4')
      ELSE SPLIT_PART(${default_cost_centers_full_path},'/','5') END;;
  }

  dimension: remote {
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Remote'
      ELSE 'Not Remote' END;;
  }

  # dimension: work_email {
  #   type: string
  #   sql: ${TABLE}."WORK_EMAIL" ;;
  # }

  # dimension: work_phone {
  #   type: string
  #   sql: ${TABLE}."WORK_PHONE" ;;
  # }

  dimension: full_name {
    type: string
    sql: concat(${first_name},' ',${last_name}) ;;
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

  dimension: unicorn_departments_jobs {
    type: string
    sql: CASE WHEN ${employee_title} ='General Manager'THEN 'General Managers'
          WHEN ${employee_title} = 'District Sales Manager' THEN 'District Sales Managers'
          WHEN CONTAINS(SPLIT_PART(${default_cost_centers_full_path},'/','4'),'Business Analytics') OR CONTAINS(SPLIT_PART(${default_cost_centers_full_path},'/','4'),'Data Org')  THEN 'Business Analytics'
          WHEN (CONTAINS(SPLIT_PART(${default_cost_centers_full_path},'/','4'),'Accounting') OR CONTAINS(SPLIT_PART(${default_cost_centers_full_path},'/','4'),'Finance & Treasury')) THEN 'Accounting/Finance'
          ELSE 'Other' END;;
  }

  dimension: job_type {
    type: string
    sql: CASE WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'Corp' THEN 'Corporate'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'Manufacturing' THEN 'Corporate'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'E-Commerce' THEN 'Corporate'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'T3' THEN 'Corporate'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'Materials' and CONTAINS(${pay_calc}, 'Hourly') THEN 'Non-Exempt'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'National' and CONTAINS(${pay_calc}, 'Hourly') THEN 'Non-Exempt'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'Rental' and CONTAINS(${pay_calc}, 'Hourly') THEN 'Non-Exempt'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'Materials' and CONTAINS(${pay_calc}, 'Salary') THEN 'Exempt'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'National' and CONTAINS(${pay_calc}, 'Salary') THEN 'Exempt'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'Rental' and CONTAINS(${pay_calc}, 'Salary') THEN 'Exempt'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'Materials' and CONTAINS(${pay_calc}, 'Exempt') THEN 'Exempt'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'National' and CONTAINS(${pay_calc}, 'Exempt') THEN 'Exempt'
            WHEN SPLIT_PART(${default_cost_centers_full_path},'/','1') = 'Rental' and CONTAINS(${pay_calc}, 'Exempt') THEN 'Exempt'
            ELSE 'Other' END;;
  }

  dimension: remote_edited {
    type: string
    sql: CASE WHEN CONTAINS(${employee_title}, 'General Manager') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Assistant General Manager')AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Driver') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Field Technician') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Shop Technician') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Yard Technician') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Rental Coordinator') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Service Manager') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Parts Assistant') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Parts Manager') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Dispatcher') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Regional Manager') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'District Manager') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Telematics Installer') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Territory Account Manager') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'CDL') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Construction') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Pilot') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Telematics Manager') AND CONTAINS(${tax_location}, 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${employee_title}, 'Remote') THEN 'Remote'
          ELSE 'Not Remote' END ;;
  }

  dimension: hire_type {
    description: "Indicator for identifing internal/external/rehires based on absence of rehired date and having previous job title(s)."
    type: string
    sql: case
       when ${date_rehired} is not null then 'Rehired'
       when ${job_changes.prior_title} is null then 'External Hire'
      else 'Internal Hire'
      end;;
  }

  dimension: headcount_raw {
    sql: ${headcount} ;;
  }

  measure: headcount {
    sql: ${headcount} ;;
    type:  sum
  }

  measure: hires {
    sql: ${hires};;
    type:  sum
  }

  measure: rehires {
    sql: ${rehires} ;;
    type: sum
  }

  measure: terminations {
    sql: ${terminations} ;;
    type:  sum
    filters: [term_ind: "1"]
    drill_fields: [headcount_details*,
      date_terminated
    ]
  }

  measure: terminations_with_rate {
    sql: ${terminations} ;;
    type:  sum
    filters: [term_ind: "1"]
    drill_fields: [headcount_details*,
      date_terminated
    ]
    html: Total Terminations - {{rendered_value}} || Termination Rate - {{termination_rate._rendered_value }} ;;
  }

  dimension: term_ind {
    sql: ${terminations} ;;
    type: number
    hidden: yes
  }

  measure: count_of_external_hires{
    type: count
    # sql: ${primary_key} ;;
    filters: [hire_type: "External Hire"]
    drill_fields: [job_changes.effective_date_date, full_name, hire_type,location,job_changes.current_title, key_ops_jobs, disc_link, remote_edited ]
  }

  measure: count_of_internal_hires{
    type: count
    # sql: ${primary_key} ;;
    filters: [hire_type: "Internal Hire"]
    drill_fields:[job_changes.effective_date_date, full_name, hire_type,location,job_changes.current_title, job_changes.prior_title, key_ops_jobs, disc_link, greenhouse_application_id, remote_edited ]
  }

  measure: count_of_rehires{
    type: count
    # sql: ${rehires} ;;
    filters: [hire_type: "Rehired"]
    drill_fields: [job_changes.effective_date_date, full_name, hire_type,location,job_changes.current_title, job_changes.prior_title, key_ops_jobs, disc_link, remote_edited ]
  }

  measure: count {
    type: count
    drill_fields: [division, region2, district, department, exempt_status, remote, last_name, first_name, employee_title, direct_manager_name, date_hired, date_rehired, disc_link]
  }

  measure: count_no_drill {
    type: count
  }

  measure: count_unique_eeid {
    type: count_distinct
    sql:  ${employee_id} ;;
    drill_fields: [last_name, first_name, full_name, employee_title, direct_manager_name, date_hired, date_rehired, disc_link]
  }

  # measure: company_tenure_average {
  #   type: average
  #   sql:  ${company_tenure};;
  # }

  # measure: company_tenure_average_2 {
  #   type: average
  #   sql:  ${company_tenure};;
  # }

  dimension: tenure_months {
    type: number
    sql: datediff(months,${most_recent_hire_date_raw},coalesce(${date_terminated2_raw},current_date)) ;;
    description: "Number of months from most recent hire date until current date."
  }

  dimension: tenure_days {
    type: number
    sql: datediff(days,${most_recent_hire_date_raw},coalesce(${date_terminated2_raw},current_date)) ;;
    description: "Number of days from most recent hire date until current date."
  }

## We should move these to the proper dashboard explore when time allows.
    measure: headcount_with_drill {
      type: count
      # filters: [region_ind: "yes"]
      drill_fields: [regional_totals*]
      link: {
        label: "View Headcount by Region"
        url: "
        {% assign vis_config = '{
        \"x_axis_gridlines\":false,
        \"y_axis_gridlines\":true,
        \"show_view_names\":false,
        \"show_y_axis_labels\":true,
        \"show_y_axis_ticks\":true,
        \"y_axis_tick_density\":\"default\",
        \"y_axis_tick_density_custom\":5,
        \"show_x_axis_label\":true,
        \"show_x_axis_ticks\":true,
        \"y_axis_scale_mode\":\"linear\",
        \"x_axis_reversed\":false,
        \"y_axis_reversed\":false,
        \"plot_size_by_field\":false,
        \"trellis\":\"\",
        \"stacking\":\"\",
        \"limit_displayed_rows\":false,
        \"legend_position\":\"center\",
        \"point_style\":\"none\",
        \"show_value_labels\":true,
        \"label_density\":25,
        \"x_axis_scale\":\"auto\",
        \"y_axis_combined\":true,
        \"ordering\":\"none\",
        \"show_null_labels\":false,
        \"show_totals_labels\":false,
        \"show_silhouette\":false,
        \"totals_color\":\"#808080\",
        \"x_axis_label\":\"Region\",
        \"x_axis_zoom\":true,
        \"y_axis_zoom\":true,
        \"series_colors\":{\"ee_company_directory_12_month.region_headcount\":\"#004d99\"},
        \"series_labels\":{\"ee_company_directory_12_month.region_headcount\":\"Headcount\"},
        \"type\":\"looker_column\",
        \"defaults_version\":1
        }' %}
        {{ link }}&vis_config={{ vis_config | encode_uri }}&sort=ee_company_directory_12_month.region2&toggle=dat,pik,vis&limit=5000"
      }
    }

    measure: region_headcount {
      type: count
      drill_fields: [district_totals*]
      link: {
        label: "View Headcount by District"
        url: "
        {% assign vis_config = '{
        \"x_axis_gridlines\":false,
        \"y_axis_gridlines\":true,
        \"show_view_names\":false,
        \"show_y_axis_labels\":true,
        \"show_y_axis_ticks\":true,
        \"y_axis_tick_density\":\"default\",
        \"y_axis_tick_density_custom\":5,
        \"show_x_axis_label\":true,
        \"show_x_axis_ticks\":true,
        \"y_axis_scale_mode\":\"linear\",
        \"x_axis_reversed\":false,
        \"y_axis_reversed\":false,
        \"plot_size_by_field\":false,
        \"trellis\":\"\",
        \"stacking\":\"\",
        \"limit_displayed_rows\":false,
        \"legend_position\":\"center\",
        \"point_style\":\"none\",
        \"show_value_labels\":true,
        \"label_density\":25,
        \"x_axis_scale\":\"auto\",
        \"y_axis_combined\":true,
        \"ordering\":\"none\",
        \"show_null_labels\":false,
        \"show_totals_labels\":false,
        \"show_silhouette\":false,
        \"totals_color\":\"#808080\",
        \"x_axis_zoom\":true,
        \"y_axis_zoom\":true,
        \"series_colors\":{\"ee_company_directory_12_month.count\":\"#004d99\"},
        \"series_labels\":{\"ee_company_directory_12_month.count\":\"Headcount\"},
        \"type\":\"looker_column\",
        \"defaults_version\":1
        }' %}
        {{ link }}&vis_config={{ vis_config | encode_uri }}&sorts=ee_company_directory_12_month.district&toggle=dat,pik,vis&limit=5000"

      }
    }

    dimension: curr_headcount_ind {
      type: yesno
      sql: ${most_recent_hire_date_date}<=${_es_update_timestamp_date} ;;
    }

    measure: termination_rate {
      type: number
      sql: nullifzero(${terminations})/${headcount} ;;
      value_format_name: percent_1
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
        date_hired,
        date_rehired,
        disc_link]
    }

}
