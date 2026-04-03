view: invoices_awaiting_approval_action_items {
  derived_table: {
    sql: SELECT DISTINCT
          PBA.COST_OBJECT_APPROVER  AS APPROVER_NAME,
          PBA.EMPLOYEE_ID           AS APPROVER_EMAIL,
          PBA.LATEST_SUBMIT_DATE    AS LAST_SUBMITTED,
          PBA.DAYS_PENDING_APPROVAL AS DAYS_PENDING,
          PBA.VENDOR_ID             AS VENDOR_ID,
          VEND.NAME                 AS VENDOR_NAME,
          PBA.INVOICE_NUMBER,
          PBA.BRANCH_ID             AS BRANCH_ID,
          XW.MARKET_NAME,
          XW.DISTRICT,
          XW.REGION_NAME,
          DEPT.TITLE                AS BRANCH_NAME,
          PBA.REQUEST_TOTAL         AS INVOICE_TOTAL,
          PBA._ES_UPDATE_TIMESTAMP  AS ES_UPDATE_TIMESTAMP
      FROM
          ANALYTICS.CONCUR.PENDING_BRANCH_APPROVAL PBA
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON PBA.VENDOR_ID = VEND.VENDORID
              LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON PBA.BRANCH_ID = DEPT.DEPARTMENTID
              JOIN ANALYTICS.PUBLIC.MARKET_REGION_XWALK XW ON try_to_number(PBA.BRANCH_ID) = XW.MARKET_ID
      WHERE PBA._ES_UPDATE_TIMESTAMP >= DATEADD(HOUR, -24, CURRENT_TIMESTAMP)
       ;;
  }

#Custom SQL as received from Joshua Bromer 2022-11-17 PB
#Updated to add timestamp, was just notified there is historical in the PBA table 2022-12-05 PB
#This updates every 24 Hours per old market dashboard - 5/1/2024 KC

  measure: count {
    type: count
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
    html: {{ rendered_value | date: "%b %d, %Y" }};;
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

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: region {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: invoice_total {
    type: number
    sql: ${TABLE}."INVOICE_TOTAL" ;;
    value_format_name: usd
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
}
