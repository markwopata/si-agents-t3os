view: dim_salesperson_enhanced {

  sql_table_name: "BUSINESS_INTELLIGENCE"."GOLD"."V_DIM_SALESPERSON_ENHANCED" ;;

  dimension_group: _created_recordtimestamp {
    type: time
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
    hidden: yes
  }
  dimension: _is_current {
    type: yesno
    sql: ${TABLE}."_IS_CURRENT" ;;
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
    hidden:  yes
  }

  dimension_group: _valid_from {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_VALID_FROM" ;;
  }

  dimension_group: _valid_to {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_VALID_TO" ;;
  }

  dimension_group: date_hired_current {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_HIRED_CURRENT" ;;
  }

  dimension_group: date_rehired_current {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_REHIRED_CURRENT" ;;
  }

  dimension_group: date_terminated_current {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_TERMINATED_CURRENT" ;;
  }

  dimension: direct_manager_email_address_current {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMAIL_ADDRESS_CURRENT" ;;
  }

  dimension: direct_manager_employee_id_current {
    type: number
    value_format_name: id
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID_CURRENT" ;;
  }

  dimension: direct_manager_name_current {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME_CURRENT" ;;
  }

  dimension: direct_manager_user_id_current {
    type: number
    value_format_name: id
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID_CURRENT" ;;
  }

  dimension: employee_email_current {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL_CURRENT" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_status_hist {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS_HIST" ;;
  }

  dimension: employee_title_hist {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE_HIST" ;;
  }

  dimension_group: first_salesperson {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FIRST_SALESPERSON_DATE" ;;
  }

  dimension_group: first_tam {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FIRST_TAM_DATE" ;;
  }

  dimension: has_salesperson_title {
    type: yesno
    sql: ${TABLE}."HAS_SALESPERSON_TITLE" ;;
  }

  dimension: market_district_hist {
    type: string
    sql: ${TABLE}."MARKET_DISTRICT_HIST" ;;
  }

  dimension: market_division_name_hist {
    type: string
    sql: ${TABLE}."MARKET_DIVISION_NAME_HIST" ;;
  }

  dimension: market_id_hist {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID_HIST" ;;
  }

  dimension: market_name_hist {
    type: string
    sql: ${TABLE}."MARKET_NAME_HIST" ;;
  }

  dimension: market_region_hist {
    type: number
    sql: ${TABLE}."MARKET_REGION_HIST" ;;
  }

  dimension: market_region_name_hist {
    type: string
    sql: ${TABLE}."MARKET_REGION_NAME_HIST" ;;
  }

  dimension: name_current {
    type: string
    sql: ${TABLE}."NAME_CURRENT" ;;
  }

  dimension_group: position_effective_date_hist {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."POSITION_EFFECTIVE_DATE_HIST" ;;
  }

  dimension: salesperson_jurisdiction {
    type: string
    sql: ${TABLE}."SALESPERSON_JURISDICTION" ;;
  }

  dimension: salesperson_key {
    type: string
    sql: ${TABLE}."SALESPERSON_KEY" ;;
    primary_key: yes
    hidden: yes
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_is_deleted {
    type: yesno
    sql: ${TABLE}."USER_IS_DELETED" ;;
  }

  dimension: worker_type_current {
    type: string
    sql: ${TABLE}."WORKER_TYPE_CURRENT" ;;
  }

  measure: count {
    type: count
  }
}
