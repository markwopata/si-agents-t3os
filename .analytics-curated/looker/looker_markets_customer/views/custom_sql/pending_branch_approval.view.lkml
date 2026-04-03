view: pending_branch_approval {
  derived_table: {
    sql: SELECT DISTINCT
          PBA.COST_OBJECT_APPROVER  AS APPROVER_NAME,
          PBA.EMPLOYEE_ID           AS APPROVER_EMAIL,
          PBA.LATEST_SUBMIT_DATE    AS LAST_SUBMITTED,
          PBA.DAYS_PENDING_APPROVAL AS DAYS_PENDING,
          PBA.VENDOR_ID             AS VENDOR_ID,
          VEND.NAME                 AS VENDOR_NAME,
          PBA.INVOICE_NUMBER        AS BILL_NUMBER,
          PBA.BRANCH_ID             AS BRANCH_ID,
          DEPT.TITLE                AS BRANCH_NAME,
          PBA.REQUEST_TOTAL         AS INVOICE_TOTAL,
          PBA._ES_UPDATE_TIMESTAMP  AS ES_UPDATE_TIMESTAMP
      FROM
          ANALYTICS.CONCUR.PENDING_BRANCH_APPROVAL PBA
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON PBA.VENDOR_ID = VEND.VENDORID
              LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON PBA.BRANCH_ID = DEPT.DEPARTMENTID
      WHERE PBA._ES_UPDATE_TIMESTAMP >= DATEADD(HOUR, -22, CURRENT_TIMESTAMP)
      ORDER BY
          PBA.COST_OBJECT_APPROVER ASC,
          PBA.DAYS_PENDING_APPROVAL DESC,
          PBA.VENDOR_ID ASC,
          PBA.INVOICE_NUMBER ASC
       ;;
  }

#Custom SQL as received from Joshua Bromer 2022-11-17 PB
#Updated to add timestamp, was just notified there is historical in the PBA table 2022-12-05 PB

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: approver_name {
    type: string
    sql: ${TABLE}."APPROVER_NAME" ;;
  }

  dimension: approver_email {
    type: string
    sql: ${TABLE}."APPROVER_EMAIL" ;;
  }

  dimension: last_submitted {
    type: date
    sql: ${TABLE}."LAST_SUBMITTED" ;;
  }

  dimension: days_pending {
    type: number
    sql: ${TABLE}."DAYS_PENDING" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: invoice_total {
    type: number
    sql: ${TABLE}."INVOICE_TOTAL" ;;
  }

  dimension: es_update_timestamp {
    type: date
    sql: ${TABLE}."ES_UPDATE_TIMESTAMP" ;;
  }

  measure: documentation_link {
    type:  string
    sql:  'https://docs.google.com/document/d/194OUbuIYyUXjBfE8yaoeOVBB_mWi4sZuQbcXgtHh578' ;;
    html: <u><a href="{{value}}" target="_blank">SAP Reference Guide</a></u> ;;
  }

  set: detail {
    fields: [
      approver_name,
      approver_email,
      last_submitted,
      days_pending,
      vendor_id,
      vendor_name,
      bill_number,
      branch_id,
      branch_name,
      invoice_total
    ]
  }
}
