view: accounts_payable_vendor_activity {
  derived_table: {
    sql: SELECT
          V.VENDORID AS "Vendor ID",
          V.NAME AS "Vendor Name",
          V.VENDTYPE AS "Vendor Type",
          V.VENDOR_CATEGORY AS "Vendor Category",
          TO_VARCHAR(APB.TOTALDUE, '9,999,990.00') AS "Total Due",
          V.STATUS AS "Vendor Status",
          V.WHENCREATED AS "Vendor Created",
          PO.WHENCREATED AS "Last PO",
          APP.WHENPAID AS "Last Paid"
      FROM
          "ANALYTICS"."SAGE_INTACCT"."VENDOR" V
          LEFT JOIN (select
                         custvendid,
                         max(whencreated) whencreated
                     from "ANALYTICS"."SAGE_INTACCT"."PO_DOCUMENT"
                     group by custvendid) AS PO
          ON V.VENDORID = PO.CUSTVENDID
          LEFT JOIN (select vendorid, sum(totaldue) totaldue from "ANALYTICS"."SAGE_INTACCT"."AP_BILL" group by vendorid) AS APB
          ON V.VENDORID = APB.VENDORID
          LEFT JOIN (select vendorid, max(whenpaid) whenpaid from "ANALYTICS"."SAGE_INTACCT"."AP_PAYMENT" group by vendorid) AS APP
          ON V.VENDORID = APP.VENDORID
      WHERE
          v.status = 'active'
      GROUP BY
          V.VENDORID, V.NAME, V.VENDTYPE, V.VENDOR_CATEGORY, TO_VARCHAR(APB.TOTALDUE, '9,999,990.00'), V.STATUS,
          V.WHENCREATED, PO.WHENCREATED, APP.WHENPAID
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    label: "Vendor ID"
    sql: ${TABLE}."Vendor ID" ;;
  }

  dimension: vendor_name {
    type: string
    label: "Vendor Name"
    sql: ${TABLE}."Vendor Name" ;;
  }

  dimension: vendor_type {
    type: string
    label: "Vendor Type"
    sql: ${TABLE}."Vendor Type" ;;
  }

  dimension: vendor_category {
    type: string
    label: "Vendor Category"
    sql: ${TABLE}."Vendor Category" ;;
  }

  dimension: total_due {
    type: string
    label: "Total Due"
    sql: ${TABLE}."Total Due" ;;
  }

  dimension: vendor_status {
    type: string
    label: "Vendor Status"
    sql: ${TABLE}."Vendor Status" ;;
  }

  dimension: vendor_created {
    type: string
    label: "Vendor Created"
    sql: ${TABLE}."Vendor Created" ;;
  }

  dimension: last_po {
    type: string
    label: "Last PO"
    sql: ${TABLE}."Last PO" ;;
  }

  dimension: last_paid {
    type: date
    label: "Last Paid"
    sql: ${TABLE}."Last Paid" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor_type,
      vendor_category,
      total_due,
      vendor_status,
      vendor_created,
      last_po,
      last_paid
    ]
  }
}
