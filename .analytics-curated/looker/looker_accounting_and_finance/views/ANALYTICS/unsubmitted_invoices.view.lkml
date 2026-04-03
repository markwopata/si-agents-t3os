view: unsubmitted_invoices {
  sql_table_name: "ANALYTICS"."TREASURY"."UNSUBMITTED_INVOICES"
    ;;



   dimension: _es_update_timestamp {
    type: date
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }

  dimension: custom_1_location {
    type: string
    sql: ${TABLE}."CUSTOM_1_LOCATION" ;;
  }

  dimension: custom_1_name {
    type: string
    sql: ${TABLE}."CUSTOM_1_NAME" ;;
  }

  dimension: days_past_due {
    type: number
    sql: ${TABLE}."DAYS_PAST_DUE" ;;
  }



  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: employee_last_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_LAST_NAME" ;;
  }

  dimension: inventory_reporting_category {
    type: string
    sql: ${TABLE}."INVENTORY_REPORTING_CATEGORY" ;;
  }



  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: invoice_received_date {
    type: date
    sql: ${TABLE}."INVOICE_RECEIEVED_DATE" ;;
  }



  dimension: invoice_received {
    type: string
    sql: ${TABLE}."INVOICE_RECEIVED" ;;
  }


  dimension: misc1 {
    type: string
    sql: ${TABLE}."MISC1" ;;
  }

  dimension: non_inventory {
    type: string
    sql: ${TABLE}."NON_INVENTORY" ;;
  }

  dimension: origin_source {
    type: string
    sql: ${TABLE}."ORIGIN_SOURCE" ;;
  }

  dimension: past_due_bucket {
    type: string
    sql: ${TABLE}."PAST_DUE_BUCKET" ;;
  }

  dimension: past_due_bucket_order {
    type: number
    sql: case when ${past_due_bucket} = 'Current' then 1
         when ${past_due_bucket}      = '0-14' then 2
         when ${past_due_bucket}      = '15-30' then 3
         when ${past_due_bucket}      = '30+' then 4
         when ${past_due_bucket}      = '45+' then 5
         when ${past_due_bucket}      = '60+' then 6
         when ${past_due_bucket}      = '90+' then 7
         when ${past_due_bucket}      = '120+' then 8
         else 9 end ;;
  }

  dimension: payment_due_date {
    type: date
    sql: ${TABLE}."PAYMENT_DUE_DATE" ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }

  dimension: policy {
    type: string
    sql: ${TABLE}."POLICY" ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: request_name {
    type: string
    sql: ${TABLE}."REQUEST_NAME" ;;
  }

  dimension: revised_terms {
    type: number
    sql: ${TABLE}."REVISED_TERMS" ;;
  }

  dimension: service_type {
    type: string
    sql: ${TABLE}."SERVICE_TYPE" ;;
  }



  dimension: vendor_id {
    type: string
    sql: ${TABLE}."SUPPLIER_CODE" ;;
  }

  dimension: submit_date {
    type: date
    sql: ${TABLE}."SUBMIT_DATE" ;;
  }

  dimension: supplier_invoice_number {
    type: string
    sql: ${TABLE}."SUPPLIER_INVOICE_NUMBER" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."TERMS" ;;
  }



  measure: request_total {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  measure: request_total_mm {
    type: sum
    value_format: "$0,,;($0,,);-"
    drill_fields: [drill_details*]
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  measure: request_total_inv {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    sql: case where ${inventory_reporting_category} = 'Inventory' then ${TABLE}."REQUEST_TOTAL" else 0 end ;;
  }

  measure: request_total_non {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [drill_details*]
    sql: case where ${inventory_reporting_category} = 'Non-Inventory' then ${TABLE}."REQUEST_TOTAL" else 0 end ;;
  }

  measure: count {
    type: count
    drill_fields: [drill_details*]
  }

  set: drill_details {
    fields: [request_name, employee_last_name, vendor_name, vendor_id, invoice_received, invoice_received_date, origin_source, approval_status,payment_status,
      policy,purchase_order_number,invoice_date,non_inventory,due_date,days_past_due, past_due_bucket, request_total
    ]
  }

}
