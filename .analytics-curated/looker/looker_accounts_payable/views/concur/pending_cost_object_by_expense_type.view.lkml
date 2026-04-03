view: pending_cost_object_by_expense_type {
  sql_table_name: "CONCUR"."PENDING_COST_OBJECT_BY_EXPENSE_TYPE" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }
  dimension: cost_object_approver {
    type: string
    sql: ${TABLE}."COST_OBJECT_APPROVER" ;;
  }
  dimension: days_pending_approval {
    type: number
    sql: ${TABLE}."DAYS_PENDING_APPROVAL" ;;
  }
  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }
  dimension: expense_type_name {
    type: string
    sql: ${TABLE}."EXPENSE_TYPE_NAME" ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
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
  dimension: location_code {
    type: string
    sql: ${TABLE}."LOCATION_CODE" ;;
  }
  dimension: requesting_branch {
    type: string
    sql: concat(${location_code}, ' - ', ${location});;
  }
  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }
  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }
  dimension: total_requested {
    type: number
    sql: ${TABLE}."TOTAL_REQUESTED" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: days_past_due {
    type: number
    sql: ${TABLE}."DAYS_PAST_DUE" ;;
  }
  dimension: invoice_received_date {type: date sql: ${TABLE}."INVOICE_RECEIVED_DATE" ;;}
  dimension: payment_terms_days {type: number sql: ${TABLE}."PAYMENT_TERM_DAYS" ;;}
  dimension: payment_terms {type: string sql: ${TABLE}."PAYMENT_TERM_DAYS" ;;}
  dimension: payment_due_date {type: date sql: ${TABLE}."PAYMENT_DUE_DATE" ;;}


  measure: count {
    type: count
    drill_fields: [expense_type_name, vendor_name, days_past_due, days_pending_approval, po_number, location]
  }
}
