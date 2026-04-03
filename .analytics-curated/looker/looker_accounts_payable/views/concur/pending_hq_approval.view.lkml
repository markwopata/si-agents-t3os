view: pending_hq_approval {
  sql_table_name: "CONCUR"."PENDING_HQ_APPROVAL" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: account_code {
    type: string
    sql: ${TABLE}."ACCOUNT_CODE" ;;
  }
  dimension: amt_breakdown {
    type: number
    sql: ${TABLE}."AMT_BREAKDOWN" ;;
  }
  dimension: approver_email {
    type: string
    sql: ${TABLE}."APPROVER_EMAIL" ;;
  }
  dimension: approver_name {
    type: string
    sql: ${TABLE}."APPROVER_NAME" ;;
  }
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }
  dimension_group: cognos {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."COGNOS_DATE" ;;
  }
  dimension: days_pending_approval {
    type: number
    sql: ${TABLE}."DAYS_PENDING_APPROVAL" ;;
  }
  dimension_group: invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: invoice_received {
    type: string
    sql: ${TABLE}."INVOICE_RECEIVED" ;;
  }
  dimension_group: invoice_received {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_RECEIVED_DATE" ;;
  }
  dimension_group: latest_submit {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LATEST_SUBMIT_DATE" ;;
  }
  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }
  dimension: request_key {
    type: string
    sql: ${TABLE}."REQUEST_KEY" ;;
  }
  dimension: request_legacy_key {
    type: string
    sql: ${TABLE}."REQUEST_LEGACY_KEY" ;;
  }
  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [vendor_name, approver_name]
  }
}
