view: v_dim_salesperson_enhanced {
  sql_table_name: BUSINESS_INTELLIGENCE.GOLD.V_DIM_SALESPERSON_ENHANCED ;;

  dimension: salesperson_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."SALESPERSON_KEY" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_is_deleted {
    type: yesno
    sql: ${TABLE}."USER_IS_DELETED" ;;
  }

  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: employee_email_current {
    type: string
    sql: ${TABLE}."EMPLOYEE_EMAIL_CURRENT" ;;
  }

  dimension: name_current {
    type: string
    sql: ${TABLE}."NAME_CURRENT" ;;
  }

  dimension_group: date_hired_current {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."DATE_HIRED_CURRENT" ;;
  }

  dimension_group: date_rehired_current {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."DATE_REHIRED_CURRENT" ;;
  }

  dimension_group: date_terminated_current {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."DATE_TERMINATED_CURRENT" ;;
  }

  dimension: has_salesperson_title {
    type: yesno
    sql: ${TABLE}."HAS_SALESPERSON_TITLE" ;;
  }

  dimension: salesperson_jurisdiction {
    type: string
    sql: ${TABLE}."SALESPERSON_JURISDICTION" ;;
  }

  dimension: worker_type_current {
    type: string
    sql: ${TABLE}."WORKER_TYPE_CURRENT" ;;
  }

  dimension: market_division_name_hist {
    type: string
    sql: ${TABLE}."MARKET_DIVISION_NAME_HIST" ;;
  }

  dimension: market_id_hist {
    type: number
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

  dimension: market_district_hist {
    type: string
    sql: ${TABLE}."MARKET_DISTRICT_HIST" ;;
  }

  dimension: employee_title_hist {
    type: string
    description: "When not in this table or in excluded names list, we are labeling them 'Corporate'"
    sql:
      CASE
        WHEN ${TABLE}."NAME_CURRENT" IN ('Dan Weinshanker', 'Amy Howard', 'Tanner Jones') THEN 'Corporate'
        WHEN TRIM(${TABLE}."EMPLOYEE_TITLE_HIST") IS NULL OR TRIM(${TABLE}."EMPLOYEE_TITLE_HIST") = '' THEN 'Corporate'
        ELSE TRIM(${TABLE}."EMPLOYEE_TITLE_HIST")
      END
     ;;
  }

  dimension_group: position_effective_date_hist {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."POSITION_EFFECTIVE_DATE_HIST" ;;
  }

  dimension: employee_status_hist {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS_HIST" ;;
  }

  dimension_group: first_salesperson_date {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."FIRST_SALESPERSON_DATE" ;;
  }

  dimension_group: first_tam_date {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."FIRST_TAM_DATE" ;;
  }

  dimension: direct_manager_employee_id_current {
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_EMPLOYEE_ID_CURRENT" ;;
  }

  dimension: direct_manager_name_current {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_NAME_CURRENT" ;;
  }

  dimension: direct_manager_user_id_current {
    type: number
    sql: ${TABLE}."DIRECT_MANAGER_USER_ID_CURRENT" ;;
  }

  dimension: direct_manager_email_address_current {
    type: string
    sql: ${TABLE}."DIRECT_MANAGER_EMAIL_ADDRESS_CURRENT" ;;
  }

  dimension_group: _valid_from {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."_VALID_FROM" ;;
  }

  dimension_group: _valid_to {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."_VALID_TO" ;;
  }

  dimension: _is_current {
    type: yesno
    sql: ${TABLE}."_IS_CURRENT" ;;
  }

  dimension_group: _created_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."_CREATED_RECORDTIMESTAMP" ;;
  }

  dimension_group: _updated_recordtimestamp {
    type: time
    timeframes: [raw, time, date, week, month, year]
    sql: ${TABLE}."_UPDATED_RECORDTIMESTAMP" ;;
  }
}
