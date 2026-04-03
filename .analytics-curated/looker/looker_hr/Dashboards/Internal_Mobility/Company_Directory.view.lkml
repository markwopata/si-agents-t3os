view: company_directory {
  sql_table_name: "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY"
    ;;

  dimension_group: date_hired {
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

  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: division {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/',1) ;;
  }

  dimension: district {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH", '/', 3) ;;
  }

  dimension: cost_center_location {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH", '/', 4) ;;
  }

  dimension: department {
    type: string
    sql: split_part(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/',4) ;;
  }

  dimension: direct_manager_employee_id {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: employee_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
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

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: employee_name {
    type: string
    sql: coalesce(${nickname} , ${first_name})||' '||${last_name} ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: work_phone {
    type: string
    sql: ${TABLE}."WORK_PHONE" ;;
  }

  dimension: greenhouse_application_id {
    type: string
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: personal_email {
    type: string
    sql: ${TABLE}."PERSONAL_EMAIL" ;;
  }

  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
  }

  dimension: tax_location {
    type: string
    sql: ${TABLE}."TAX_LOCATION" ;;
  }

  measure: count {
    type: count
    drill_fields: [last_name, direct_manager_name, first_name]
  }

  dimension: is_market_management {
    type: yesno
    sql:${TABLE}."EMPLOYEE_TITLE" in ('Area General Manager', 'Area Sales Developer', 'Business Development Manager',
               'District Operations Manager', 'Facility Administrator', 'General Manager - Industrial Tooling',
               'Market Consultant Manager', 'Operations Manager', 'Parts & Service Administrator',
               'Regional Manager - Industrial Services', 'Rental Coordinator - Industrial Tooling', 'Retail Parts Manager',
               'Tool Trailer Manager','Assistant General Manager','Service Manager','General Manager',
               'Parts Manager') ;;
  }

}
