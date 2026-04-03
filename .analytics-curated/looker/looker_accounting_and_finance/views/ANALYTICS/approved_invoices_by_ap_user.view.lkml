view: approved_invoices_by_ap_user {
  sql_table_name: "ANALYTICS"."CONCUR"."APPROVED_INVOICES_BY_AP_USER"
    ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: ap_user_email {
    type: string
    sql: ${TABLE}."AP_USER_EMAIL" ;;
  }

  dimension: ap_user_name {
    type: string
    sql: case when ${TABLE}."AP_USER_NAME" = 'Administrator, Concur' then 'A. Concur Administrator'
      when ${TABLE}."AP_USER_NAME" = 'System, Concur' then 'AA. Concur System' else  ${TABLE}."AP_USER_NAME" end ;;
  }

  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension_group: final_approval_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."FINAL_APPROVAL_DATE" ;;
  }

  dimension: header_po_number {
    type: string
    sql: ${TABLE}."HEADER_PO_NUMBER" ;;
  }

  dimension_group: invoice_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension_group: invoice_received {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."INVOICE_RECEIVED_DATE" ;;
  }

  dimension_group: last_submit_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_SUBMIT_DATE" ;;
  }

  dimension: request_currency {
    type: string
    sql: ${TABLE}."REQUEST_CURRENCY" ;;
  }

  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }

  measure: request_total {
    type: sum
    drill_fields: [drill_details*]
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  measure: shipping_amount {
    type: sum
    drill_fields: [drill_details*]
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."SHIPPING_AMOUNT" ;;
  }

  measure: tax_amount {
    type: sum
    drill_fields: [drill_details*]
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."TAX_AMOUNT" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [drill_details*]
  }

  set: drill_details {
    fields: [ap_user_name,request_id,vendor_id,invoice_number,last_submit_date_date,invoice_date_date,header_po_number,approval_status,
       invoice_received_date,final_approval_date_date,tax_amount,shipping_amount,request_total
    ]
  }
}
