view: invoices_by_exception_code {
  sql_table_name: "ANALYTICS"."CONCUR"."INVOICES_BY_EXCEPTION_CODE"
    ;;




  dimension: cognos_date {
    type: date
    sql: ${TABLE}."COGNOS_DATE" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: exception_code {
    type: string
    sql: CASE WHEN ${TABLE}."EXCEPTION_CODE" IS NULL THEN 'Blank'
              WHEN ${TABLE}."EXCEPTION_CODE" = 'NOPOLINE' THEN 'No PO or Missing PO Line(s)'
              WHEN ${TABLE}."EXCEPTION_CODE" = 'FUTRDATE' THEN 'Future Dated Invoice'
              WHEN ${TABLE}."EXCEPTION_CODE" = 'COW'      THEN 'DOA - Needs Higher Auth to Approve'
              WHEN ${TABLE}."EXCEPTION_CODE" = 'TOTALS'   THEN 'Cost Discrepancy'
              WHEN ${TABLE}."EXCEPTION_CODE" = 'NEWVEND'  THEN 'New Vendor, Needs Setup'
              WHEN ${TABLE}."EXCEPTION_CODE" = 'DUPINV99' THEN 'Duplicate Invoice'
              WHEN ${TABLE}."EXCEPTION_CODE" = 'CONOAPPR' THEN 'Needs an Approver To Be Assigned'
              ELSE 'Blank' END;;
  }

  dimension: exception_code_sort {
    type: number
    sql: CASE WHEN ${TABLE}."EXCEPTION_CODE" IS NULL THEN 8
              WHEN ${TABLE}."EXCEPTION_CODE" = 'NOPOLINE' THEN 6
              WHEN ${TABLE}."EXCEPTION_CODE" = 'FUTRDATE' THEN 4
              WHEN ${TABLE}."EXCEPTION_CODE" = 'COW'      THEN 2
              WHEN ${TABLE}."EXCEPTION_CODE" = 'TOTALS'   THEN 7
              WHEN ${TABLE}."EXCEPTION_CODE" = 'NEWVEND'  THEN 5
              WHEN ${TABLE}."EXCEPTION_CODE" = 'DUPINV99' THEN 3
              WHEN ${TABLE}."EXCEPTION_CODE" = 'CONOAPPR' THEN 1
              ELSE 8 END;;
  }

  dimension: exception_text {
    type: string
    sql:${TABLE}."EXCEPTION_TEXT" ;;
  }

  dimension: expense_type_name {
    type: string
    sql: ${TABLE}."EXPENSE_TYPE_NAME" ;;
  }



  dimension: invoice_name {
    type: string
    sql: ${TABLE}."INVOICE_NAME" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: system_receive_date {
    type: date
    sql: ${TABLE}."SYSTEM_RECEIVE_DATE" ;;
  }

  measure: total_requested {
    type: sum
    value_format: "$#,##0;($#,##0);-"
    sql: ${TABLE}."TOTAL_REQUESTED_RPT" ;;
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
    value_format: "#,##0"
    drill_fields: [exception_details*]
  }

  measure: invoice_count {
    type: count_distinct
    value_format: "#,##0"
    drill_fields: [exception_details*]
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  set: exception_details {
    fields: [invoice_name,invoice_number,vendor_id,vendor_name,location,expense_type_name,purchase_order_number,system_receive_date,invoice_date,
      exception_code,exception_text,total_requested]
  }

}
