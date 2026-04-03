view: ee_company_directory_12_month {
  sql_table_name: "ANALYTICS"."PAYROLL"."EE_COMPANY_DIRECTORY_12_MONTH"
    ;;

  dimension: primary_key {
    primary_key: yes
    type: string
    sql:  concat(${employee_id},${_es_update_timestamp_date}) ;;
  }

  dimension: _es_update_timestamp_raw_ {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  parameter: select_timeframe {
    type: unquoted
    default_value: "365"
    allowed_value: {
      value: "365"
      label: "Last 365 Days"
    }
    allowed_value: {
      value: "180"
      label: "Last 180 Days"
    }
    allowed_value: {
      value: "90"
      label: "Last 90 Days"
    }
    allowed_value: {
      value: "30"
      label: "Last 30 Days"
    }
  }

  dimension: select_timeframe_flag_date_terminated {
    type: yesno
    sql:
    case
    when {{ select_timeframe._parameter_value }} = 30 then ${last_30_days_date_terminated} = true
    when {{ select_timeframe._parameter_value }} = 90 then ${last_90_days_date_terminated} = true
    when {{ select_timeframe._parameter_value }} = 180 then ${last_180_days_date_terminated} =true
    when {{ select_timeframe._parameter_value }} = 365 then ${last_365_days_date_terminated} = true
    else ${last_365_days_date_terminated} = true
    end;;
  }

  dimension: select_timeframe_flag_es_update_timestamp {
    type: yesno
    sql:
    case
    when {{ select_timeframe._parameter_value }} = 30 then ${last_30_days_es_update_timestamp} = true
    when {{ select_timeframe._parameter_value }} = 90 then ${last_90_days_es_update_timestamp} = true
    when {{ select_timeframe._parameter_value }} = 180 then ${last_180_days_es_update_timestamp} = true
    when {{ select_timeframe._parameter_value }} = 365 then ${last_365_days_es_update_timestamp} = true
    else ${last_365_days_es_update_timestamp} = true
    end;;
  }


  dimension: last_30_days_es_update_timestamp {
    description: "Indicator to filter records that fall within the last 30 days for the es_update_timestamp date field. Using this would exclude current month data."
    hidden: yes
    type: yesno
    sql: ${_es_update_timestamp_raw} >= dateadd('second',1,(dateadd('days',-30,(dateadd('second',-1,date_trunc('days',current_date))))))
      and ${_es_update_timestamp_raw} <= dateadd('second',-1,date_trunc('days',current_date));;
  }

  dimension: last_90_days_es_update_timestamp {
    description: "Indicator to filter records that fall within the last 90 days for the es_update_timestamp date field. Using this would exclude current month data."
    hidden: yes
    type: yesno
    sql: ${_es_update_timestamp_raw} >= dateadd('second',1,(dateadd('days',-90,(dateadd('second',-1,date_trunc('days',current_date))))))
      and ${_es_update_timestamp_raw} <= dateadd('second',-1,date_trunc('days',current_date));;
  }

  dimension: last_180_days_es_update_timestamp {
    description: "Indicator to filter records that fall within the last 180 days for the es_update_timestamp date field. Using this would exclude current month data."
    hidden: yes
    type: yesno
    sql: ${_es_update_timestamp_raw} >= dateadd('second',1,(dateadd('days',-180,(dateadd('second',-1,date_trunc('days',current_date))))))
      and ${_es_update_timestamp_raw} <= dateadd('second',-1,date_trunc('days',current_date));;
  }

  dimension: last_365_days_es_update_timestamp {
    description: "Indicator to filter records that fall within the last 365 days for the es_update_timestamp date field. Using this would exclude current month data."
    hidden: yes
    type: yesno
    sql: ${_es_update_timestamp_raw} >= dateadd('second',1,(dateadd('days',-365,(dateadd('second',-1,date_trunc('days',current_date))))))
      and ${_es_update_timestamp_raw} <= dateadd('second',-1,date_trunc('days',current_date));;
  }

  dimension: last_30_days_date_terminated {
    description: "Indicator to filter records that fall within the last 30 days for the date_terminated date field. Using this would exclude current month data."
    hidden: yes
    type: yesno
    sql: ${date_terminated2_raw} >= dateadd('second',1,(dateadd('days',-30,(dateadd('second',-1,date_trunc('days',current_date))))))
      and ${date_terminated2_raw} <= dateadd('second',-1,date_trunc('days',current_date));;
  }

  dimension: last_90_days_date_terminated {
    description: "Indicator to filter records that fall within the last 90 days for the date_terminated date field. Using this would exclude current month data."
    hidden: yes
    type: yesno
    sql: ${date_terminated2_raw} >= dateadd('second',1,(dateadd('days',-90,(dateadd('second',-1,date_trunc('days',current_date))))))
      and ${date_terminated2_raw} <= dateadd('second',-1,date_trunc('days',current_date));;
  }

  dimension: last_180_days_date_terminated {
    description: "Indicator to filter records that fall within the last 180 days for the date_terminated date field. Using this would exclude current month data."
    hidden: yes
    type: yesno
    sql: ${date_terminated2_raw} >= dateadd('second',1,(dateadd('days',-180,(dateadd('second',-1,date_trunc('days',current_date))))))
      and ${date_terminated2_raw} <= dateadd('second',-1,date_trunc('days',current_date));;
  }

  dimension: last_365_days_date_terminated {
    description: "Indicator to filter records that fall within the last 365 days for the date_terminated date field. Using this would exclude current month data."
    hidden: yes
    type: yesno
    sql: ${date_terminated2_raw} >= dateadd('second',1,(dateadd('days',-365,(dateadd('second',-1,date_trunc('days',current_date))))))
      and ${date_terminated2_raw} <= dateadd('second',-1,date_trunc('days',current_date));;
  }

  dimension: last_12_month {
    description: "Indicator to filter records that fall within the last full 12 months. Using this would exclude current month data."
    type: yesno
    sql: ${_es_update_timestamp_raw} >= dateadd('second',1,(dateadd('month',-12,(dateadd('second',-1,date_trunc('month',current_date))))))
      and ${_es_update_timestamp_raw} <= dateadd('second',-1,date_trunc('month',current_date));;
  }

  dimension: account_id {
    type: number
    sql: ${TABLE}."ACCOUNT_ID" ;;
    value_format_name: id
  }

  dimension_group: date_hired {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_HIRED" ;;
  }

  dimension_group: date_hired2 {
    label: "Date Hired"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_HIRED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: date_rehired {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_REHIRED" ;;
  }

  dimension_group: date_rehired2 {
    label: "Date Rehired"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_REHIRED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: most_recent_hire_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CASE
          WHEN ${TABLE}."DATE_REHIRED" IS NOT NULL THEN ${TABLE}."DATE_REHIRED"
          ELSE ${TABLE}."DATE_HIRED"END ;;
  }

  dimension_group: date_terminated {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }

  dimension_group: date_terminated2 {
    label: "Date Terminated"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."DATE_TERMINATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: department {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','3')
      ELSE SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','4') END;;
  }

  dimension: direct_manager_employee_id {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: disc_code{
    type: string
    sql: ${TABLE}."DISC_CODE" ;;
  }

  dimension: disc_link {
    type: string
    sql: CASE WHEN ${disc_code} IS NOT NULL THEN CONCAT('https://www.discoveryreport.com/v/', ${disc_code})
      ELSE 'No DISC' END;;
    html: <font color="blue "><u><a href ="https://www.discoveryreport.com/v/{{disc_code._value}}"target="_blank">Link to Disc</a></font></u> ;;

  }

  dimension: district {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','2')
      ELSE SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','3') END;;
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
      ELSE SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') END;;
  }

  dimension: division_2 {
    type: string
    sql: CASE
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Sales') THEN 'Sales'
          WHEN ${division}='Corp'  THEN 'Corporate'
          WHEN ${division}='Manufacturing'  THEN 'Ops'
          WHEN ${division}='Materials'  THEN 'Ops'
          WHEN ${division}='Rental'  THEN 'Ops'
          WHEN ${division}='T3'  THEN 'Corporate'
          ELSE ${division} END ;;
  }

  dimension: doc_uname {
    type: string
    sql: ${TABLE}."DOC_UNAME" ;;
  }

  dimension: ee_state {
    label: "State"
    type: string
    map_layer_name: us_states
    sql: ${TABLE}."EE_STATE" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
    value_format_name: id
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension: employee_type {
    type: string
    sql: ${TABLE}."EMPLOYEE_TYPE" ;;
  }

  dimension: exempt_status {
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."PAY_CALC", 'Hourly') THEN 'Non-exempt'
          WHEN CONTAINS(${TABLE}."PAY_CALC", ' Exempt') THEN 'Exempt'
          WHEN CONTAINS(${TABLE}."PAY_CALC", 'Salary') THEN 'Exempt'
          ELSE 'Other' END ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID";;
    value_format_name: id
  }

  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format_name: id
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: pay_calc {
    type: string
    sql: ${TABLE}."PAY_CALC" ;;
  }

  dimension: personal_email {
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }

  dimension_group: date_position_effective {
    hidden: yes
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."POSITION_EFFECTIVE_DATE" ;;
  }

  dimension_group: date_position_effective2 {
    label: "Date Position Effective"
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."POSITION_EFFECTIVE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: region {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1')
      ELSE SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','2') END;;
  }

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

  dimension: subdepartment {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','4')
      ELSE SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','5') END;;
  }

  dimension: remote {
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Remote'
      ELSE 'Not Remote' END;;
    hidden: yes
  }

  dimension: company_tenure {
    type: string
    sql: CASE WHEN ${date_terminated_date} is not null THEN DATEDIFF(month, ${most_recent_hire_date_date},${date_terminated_date})
      ELSE DATEDIFF(month, ${most_recent_hire_date_date},${_es_update_timestamp_date}) END;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: work_phone {
    type: string
    sql: ${TABLE}."WORK_PHONE" ;;
  }

  dimension: full_name {
    type: string
    sql: concat(${TABLE}."FIRST_NAME",' ',${TABLE}."LAST_NAME") ;;
  }

  dimension: key_ops_jobs {
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'General Manager') AND NOT CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Assistant General Manager') THEN 'General Managers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Assistant General Manager') THEN 'Assistant General Managers'
          WHEN (CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'CDL') AND CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Driver') AND NOT CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'non-CDL') AND NOT CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Non-CDL')) THEN 'Drivers (CDL)'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Driver') THEN 'Drivers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Field Technician') THEN 'Field Technicians'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Shop Technician') THEN 'Shop Technicians'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Yard Technician') THEN 'Yard Technician'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Rental Coordinator') THEN 'Rental Coordinators'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Service Manager') THEN 'Service Managers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Parts Assistant') THEN 'Parts Assistants'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Parts Manager') THEN 'Parts Managers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Dispatcher') THEN 'Dispatchers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Regional Manager') THEN 'Regional Managers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'District Manager') THEN 'District Managers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Telematics Installer') THEN 'Telematics Installers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Territory Account Manager') THEN 'Territory Account Managers'
          ELSE 'Other' END ;;
  }

  dimension: unicorn_departments_jobs {
    type: string
    sql: CASE WHEN ${TABLE}."EMPLOYEE_TITLE"='General Manager' OR ${TABLE}."EMPLOYEE_TITLE"='General Manager - Advanced Solutions' THEN 'General Managers'
          WHEN ${TABLE}."EMPLOYEE_TITLE" = 'District Sales Manager' THEN 'District Sales Managers'
          WHEN ${TABLE}."EMPLOYEE_TITLE" = 'Construction Project Manager' THEN 'Construction Project Managers'
          WHEN ${TABLE}."EMPLOYEE_TITLE" = 'Territory Account Manager' THEN 'Territory Account Managers'
          WHEN ${TABLE}."EMPLOYEE_TITLE" = 'Service Manager' THEN 'Service Managers'
          WHEN (CONTAINS(${TABLE}."EMPLOYEE_TITLE",'CDL')) THEN 'CDL Delivery Driver'
          WHEN (CONTAINS(${TABLE}."EMPLOYEE_TITLE",'Field Technician') OR CONTAINS(${TABLE}."EMPLOYEE_TITLE",'Shop Technician') OR CONTAINS(${TABLE}."EMPLOYEE_TITLE",'Service Technician') OR CONTAINS(${TABLE}."EMPLOYEE_TITLE",'Diesel Technician')) THEN 'Techs'
          WHEN CONTAINS(SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','4'),'Business Analytics') OR CONTAINS(SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','4'),'Data Org')  THEN 'Business Analytics'
          WHEN (CONTAINS(SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','4'),'Accounting') OR CONTAINS(SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','4'),'Finance & Treasury')) THEN 'Accounting/Finance'
          ELSE 'Other' END;;
  }

  dimension: job_type {
    type: string
    sql: CASE WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'Corp' THEN 'Corporate'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'Manufacturing' THEN 'Corporate'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'E-Commerce' THEN 'Corporate'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'T3' THEN 'Corporate'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'Materials' and CONTAINS(${TABLE}."PAY_CALC", 'Hourly') THEN 'Non-Exempt'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'National' and CONTAINS(${TABLE}."PAY_CALC", 'Hourly') THEN 'Non-Exempt'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'Rental' and CONTAINS(${TABLE}."PAY_CALC", 'Hourly') THEN 'Non-Exempt'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'Materials' and CONTAINS(${TABLE}."PAY_CALC", 'Salary') THEN 'Exempt'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'National' and CONTAINS(${TABLE}."PAY_CALC", 'Salary') THEN 'Exempt'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'Rental' and CONTAINS(${TABLE}."PAY_CALC", 'Salary') THEN 'Exempt'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'Materials' and CONTAINS(${TABLE}."PAY_CALC", 'Exempt') THEN 'Exempt'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'National' and CONTAINS(${TABLE}."PAY_CALC", 'Exempt') THEN 'Exempt'
          WHEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','1') = 'Rental' and CONTAINS(${TABLE}."PAY_CALC", 'Exempt') THEN 'Exempt'
          ELSE 'Other' END;;
  }

  dimension: remote_edited {
    label: "Remote Indicator"
    type: string
    sql: CASE WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'General Manager') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Assistant General Manager')AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Driver') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Field Technician') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Shop Technician') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Yard Technician') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Rental Coordinator') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Service Manager') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Parts Assistant') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Parts Manager') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Dispatcher') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Regional Manager') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'District Manager') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Telematics Installer') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Territory Account Manager') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'CDL') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Construction') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Pilot') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Telematics Manager') AND CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Not Remote'
          WHEN CONTAINS(${TABLE}."TAX_LOCATION", 'Remote') THEN 'Remote'
          ELSE 'Not Remote' END ;;
  }

  dimension: hire_type {
    description: "Indicator for identifing internal/external/rehires based on absence of rehired date and having previous job title(s)."
    type: string
    sql: case
         when ${date_rehired_date} is not null then 'Rehired'
         when ${job_changes.prior_title} is null then 'External Hire'
        else 'Internal Hire'
        end;;
  }

  measure: count_of_external_hires{
    type: count
    # sql: ${primary_key} ;;
    filters: [hire_type: "External Hire"]
    drill_fields: [employee_id,job_changes.effective_date_date, full_name, hire_type,location,job_changes.current_title, key_ops_jobs, disc_link, remote_edited ]
  }

  measure: count_of_internal_hires{
    type: count
    # sql: ${primary_key} ;;
    filters: [hire_type: "Internal Hire"]
    drill_fields:[employee_id,job_changes.effective_date_date, full_name, hire_type,location,job_changes.current_title, job_changes.prior_title, key_ops_jobs, disc_link, greenhouse_application_id, remote_edited ]
  }

  measure: count_of_rehires{
    type: count
    # sql: ${rehires} ;;
    filters: [hire_type: "Rehired"]
    drill_fields: [employee_id,job_changes.effective_date_date, full_name, hire_type,location,job_changes.current_title, job_changes.prior_title, key_ops_jobs, disc_link, remote_edited ]
  }

  measure: total_hires {
    type: count
    # sql: ${primary_key} ;;
    filters: [hire_type: "External Hire, Internal Hire, Rehired"]
    drill_fields: [count_of_external_hires, count_of_internal_hires, count_of_rehires]
    link: {
      label: "View Totals by Hire Type"
      url: "
      {% assign vis_config = '{
      \"show_view_names\":false,
      \"show_row_numbers\":false,
      \"transpose\":false,\"truncate_text\":true,
      \"hide_totals\":false,
      \"hide_row_totals\":false,
      \"size_to_fit\":true,
      \"table_theme\":\"white\",
      \"limit_displayed_rows\":false,
      \"enable_conditional_formatting\":false,
      \"header_text_alignment\":\"center\",
      \"header_font_size\":\"12\",
      \"rows_font_size\":\"12\",
      \"conditional_formatting_include_totals\":false,
      \"conditional_formatting_include_nulls\":false,
      \"show_sql_query_menu_options\":false,\"show_totals\":true,
      \"show_row_totals\":true,
      \"truncate_header\":false,
      \"minimum_column_width\":75,
      \"series_labels\":{\"ee_company_directory_12_month.count_of_external_hires\":\"External Hires\",
      \"ee_company_directory_12_month.count_of_internal_hires\":\"Internal Hires\",
      \"ee_company_directory_12_month.count_of_rehires\":\"Rehires\"},
      \"series_cell_visualizations\":{\"ee_company_directory_12_month.count_of_external_hires\":{\"is_active\":false}},
      \"series_text_format\":{\"ee_company_directory_12_month.count_of_external_hires\":{\"align\":\"center\"},
      \"ee_company_directory_12_month.count_of_internal_hires\":{\"align\":\"center\"},
      \"ee_company_directory_12_month.count_of_rehires\":{\"align\":\"center\"}},
      \"hidden_fields\":[],
      \"hidden_points_if_no\":[],
      \"title_override_ee_company_directory_12_month.count_of_external_hires\":\"External Hires\",
      \"title_placement_ee_company_directory_12_month.count_of_external_hires\":\"below\",
      \"title_override_ee_company_directory_12_month.count_of_internal_hires\":\"Internal Hires\",
      \"title_placement_ee_company_directory_12_month.count_of_internal_hires\":\"below\",
      \"title_override_ee_company_directory_12_month.count_of_rehires\":\"Rehires\",
      \"title_placement_ee_company_directory_12_month.count_of_rehires\":\"below\",
      \"type\":\"looker_grid\",
      \"x_axis_gridlines\":false,
      \"y_axis_gridlines\":true,
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
      \"trellis\":\"\",\"stacking\":\"\",
      \"legend_position\":\"center\",
      \"point_style\":\"none\",
      \"show_value_labels\":false,
      \"label_density\":25,
      \"x_axis_scale\":\"auto\",
      \"y_axis_combined\":true,
      \"ordering\":\"none\",
      \"show_null_labels\":false,
      \"show_totals_labels\":false,
      \"show_silhouette\":false,
      \"totals_color\":\"#808080\",
      \"defaults_version\":1,
      \"series_types\":{}
      }' %}
      {{ link }}&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis&limit=5000"
    }
  }


  ##we need to research these measures to see if they match Mitch's recoding above and if not, why? Need to see Nicole's table code for this snowflake table.
  measure: hires {
    sql: ${TABLE}."HIRES" ;;
    type:  sum
  }

  measure: rehires {
    sql: ${TABLE}."REHIRES" ;;
    type: sum
  }

  dimension: term_ind {
    sql: ${TABLE}."TERMINATIONS";;
    type: number
    hidden: yes
  }

  measure: terminations {
    sql: ${TABLE}."TERMINATIONS";;
    type:  sum
    filters: [term_ind: "1"]
    drill_fields: [headcount_details*,
      date_terminated_date,tenure_buckets
    ]
  }

  measure: terminations_with_rate{
    sql: ${TABLE}."TERMINATIONS" ;;
    type:  sum
    filters: [term_ind: "1"]
    drill_fields: [headcount_details*,
      date_terminated_date, tenure_buckets
    ]
    html: Total Terminations - {{rendered_value}} || Termination Rate - {{termination_rate._rendered_value }} ;;
  }

  dimension: regrettable_term {
    type: number
    sql: case
      when termination_details.regrettable = 'Yes' then 1 else 0 end;;
  }

  dimension: non_regrettable_term {
    type: number
    sql: case
      when termination_details.regrettable = 'Yes' then 0 else 1 end;;
  }

  measure: regrettable_count {
    type: sum
    sql: ${regrettable_term} ;;
    filters: [regrettable_term: "1",
      term_ind: "1"]
    drill_fields: [headcount_details*,date_terminated2_date]
  }

  measure: non_regrettable_count {
    type: sum
    sql: ${non_regrettable_term} ;;
    filters: [non_regrettable_term: "1",
      term_ind: "1"]
    drill_fields: [headcount_details*,date_terminated2_date]
  }

  measure: headcount {
    sql: ${TABLE}."HEADCOUNT" ;;
    type:  sum
  }

  measure: count {
    type: count
    drill_fields: [division, region2, district, department, exempt_status, remote, last_name, first_name, employee_title, direct_manager_name, date_hired_date, date_rehired_date, disc_link]
  }

  measure: count_no_drill {
    type: count
  }

  measure: count_unique_eeid {
    type: count_distinct
    sql:  ${TABLE}."EMPLOYEE_ID";;
    drill_fields: [last_name, first_name, full_name, employee_title, direct_manager_name, date_hired_date, date_rehired_date, disc_link]
  }

  measure: company_tenure_average {
    type: average
    sql:  ${company_tenure};;
  }

  measure: company_tenure_average_2 {
    type: average
    sql:  ${company_tenure};;
  }




############################## Jolene's testing ###############

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
    sql: nullifzero(${terminations})/nullifzero(${headcount}) ;;
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
      employee_id,
      employee_title,
      direct_manager_name,
      date_hired_date,
      date_rehired_date,
      disc_link,
      termination_details.reason]
  }

  dimension: tenure_months {
    type: number
    sql: datediff(months,${most_recent_hire_date_raw},coalesce(${date_terminated2_raw},${_es_update_timestamp_raw})) ;;
    description: "Number of months from most recent hire date until current date."
  }

  dimension: tenure_days {
    type: number
    sql: datediff(days,${most_recent_hire_date_raw},coalesce(${date_terminated2_raw},${_es_update_timestamp_raw})) ;;
    description: "Number of days from most recent hire date until current date."
  }

  dimension: tenure_buckets {
    type: string
    sql: case
          when${tenure_days}>=0  and ${tenure_days}<=90 then '0-90 days'
          when ${tenure_months}>=3 and ${tenure_months}<=6 then '3-6 months'
          when ${tenure_months}>6 and ${tenure_months}<=12 then '7-12 months '
          when ${tenure_months}>12 and ${tenure_months}<=24 then '1-2 years'
          else 'Over 2 years' END;;
  }

  # dimension: tenure_sort {
  #   type: number
  #   sql: case
  #   when ${tenure_buckets} = '0-30 Days' then 1
  #   when ${tenure_buckets} ='31-60 Days' then 2
  #   when ${tenure_buckets} = '61-90 Days' then 3
  #   when ${tenure_buckets} = '6 months or less' then 4
  #   when ${tenure_buckets} = '12 months or less' then 5
  #   when ${tenure_buckets} =  '24 months or less' then 6
  #   else 7 END;;
  # }
}
