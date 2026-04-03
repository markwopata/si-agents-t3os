view: company_directory_tam_performance {

  derived_table: {
    sql:SELECT cd.*, xw.market_name, xw.district, xw.region_name, xw.market_type FROM "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" cd left join analytics.public.market_region_xwalk xw ON xw.market_id = cd.market_id;;
}
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
  dimension: months_since_hired{
    type: number
    sql: (current_timestamp::DATE - (coalesce(${date_rehired},${date_hired}))::DATE)/30.4 ;;
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
  dimension: employee_id {
    type: string
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
  dimension: greenhouse_application_id {
    type: number
    sql: ${TABLE}."GREENHOUSE_APPLICATION_ID" ;;
  }
  dimension: home_phone {
    type: string
    sql: ${TABLE}."HOME_PHONE" ;;
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

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;

  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: region_name{
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: market_type{
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: nickname {
    type: string
    sql: ${TABLE}."NICKNAME" ;;
  }

  dimension: nickname_full_name {
    type: string
    sql: CASE WHEN position(' ',coalesce(${nickname},${first_name})) = 0 then concat(coalesce(${nickname},${first_name}), ' ', ${last_name})
      else concat(coalesce(${nickname},concat(${first_name}, ' ', ${last_name}))) end;;
  }

  dimension: rep {
    label: "Rep - Market"
    type: string
    sql: CONCAT(${nickname_full_name}, ' - ', ${location}) ;;
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
    drill_fields: [last_name, doc_uname, direct_manager_name, nickname, first_name]
  }
}
