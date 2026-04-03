view: pending_hq_approval {
  sql_table_name: "ANALYTICS"."TREASURY"."PENDING_HQ_APPROVAL"
    ;;

  dimension: aged_bucket {
    type: string
    sql: ${TABLE}."AGED_BUCKET" ;;
  }

  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }

  dimension: cost_object {
    type: number
    sql: ${TABLE}."COST_OBJECT:" ;;
  }

  dimension: curr_due {
    type: date
    sql: ${TABLE}."CURR_DATE" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: latest_submit_date {
    type: date_time
    sql: ${TABLE}."LASTEST_SUBMIT_DATE" ;;
  }

  dimension: payment_due_date {
    type: date
    sql: ${TABLE}."PAYMENT_DUE_DATE" ;;
  }

  dimension: system_received_date {
    type: date_time
    sql: ${TABLE}."SYSTEM_RECEIVED_DATE" ;;
  }

  dimension: timestamp {
    type: date_time
    sql: ${TABLE}."TIMESTAMP" ;;
  }


  dimension: days_past_due {
    type: number
    sql: ${TABLE}."DAYS_PAST_DUE" ;;
  }

  dimension: employee_last_name {
    type: string
    sql: ${TABLE}."EMPLOYEE_LAST_NAME" ;;
  }



  dimension: invoice_name {
    type: string
    sql: ${TABLE}."INVOICE_NAME" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: invoice_received {
    type: string
    sql: ${TABLE}."INVOICE_RECEIVED" ;;
  }

  dimension: origin_source {
    type: string
    sql: ${TABLE}."ORIGIN_SOURCE" ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }

  dimension: vendor_code {
    type: string
    sql: ${TABLE}."VENDOR_CODE" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  measure: request_total {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    drill_fields: [pending_hq_details_amount*]
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  measure: invoice_count {
    type: count
    drill_fields: [pending_hq_details_count*]
  }

  set: pending_hq_details_count {
    fields: [invoice_number,invoice_name,invoice_date,employee_last_name,vendor_name,vendor_code,invoice_received,origin_source,approval_status,payment_status,
     system_received_date,payment_due_date,days_past_due,aged_bucket,invoice_count]
  }

  set: pending_hq_details_amount {
    fields: [invoice_number,invoice_name,invoice_date,employee_last_name,vendor_name,vendor_code,invoice_received,origin_source,approval_status,payment_status,
      system_received_date,payment_due_date,days_past_due,request_total]
  }



}
