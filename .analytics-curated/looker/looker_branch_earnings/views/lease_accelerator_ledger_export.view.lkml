view: lease_accelerator_ledger_export {
  sql_table_name: "LEASE_ACCELERATOR"."LEASE_ACCELERATOR_LEDGER_EXPORT" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: account_description {
    type: string
    sql: ${TABLE}."ACCOUNT_DESCRIPTION" ;;
  }
  dimension: admin_asset_id {
    type: number
    sql: ${TABLE}."ADMIN_ASSET_ID" ;;
    value_format: "0"
  }
  dimension: asset_number {
    type: string
    sql: ${TABLE}."ASSET_NUMBER" ;;
  }
  dimension: asset_reference_number {
    type: string
    sql: ${TABLE}."ASSET_REFERENCE_NUMBER" ;;
  }
  dimension: serial_number {
    type: string
    sql: ${TABLE}."SERIAL_NUMBER" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }
  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: first_rental_date {
    type: string
    sql: ${TABLE}."FIRST_RENTAL_DATE" ;;
  }
  dimension: schedule {
    type: string
    sql: ${TABLE}."SCHEDULE" ;;
  }
  dimension: comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }
  dimension: credit_amount {
    type: number
    sql: ${TABLE}."CREDIT_AMOUNT" ;;
    }
  dimension: debit_amount {
    type: number
    sql: ${TABLE}."DEBIT_AMOUNT" ;;
    }
  dimension: net_amount {
    type: number
    sql: ${TABLE}."NET_AMOUNT" ;;
  }
  dimension: es_segment {
    type: string
    sql: ${TABLE}."ES_SEGMENT" ;;
  }
  dimension: foreign_exchange_rate_type {
    type: string
    sql: ${TABLE}."FOREIGN_EXCHANGE_RATE_TYPE" ;;
  }
  dimension: functional_currency {
    type: string
    sql: ${TABLE}."FUNCTIONAL_CURRENCY" ;;
  }
  dimension: gl_account_number {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }
  dimension: journal_entry_description {
    type: string
    sql: ${TABLE}."JOURNAL_ENTRY_DESCRIPTION" ;;
  }
  dimension: las_asset_id {
    type: string
    sql: ${TABLE}."LAS_ASSET_ID" ;;
  }
  dimension_group: ledger {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."LEDGER_DATE" ;;
  }
  dimension: ledger_entry_id {
    type: string
    sql: ${TABLE}."LEDGER_ENTRY_ID" ;;
  }
  dimension: ledger_entry_sub_id {
    type: string
    sql: ${TABLE}."LEDGER_ENTRY_SUB_ID" ;;
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
  dimension_group: related_period {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."RELATED_PERIOD" ;;
  }
  dimension: reporting_currency {
    type: string
    sql: ${TABLE}."REPORTING_CURRENCY" ;;
  }
  dimension_group: status {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."STATUS" ;;
  }
  dimension_group: time_of_run {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIME_OF_RUN" ;;
  }
  dimension_group: commencement_date {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COMMENCEMENT_DATE" ;;
  }
  dimension: transactional_currency {
    type: string
    sql: ${TABLE}."TRANSACTIONAL_CURRENCY" ;;
  }
  measure: count {
    type: count
  }
}
