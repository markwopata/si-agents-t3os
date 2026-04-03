
view: commission_plan_wd_data_load {
  sql_table_name: "PEOPLE_ANALYTICS"."LOOKER"."COMMISSION_PLAN_WD_DATA_LOAD" ;;

  dimension: workday_id {
    primary_key: yes
    type: string
    sql: ${TABLE}.WORKDAY_ID ;;
  }

  dimension: employee {
    type: string
    sql: ${TABLE}.EMPLOYEE ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.EMPLOYEE_ID ;;
  }

  dimension: compensation_plan_type {
    type: string
    sql: ${TABLE}.COMPENSATION_PLAN_TYPE ;;
  }

  dimension: compensation_change {
    type: string
    sql: ${TABLE}.COMPENSATION_CHANGE ;;
  }

  dimension: compensation_event_status {
    type: string
    sql: ${TABLE}.COMPENSATION_EVENT_STATUS ;;
  }

  dimension: assignment_details_proposed {
    type: string
    sql: ${TABLE}.COMPENSATION_EVENT_OVERALL_BUSINESS_PROCESS ;;
  }

  dimension: compensation_event_overall_business_process {
    type: string
    sql: ${TABLE}.COMPENSATION_EVENT_OVERALL_BUSINESS_PROCESS ;;
  }

  dimension: compensation_event_business_process_reason {
    type: string
    sql: ${TABLE}.COMPENSATION_EVENT_BUSINESS_PROCESS_REASON ;;
  }

  dimension: compensation_event_business_process_type {
    type: string
    sql: ${TABLE}.COMPENSATION_EVENT_BUSINESS_PROCESS_TYPE ;;
  }

  dimension: business_title_current {
    type: string
    sql: ${TABLE}.BUSINESS_TITLE_CURRENT ;;
  }

  dimension: business_title_proposed {
    type: string
    sql: ${TABLE}.BUSINESS_TITLE_PROPOSED ;;
  }

  dimension: position_current {
    type: string
    sql: ${TABLE}.POSITION_CURRENT ;;
  }

  dimension: position_id_current {
    type: string
    sql: ${TABLE}.POSITION_ID_CURRENT ;;
  }

  dimension: position_proposed {
    type: string
    sql: ${TABLE}.POSITION_PROPOSED ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.LOCATION ;;
  }

  dimension: cost_center {
    type: string
    sql: ${TABLE}.COST_CENTER ;;
  }

  dimension: initiating_worker {
    type: string
    sql: ${TABLE}.INITIATING_WORKER ;;
  }

  dimension_group: effective_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.EFFECTIVE_DATE ;;
  }

  dimension_group: date_time_initiated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_TIME_INITIATED ;;
  }

  dimension_group: date_time_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_TIME_COMPLETED ;;
  }

  dimension_group: actual_end_date_proposed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.ACTUAL_END_DATE_PROPOSED ;;
  }

  dimension_group: actual_end_date_current {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.ACTUAL_END_DATE_CURRENT ;;
  }

  measure: count {
    type: count
  }
}
