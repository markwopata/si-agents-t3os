view: lease_accelerator_leasing_summary {
  sql_table_name: "LEASE_ACCELERATOR"."LEASE_ACCELERATOR_LEASING_SUMMARY" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: asset_type {
    type: string
    sql: ${TABLE}."ASSET_TYPE" ;;
  }
  dimension_group: booking_ledger {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."BOOKING_LEDGER_DATE" ;;
  }
  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }
  dimension: equipment_value_local {
    type: number
    sql: ${TABLE}."EQUIPMENT_VALUE_LOCAL" ;;
    value_format: "$#,##0.00"
  }
  dimension: equipment_value_reporting_currency {
    type: number
    sql: ${TABLE}."EQUIPMENT_VALUE_REPORTING_CURRENCY" ;;
  }
  dimension: funder {
    type: string
    sql: ${TABLE}."FUNDER" ;;
  }
  dimension: lease_rent_factor {
    type: number
    sql: ${TABLE}."LEASE_RENT_FACTOR" ;;
  }
  dimension_group: rental_end {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."RENTAL_END" ;;
  }
  dimension: rental_local {
    type: number
    sql: ${TABLE}."RENTAL_LOCAL" ;;
  }
  dimension_group: rental_start {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."RENTAL_START" ;;
  }
  dimension: schedule_number {
    type: string
    sql: ${TABLE}."SCHEDULE_NUMBER" ;;
  }
  dimension: ledger_code {
    type: string
    sql: ${TABLE}."LEDGER_CODE" ;;
  }

  dimension_group: time_of_run {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIME_OF_RUN" ;;
  }
  dimension: ledger_category {
    type: string
    sql: ${TABLE}."LEDGER_CATEGORY" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: most_recent_run {
    type: string
    sql: ${TABLE}."MOST_RECENT_RUN" ;;
  }

  dimension: term {
    type: number
    sql: ${TABLE}."TERM" ;;
  }
  dimension: total_rent_local {
    type: number
    sql: ${TABLE}."TOTAL_RENT_LOCAL" ;;
  }
  dimension: total_rent_reporting_currency {
    type: number
    sql: ${TABLE}."TOTAL_RENT_REPORTING_CURRENCY" ;;
  }
  measure: count {
    type: count
  }
}
