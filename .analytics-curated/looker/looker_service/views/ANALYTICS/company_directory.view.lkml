view: company_directory {
  sql_table_name: "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY"
    ;;

  dimension: account_id {
    type: number
    sql: ${TABLE}."ACCOUNT_ID" ;;
  }

  dimension: date_hired {
    type: string
    sql: ${TABLE}."DATE_HIRED" ;;
  }

  dimension: date_rehired {
    type: string
    sql: ${TABLE}."DATE_REHIRED" ;;
  }

  dimension: date_terminated {
    type: string
    sql: ${TABLE}."DATE_TERMINATED" ;;
  }

  dimension: default_cost_centers_full_path {
    type: string
    sql: ${TABLE}."DEFAULT_COST_CENTERS_FULL_PATH" ;;
  }

  dimension: direct_manager_employee_id {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID" ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME" ;;
  }

  dimension: doc_uname {
    type: string
    sql: ${TABLE}."DOC_UNAME" ;;
  }

  dimension: ee_state {
    type: string
    sql: ${TABLE}."EE_STATE" ;;
  }

  dimension: employee_name {
    type: string
    sql: concat(${first_name},' ',${last_name}) ;;
  }

  dimension: employee_id {
    primary_key: yes
    type: string
    sql: to_char(${TABLE}."EMPLOYEE_ID") ;;
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

  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }

  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
  }

  dimension: is_tech {
    type: yesno
    sql: case
        when employee_title ilike '%Field technician%' then true
        when employee_title ilike '%Yard technician%' then true
        when employee_title ilike '%Service technician%' then true
        when employee_title ilike '%Shop technician%' then true
        when employee_title ilike '%Fleet technician%' then true
        else false
        end;;
  }

  dimension: is_tech_or_mechanic {
    type: yesno
    sql: ${employee_title} ilike any ('%technician%', '%mechanic%') and ${employee_title} not ilike '%yard technician%' ;;
  }

  dimension: labor_distribution_profile {
    type: string
    sql: ${TABLE}."LABOR_DISTRIBUTION_PROFILE" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: last_updated_date {
    type: string
    sql: ${TABLE}."LAST_UPDATED_DATE" ;;
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

  dimension: tax_location {
    type: string
    sql: ${TABLE}."TAX_LOCATION" ;;
  }

  dimension: work_email {
    type: string
    sql: ${TABLE}."WORK_EMAIL" ;;
  }

  dimension: work_phone {
    type: string
    sql: ${TABLE}."WORK_PHONE" ;;
  }

  measure: count {
    type: count
    drill_fields: [doc_uname, last_name, nickname, first_name, direct_manager_name]
  }

  measure: count_active {
    type: count_distinct
    filters: [employee_status: "Active"]
    sql: ${employee_id};;
    drill_fields: [employee_name,employee_title,market_region_xwalk.market_name]
  }

  measure: count_tech {
    type: count_distinct
    filters: [is_tech: "TRUE", employee_status: "Active"]
    sql: ${employee_id} ;;
    drill_fields: [employee_name,employee_title,market_region_xwalk.market_name]
  }

  measure: count_tech_or_mech {
    type: count_distinct
    filters: [employee_status: "Active", is_tech_or_mechanic: "TRUE"]
    sql: ${employee_id} ;;
  }
}
