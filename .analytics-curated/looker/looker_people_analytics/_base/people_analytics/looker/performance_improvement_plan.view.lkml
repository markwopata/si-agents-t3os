view: performance_improvement_plan {
  sql_table_name: "LOOKER"."PERFORMANCE_IMPROVEMENT_PLAN" ;;

  dimension: awaiting_persons {
    type: string
    sql: ${TABLE}."AWAITING_PERSONS" ;;
  }
  dimension: business_title {
    type: string
    sql: ${TABLE}."BUSINESS_TITLE" ;;
  }
  dimension: current_steps {
    type: string
    sql: ${TABLE}."CURRENT_STEPS" ;;
  }
  dimension_group: date_initiated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_INITIATED" ;;
  }
  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension_group: effective {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EFFECTIVE_DATE" ;;
  }
  dimension: employee_id {
    type: number
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: employee_status {
    type: string
    sql: ${TABLE}."EMPLOYEE_STATUS" ;;
  }
  dimension_group: end {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."END_DATE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: overall_business_process {
    type: string
    sql: ${TABLE}."OVERALL_BUSINESS_PROCESS" ;;
  }
  dimension: position_length_of_service {
    type: string
    sql: ${TABLE}."POSITION_LENGTH_OF_SERVICE" ;;
  }
  dimension: review_template {
    type: string
    sql: ${TABLE}."REVIEW_TEMPLATE" ;;
  }
  dimension_group: start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: time_completed {
    type: string
    sql: ${TABLE}."TIME_COMPLETED" ;;
  }
  dimension: worker {
    type: string
    sql: ${TABLE}."WORKER" ;;
  }
  dimension: workers_manager {
    type: string
    sql: ${TABLE}."WORKERS_MANAGER" ;;
  }
  measure: count {
    type: count
  }
}
