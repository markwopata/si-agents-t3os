view: pending_invoices_per_concur_approver {
  derived_table: {
    sql: SELECT DISTINCT
  PCOBET.COST_OBJECT_APPROVER,
  PCOBET.EMPLOYEE_ID,
  PCOBET.INVOICE_NUMBER,
  PCOBET.VENDOR_NAME,
  PCOBET.PO_NUMBER,
  PCOBET.LATEST_SUBMIT_DATE,
  CAST(PCOBET.DAYS_PENDING_APPROVAL AS INT) AS DAYS_PENDING_APPROVAL,
  PCOBET.LOCATION,
  PCOBET.REQUEST_TOTAL,
  CAST(PCOBET.PAYMENT_TERM_DAYS AS INT) AS PAYMENT_TERM_DAYS,
  PCOBET.INVOICE_RECEIVED_DATE,
  DSPA.INVOICE_DATE,
  PCOBET.PAYMENT_DUE_DATE,
  CAST(PCOBET.DAYS_PAST_DUE AS INT) AS DAYS_PAST_DUE
FROM ANALYTICS.CONCUR.PENDING_COST_OBJECT_BY_EXPENSE_TYPE PCOBET
LEFT JOIN ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL DSPA ON PCOBET.INVOICE_NUMBER = DSPA.INVOICE_NUMBER
ORDER BY DSPA.INVOICE_DATE DESC
            ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: cost_object_approver {
    type: string
    sql: ${TABLE}."COST_OBJECT_APPROVER" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."EMPLOYEE_ID" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: latest_submit_date {
    type: date
    sql: ${TABLE}."LATEST_SUBMIT_DATE" ;;
  }

  dimension: days_pending_approval {
    type: number
    sql: CAST(${TABLE}."DAYS_PENDING_APPROVAL" AS INT) ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: request_total {
    type: number
    sql: ${TABLE}."REQUEST_TOTAL" ;;
  }

  dimension: payment_term_days {
    type: number
    sql: CAST(${TABLE}."PAYMENT_TERM_DAYS" AS INT) ;;
  }

  dimension: invoice_received_date {
    type: date
    sql: ${TABLE}."INVOICE_RECEIVED_DATE" ;;
  }

  dimension: invoice_date {
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: payment_due_date {
    type: date
    sql: ${TABLE}."PAYMENT_DUE_DATE" ;;
  }

  dimension: days_past_due {
    type: number
    sql: CAST(${TABLE}."DAYS_PAST_DUE" AS INT) ;;
  }

  set: detail {
    fields: [
      cost_object_approver,
      employee_id,
      invoice_number,
      vendor_name,
      po_number,
      latest_submit_date,
      days_pending_approval,
      location,
      request_total,
      payment_term_days,
      invoice_received_date,
      invoice_date,
      payment_due_date,
      days_past_due
    ]
  }
}
