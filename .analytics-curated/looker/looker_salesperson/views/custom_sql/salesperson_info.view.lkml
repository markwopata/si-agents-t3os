
view: salesperson_info {
  derived_table: {
    sql: select *,
     CASE WHEN DATEADD(month, '6', first_date_as_TAM) > CONVERT_TIMEZONE('UTC', 'America/Chicago', CURRENT_TIMESTAMP())::DATE THEN 'Under 6 Months' ELSE 'Older than 6 Months' END AS new_sp_flag_current
        from analytics.bi_ops.salesperson_info where record_ineffective_date IS NULL;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: record_effective_date {
    type: date
    sql: ${TABLE}."RECORD_EFFECTIVE_DATE" ;;
  }

  dimension: record_ineffective_date {
    type: date
    sql: ${TABLE}."RECORD_INEFFECTIVE_DATE" ;;
  }

  dimension: user_id {
    type: string
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: rep {
    type:  string
    sql: CONCAT(${name}, ' - ', ${home_market_dated}) ;;
  }

  dimension: salesperson {
    type: string
    sql: ${name} ;;
    html:
    <font color="#0063f3 "><a href="https://equipmentshare.looker.com/dashboards/1409?Rep={{rep._filterable_value}}"target="_blank">
    {{rendered_value}} ➔</a>
    <br />
    <font style="color: #8C8C8C; text-align: right;">Home: {{home_market_dated._rendered_value }} </font>
    ;;
  }

  dimension: email_address {
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: region_dated {
    type: string
    sql: ${TABLE}."REGION_DATED" ;;
  }

  dimension: region_name_dated {
    type: string
    sql: ${TABLE}."REGION_NAME_DATED" ;;
  }

  dimension: district_dated {
    type: string
    sql: ${TABLE}."DISTRICT_DATED" ;;
  }

  dimension: home_market_id_dated {
    type: string
    sql: ${TABLE}."HOME_MARKET_ID_DATED" ;;
  }

  dimension: home_market_dated {
    type: string
    sql: ${TABLE}."HOME_MARKET_DATED" ;;
  }

  dimension: rep_current_location {
    type:  string
    sql: CONCAT(${name}, ' - ', COALESCE(${home_market_dated}, concat('District ', ${district_dated}), ${region_name_dated})) ;;
  }

  dimension: date_hired_initial {
    type: date
    sql: ${TABLE}."DATE_HIRED_INITIAL" ;;
  }

  dimension: start_date_as_salesperson {
    type: date
    sql: ${TABLE}."START_DATE_AS_SALESPERSON" ;;
  }

  dimension: date_rehired_present {
    type: date
    sql: ${TABLE}."DATE_REHIRED_PRESENT" ;;
  }

  dimension: date_terminated_present {
    type: date
    sql: ${TABLE}."DATE_TERMINATED_PRESENT" ;;
  }

  dimension: employee_status_present {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS_PRESENT" ;;
  }

  dimension: employee_title_dated {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE_DATED" ;;
  }

  dimension: employee_title_dated_is_salesperson {
    type: yesno
    sql: ${TABLE}."EMPLOYEE_TITLE_DATED_IS_SALESPERSON" ;;
  }

  dimension: salesperson_jurisdiction_dated {
    type: string
    sql: ${TABLE}."SALESPERSON_JURISDICTION_DATED" ;;
  }

  dimension: direct_manager_user_id_present {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID_PRESENT" ;;
  }

  dimension: direct_manager_employee_id_present {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID_PRESENT" ;;
  }

  dimension: direct_manager_name_present {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME_PRESENT" ;;
  }

  dimension: direct_manager_name {
    type: string
    sql: TRIM(LEFT(${direct_manager_name_present}, POSITION('(' IN ${direct_manager_name_present}) - 1));;
  }

  dimension: direct_manager_email_present {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMAIL_PRESENT" ;;
  }

  dimension: first_date_as_tam {
    type: date
    sql: ${TABLE}."FIRST_DATE_AS_TAM" ;;
  }

  dimension: new_sp_flag_current {
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }

  set: detail {
    fields: [
        record_effective_date,
  record_ineffective_date,
  user_id,
  employee_id,
  name,
  email_address,
  region_dated,
  region_name_dated,
  district_dated,
  home_market_id_dated,
  home_market_dated,
  date_hired_initial,
  start_date_as_salesperson,
  date_rehired_present,
  date_terminated_present,
  employee_status_present,
  employee_title_dated,
  employee_title_dated_is_salesperson,
  salesperson_jurisdiction_dated,
  direct_manager_user_id_present,
  direct_manager_employee_id_present,
  direct_manager_name_present,
  direct_manager_email_present,
  first_date_as_tam
    ]
  }
}
