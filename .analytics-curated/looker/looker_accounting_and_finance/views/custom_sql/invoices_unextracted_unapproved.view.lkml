view: invoices_unextracted_unapproved {
derived_table: {
  sql: SELECT
    IR.INVOICE_NUMBER                                       AS INVOICE_NUMBER,
    IR.APPROVAL_STATUS                                      AS APPROVAL_STATUS,
    IR.PAYMENT_STATUS                                       AS PAYMENT_STATUS,
    IR.INVOICE_DATE                                         AS INVOICE_DATE,
    CB.BRANCH_ID                                            AS BRANCH_ID,
    CB.BRANCH_NAME                                          AS BRANCH_NAME,
    IR.EMPLOYEE_LAST_NAME                                   AS EMPLOYEE_NAME,
    IR.VENDOR_NAME                                          AS VENDOR_NAME,
    FROM ANALYTICS.CONCUR.INVOICES_RECEIVED IR
    LEFT JOIN ANALYTICS.CONCUR.UNSUBMITTED_INVOICES UI ON UI.SUPPLIER_INVOICE_NUMBER = IR.INVOICE_NUMBER
    LEFT JOIN ANALYTICS.CONCUR.CONCUR_BRANCHES CB ON CB.BRANCH_NAME = UI.CUSTOM_1_LOCATION
    WHERE IR.APPROVAL_STATUS != 'Approved'
    AND IR.PAYMENT_STATUS != 'Extracted'
    AND CB.BRANCH_ID NOT IN ('nan', '-') ;;
}

dimension: invoice_number {
  type: string
  label: "Invoice Number"
  sql: ${TABLE}."INVOICE_NUMBER" ;;
}

dimension: approval_status {
  type: string
  label: "Approval Status"
  sql: ${TABLE}."APPROVAL_STATUS" ;;
}

dimension: payment_status {
  type: string
  label: "Payment Status"
  sql: ${TABLE}."PAYMENT_STATUS" ;;
}

dimension: invoice_date {
  type: date
  label: "Invoice Date"
  sql: ${TABLE}."INVOICE_DATE" ;;
}

dimension: branch_id {
  type: string
  label: "Branch ID"
  sql: ${TABLE}."BRANCH_ID" ;;
}

dimension: branch_name {
  type: string
  label: "Branch Name"
  sql: ${TABLE}."BRANCH_NAME" ;;
}

dimension: employee_name {
  type: string
  label: "Employee Name"
  sql: ${TABLE}."EMPLOYEE_NAME" ;;
}

  dimension: vendor_name {
    type: string
    label: "Vendor Name"
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

measure: count {
  type: count
  drill_fields: [detail*]
}

set: detail {
  fields: [
    invoice_number,
    approval_status,
    payment_status,
    invoice_date,
    branch_id,
    branch_name,
    employee_name,
    vendor_name
  ]
}
}
