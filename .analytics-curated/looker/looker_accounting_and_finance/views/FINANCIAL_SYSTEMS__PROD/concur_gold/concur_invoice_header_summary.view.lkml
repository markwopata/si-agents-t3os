view: concur_invoice_header_summary {
  sql_table_name: "CONCUR_GOLD"."CONCUR_INVOICE_HEADER_SUMMARY" ;;

  dimension: amount_invoice {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE" ;;
  }
  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }
  dimension: count_cleared_exceptions {
    type: number
    sql: ${TABLE}."COUNT_CLEARED_EXCEPTIONS" ;;
  }
  dimension: count_exceptions {
    type: number
    sql: ${TABLE}."COUNT_EXCEPTIONS" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }
  dimension: is_deleted {
    type: string
    sql: ${TABLE}."IS_DELETED" ;;
  }
  dimension: name_assigned_approver_over_10_k {
    type: string
    sql: ${TABLE}."NAME_ASSIGNED_APPROVER_OVER_10K" ;;
  }
  dimension: name_assigned_approver_over_25_k {
    type: string
    sql: ${TABLE}."NAME_ASSIGNED_APPROVER_OVER_25K" ;;
  }
  dimension: name_assigned_approver_over_5_k {
    type: string
    sql: ${TABLE}."NAME_ASSIGNED_APPROVER_OVER_5K" ;;
  }
  dimension: name_created_by_employee {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_EMPLOYEE" ;;
  }
  dimension: name_delegate_approver_over_10_k {
    type: string
    sql: ${TABLE}."NAME_DELEGATE_APPROVER_OVER_10K" ;;
  }
  dimension: name_delegate_approver_over_25_k {
    type: string
    sql: ${TABLE}."NAME_DELEGATE_APPROVER_OVER_25K" ;;
  }
  dimension: name_delegate_approver_over_5_k {
    type: string
    sql: ${TABLE}."NAME_DELEGATE_APPROVER_OVER_5K" ;;
  }
  dimension: name_deleted_by_employee {
    type: string
    sql: ${TABLE}."NAME_DELETED_BY_EMPLOYEE" ;;
  }
  dimension: name_request {
    type: string
    sql: ${TABLE}."NAME_REQUEST" ;;
  }
  dimension: name_requesting_employee {
    type: string
    sql: ${TABLE}."NAME_REQUESTING_EMPLOYEE" ;;
  }
  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }
  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }
  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }
  dimension: pk_request_key {
    type: number
    sql: ${TABLE}."PK_REQUEST_KEY" ;;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension_group: timestamp_approved_over_10_k {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_APPROVED_OVER_10K") ;;
  }
  dimension_group: timestamp_approved_over_25_k {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_APPROVED_OVER_25K") ;;
  }
  dimension_group: timestamp_approved_over_5_k {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_APPROVED_OVER_5K") ;;
  }
  dimension_group: timestamp_deleted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_DELETED") ;;
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_EXTRACTED") ;;
  }
  dimension_group: timestamp_invoice_received {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_INVOICE_RECEIVED") ;;
  }
  dimension_group: timestamp_invoice_submitted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_INVOICE_SUBMITTED") ;;
  }
  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CONVERT_TIMEZONE('UTC', 'America/Chicago', ${TABLE}."TIMESTAMP_LOADED") ;;
  }
  dimension: url_concur {
    label: "URL Concur"
    type: string
    sql: TRIM(${TABLE}."URL_CONCUR") ;;   # strip stray spaces
    link: {
      label: "Open Invoice Image"
      url: "{{ value }}"                 # render the cell’s value as the URL
    }
  }
  dimension: url_sage {
    type: string
    sql: ${TABLE}."URL_SAGE" ;;
    link: {
      label: "Open in Sage"
      url: "{{ value }}"                 # render the cell’s value as the URL
    }
  }
  measure: count {
    type: count
  }
}
