view: lease_accelerator_roll_forward {
  sql_table_name: "LEASE_ACCELERATOR"."LEASE_ACCELERATOR_ROLL_FORWARD" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: accountdescription {
    type: string
    sql: ${TABLE}."ACCOUNTDESCRIPTION" ;;
  }
  dimension: affected_component {
    type: string
    sql: ${TABLE}."AFFECTED_COMPONENT" ;;
  }
  dimension: comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }
  dimension: entry_type {
    type: string
    sql: ${TABLE}."ENTRY_TYPE" ;;
  }
  dimension: es_segment {
    type: string
    sql: ${TABLE}."ES_SEGMENT" ;;
  }
  dimension: event_details {
    type: string
    sql: ${TABLE}."EVENT_DETAILS" ;;
  }
  dimension: functional_cr {
    type: number
    sql: ${TABLE}."FUNCTIONAL_CR" ;;
  }
  dimension: functional_currency {
    type: string
    sql: ${TABLE}."FUNCTIONAL_CURRENCY" ;;
  }
  dimension: functional_dr {
    type: number
    sql: ${TABLE}."FUNCTIONAL_DR" ;;
  }
  dimension: functional_net {
    type: number
    sql: ${TABLE}."FUNCTIONAL_NET" ;;
  }
  dimension_group: fx_conversion {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."FX_CONVERSION_DATE" ;;
  }
  dimension: gl_account_number {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }
  dimension: je_type {
    type: string
    sql: ${TABLE}."JE_TYPE" ;;
  }
  dimension: jeshortdesc {
    type: string
    sql: ${TABLE}."JESHORTDESC" ;;
  }
  dimension: ledger_category {
    type: string
    sql: ${TABLE}."LEDGER_CATEGORY" ;;
  }
  dimension: ledger_code {
    type: string
    sql: ${TABLE}."LEDGER_CODE" ;;
  }
  dimension_group: ledger {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LEDGER_DATE" ;;
  }
  dimension: ledgerentrysubid {
    type: string
    sql: ${TABLE}."LEDGERENTRYSUBID" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: most_recent_run {
    type: number
    sql: ${TABLE}."MOST_RECENT_RUN" ;;
  }
  dimension: posting_code {
    type: string
    sql: ${TABLE}."POSTING_CODE" ;;
  }
  dimension: reporting_cr {
    type: number
    sql: ${TABLE}."REPORTING_CR" ;;
  }
  dimension: reporting_currency {
    type: string
    sql: ${TABLE}."REPORTING_CURRENCY" ;;
  }
  dimension: reporting_dr {
    type: number
    sql: ${TABLE}."REPORTING_DR" ;;
  }
  dimension: reporting_net {
    type: string
    sql: ${TABLE}."REPORTING_NET" ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}."SCHEDULE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension_group: time_of_run {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIME_OF_RUN" ;;
  }
  dimension: transactional_cr {
    type: number
    sql: ${TABLE}."TRANSACTIONAL_CR" ;;
  }
  dimension: transactional_currency {
    type: string
    sql: ${TABLE}."TRANSACTIONAL_CURRENCY" ;;
  }
  dimension: transactional_dr {
    type: number
    sql: ${TABLE}."TRANSACTIONAL_DR" ;;
  }
  dimension: transactional_net {
    type: number
    sql: ${TABLE}."TRANSACTIONAL_NET" ;;
  }
  dimension: triggering_event {
    type: string
    sql: ${TABLE}."TRIGGERING_EVENT" ;;
  }
  measure: count {
    type: count
  }
}
