view: guarantees_commissions_status {
  sql_table_name: "ANALYTICS"."BI_OPS"."GUARANTEES_COMMISSIONS_STATUS" ;;

  dimension_group: commission_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COMMISSION_END_DATE" ;;
  }
  dimension_group: commission_start_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COMMISSION_START_DATE" ;;
  }
  dimension: commission_type {
    type: string
    sql: ${TABLE}."COMMISSION_TYPE" ;;
  }
  dimension: contract_months_of_guarantee {
    type: number
    sql: ${TABLE}."CONTRACT_MONTHS_OF_GUARANTEE" ;;
  }
  dimension: current_guarantee_status {
    type: string
    sql: ${TABLE}."CURRENT_GUARANTEE_STATUS" ;;
  }
  dimension: current_home_district {
    type: string
    sql: ${TABLE}."CURRENT_HOME_DISTRICT" ;;
  }
  dimension: current_home_location {
    type: string
    sql: ${TABLE}."CURRENT_HOME_LOCATION" ;;
  }
  dimension: current_home_market {
    type: string
    sql: ${TABLE}."CURRENT_HOME_MARKET" ;;
  }
  dimension: current_home_market_id {
    type: number
    sql: ${TABLE}."CURRENT_HOME_MARKET_ID" ;;
  }
  dimension: current_home_region {
    type: string
    sql: ${TABLE}."CURRENT_HOME_REGION" ;;
  }
  dimension: current_months_of_guarantee {
    type: number
    sql: ${TABLE}."CURRENT_MONTHS_OF_GUARANTEE" ;;
  }
  dimension: direct_manager {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER" ;;
  }
  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }
  dimension_group: g_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."G_END" ;;
  }
  dimension: guarantee_amount {
    type: string
    sql: ${TABLE}."GUARANTEE_AMOUNT" ;;
  }
  dimension_group: guarantee_end_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."GUARANTEE_END_DATE" ;;
  }
  dimension_group: guarantee_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."GUARANTEE_START_DATE" ;;
  }
  dimension: hire_rehire_date {
    type: string
    sql: ${TABLE}."HIRE_REHIRE_DATE" ;;
  }
  dimension: lifetime_guarantee_months {
    type: number
    sql: ${TABLE}."LIFETIME_GUARANTEE_MONTHS" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: new_sp_flag_current {
    type: string
    sql: ${TABLE}."NEW_SP_FLAG_CURRENT" ;;
  }
  dimension_group: payroll_commission_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."PAYROLL_COMMISSION_START_DATE" ;;
  }
  dimension_group: payroll_guarantee_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."PAYROLL_GUARANTEE_END_DATE" ;;
  }
  dimension: rep {
    type: string
    sql: ${TABLE}."REP" ;;
  }
  dimension: rep_current_location {
    type: string
    sql: ${TABLE}."REP_CURRENT_LOCATION" ;;
  }
  dimension: row_num {
    type: number
    sql: ${TABLE}."ROW_NUM" ;;
  }
  dimension: salesperson_user_id {
    type: number
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }
  dimension: is_guaranteed {
    type: yesno
    sql: case when ${salesperson_user_id} is not null then true else false end ;;
  }
  dimension: terminated_date {
    type: string
    sql: ${TABLE}."TERMINATED_DATE" ;;
  }
  measure: count {
    type: count
    drill_fields: [name]
  }
}
