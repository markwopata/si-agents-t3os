view: organizational_health_ee_company_directory_12_month {
  derived_table: {
    sql:SELECT * from analytics.payroll.EE_COMPANY_DIRECTORY_12_MONTH cd left join
    (SELECT * from analytics.greenhouse.job_profiles) jp on
   cd.EMPLOYEE_TITLE=jp.JOB_TITLE
    ;;
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

  dimension: account_id {
    type: number
    sql: ${TABLE}."ACCOUNT_ID" ;;
  }

  dimension: compound_primary_key{
    primary_key: yes
    sql: CONCAT(${TABLE}."_ES_UPDATE_TIMESTAMP", ${TABLE}."EMPLOYEE_ID") ;;
  }


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
    sql: (CASE
          WHEN ${TABLE}."DATE_REHIRED" IS NOT NULL THEN ${TABLE}."DATE_REHIRED"
          ELSE ${TABLE}."DATE_HIRED" END );;
  }

  dimension_group: date_terminated {
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
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: district {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','2')
      ELSE SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','3') END;;
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
          WHEN ${TABLE}."DIVISION"='Corp'  THEN 'Corporate'
          WHEN ${TABLE}."DIVISION"='Manufacturing'  THEN 'Ops'
          WHEN ${TABLE}."DIVISION"='Materials'  THEN 'Ops'
          WHEN ${TABLE}."DIVISION"='Rental'  THEN 'Ops'
          WHEN ${TABLE}."DIVISION"='T3'  THEN 'Corporate'
          ELSE ${TABLE}."DIVISION" END ;;
  }

  dimension: doc_uname {
    type: string
    sql: ${TABLE}."DOC_UNAME" ;;
  }

  dimension: ee_state {
    type: string
    sql: ${TABLE}."EE_STATE" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }

    dimension: full_name {
      type: string
      sql: concat(${first_name}," ",${last_name}) ;;
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

  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }

  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
  }

  dimension: job_family {
    type: string
    sql: ${TABLE}."JOB_FAMILY" ;;
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

  dimension: subdepartment {
    type: string
    sql: CASE WHEN ${_es_update_timestamp_date} < TO_DATE('2023-01-01') THEN SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','4')
      ELSE SPLIT_PART(${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH",'/','5') END;;
  }


  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: work_phone {
    type: string
    sql: ${TABLE}."WORK_PHONE" ;;
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
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Territory Account Manager') THEN 'Territory Account Managers'
          WHEN CONTAINS(${TABLE}."EMPLOYEE_TITLE", 'Telematics Installer') THEN 'Telematics Installers'
          ELSE 'Other' END ;;
  }


  measure: hires {
    sql: ${TABLE}."HIRES" ;;
    type:  sum
  }

  measure: rehires {
    sql: ${TABLE}."REHIRES" ;;
    type: sum
  }

  measure: terminations {
    sql: ${TABLE}."TERMINATIONS" ;;
    type:  sum
  }

  measure: headcount {
    sql: ${TABLE}."HEADCOUNT" ;;
    type:  sum
  }

  measure: count {
    type: count
    drill_fields: [last_name, first_name,full_name, employee_title, direct_manager_name, date_hired_date, date_rehired_date, date_terminated2_month]
  }


  measure: count_no_drill {
    type: count
  }
}
