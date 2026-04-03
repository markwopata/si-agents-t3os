view: concur_inv_header_for_reassign {
  derived_table: {
    sql: SELECT
          INVH.REQUEST_ID                               AS REQUEST_ID,
          INVH.SUPPLIER_CODE                            AS VENDOR_ID,
          INVH.SUPPLIER_NAME                            AS VENDOR_NAME,
          INVH.INVOICE_NUMBER                           AS INVOICE_NUMBER,
          INVH.REQUEST_TOTAL                            AS INVOICE_TOTAL,
          INVH.APPROVAL_STATUS                          AS APPROVAL_STATUS,
          INVH.PAYMENT_STATUS                           AS PAYMENT_STATUS,
          INVH.IS_DELETED                               AS IS_DELETED,
          INVH.EMPLOYEE_EMAIL_ADDRESS                   AS CURRENT_ASSIGNMENT,
          CONCAT('<?xml version="1.0" encoding="UTF-8"?><PaymentRequest><RequestID>', INVH.REQUEST_ID,
                 '</RequestID><EmployeeLoginId>', {% parameter reassign_to %},
                 '</EmployeeLoginId></PaymentRequest>') AS IMPORT_THIS
      FROM
          ANALYTICS.CONCUR.INVOICE_HEADER INVH
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  parameter: reassign_to {
    type: string
  }

  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: invoice_total {
    type: number
    sql: ${TABLE}."INVOICE_TOTAL" ;;
  }

  dimension: approval_status {
    type: string
    sql: ${TABLE}."APPROVAL_STATUS" ;;
  }

  dimension: payment_status {
    type: string
    sql: ${TABLE}."PAYMENT_STATUS" ;;
  }

  dimension: is_deleted {
    type: string
    sql: ${TABLE}."IS_DELETED" ;;
  }

  dimension: current_assignment {
    type: string
    sql: ${TABLE}."CURRENT_ASSIGNMENT" ;;
  }

  dimension: import_this {
    type: string
    sql: ${TABLE}."IMPORT_THIS" ;;
  }

  set: detail {
    fields: [
      request_id,
      vendor_id,
      vendor_name,
      invoice_number,
      invoice_total,
      approval_status,
      payment_status,
      is_deleted,
      current_assignment,
      import_this
    ]
  }
}
