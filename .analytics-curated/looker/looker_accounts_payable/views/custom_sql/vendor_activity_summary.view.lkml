view: vendor_activity_summary {
  derived_table: {
    sql: SELECT
          V.VENDORID AS "Vendor ID",
          V.NAME AS "Vendor Name",
          V.COMPANY_LEGAL_NAME AS "Legal Name",
          V.VENDTYPE AS "Vendor Type",
          V.VENDOR_CATEGORY AS "Vendor Category",
          V.TERMNAME AS "Terms",
          V.PAYMETHODKEY AS "Pay Method",
          APB.TOTALDUE AS "Total Due",
          V.STATUS AS "Vendor Status",
          CASE WHEN CAST(V.ONETIME AS BOOLEAN) THEN 'Yes' ELSE 'No' END AS "One Time",
          COALESCE(CONTACT.MAILADDRESS_CITY, V.PAYTO_MAILADDRESS_CITY) AS "City",
          COALESCE(CONTACT.MAILADDRESS_STATE, V.PAYTO_MAILADDRESS_STATE) AS "State",
          CAST(V.WHENCREATED AS DATE) AS "Vendor Created",
          CAST(APBB.WHENCREATED AS DATE) AS "Last Billed",
          CAST(PO.WHENCREATED AS DATE) AS "Last PO",
          CAST(APP.WHENPAID AS DATE) AS "Last Payment",
          CASE --THIS GETS THE MAX DATE OF THE FOUR DATE FIELDS. THIS WAS ADDED IN AFTERWARDS
              WHEN CAST(V.WHENCREATED AS DATE) >= ifnull(CAST(APBB.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) AND CAST(V.WHENCREATED AS DATE) >= ifnull(CAST(PO.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) AND CAST(V.WHENCREATED AS DATE) >= ifnull(CAST(APP.WHENPAID AS DATE),CAST(V.WHENCREATED AS DATE)) THEN CAST(V.WHENCREATED AS DATE)
              WHEN ifnull(CAST(APBB.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) >= CAST(V.WHENCREATED AS DATE) AND ifnull(CAST(APBB.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) >= ifnull(CAST(PO.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) AND ifnull(CAST(APBB.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) >= ifnull(CAST(APP.WHENPAID AS DATE),CAST(V.WHENCREATED AS DATE)) THEN ifnull(CAST(APBB.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE))
              WHEN ifnull(CAST(PO.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) >= CAST(V.WHENCREATED AS DATE) AND ifnull(CAST(PO.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) >= ifnull(CAST(APBB.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) AND ifnull(CAST(PO.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) >= ifnull(CAST(APP.WHENPAID AS DATE),CAST(V.WHENCREATED AS DATE)) THEN ifnull(CAST(PO.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE))
              WHEN ifnull(CAST(APP.WHENPAID AS DATE),CAST(V.WHENCREATED AS DATE)) >= CAST(V.WHENCREATED AS DATE) AND ifnull(CAST(APP.WHENPAID AS DATE),CAST(V.WHENCREATED AS DATE)) >= ifnull(CAST(APBB.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) AND ifnull(CAST(APP.WHENPAID AS DATE),CAST(V.WHENCREATED AS DATE)) >= ifnull(CAST(PO.WHENCREATED AS DATE),CAST(V.WHENCREATED AS DATE)) THEN ifnull(CAST(APP.WHENPAID AS DATE),CAST(V.WHENCREATED AS DATE))
              ELSE CAST(V.WHENCREATED AS DATE)
          END AS "Last Activity"
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
          LEFT JOIN (select vendorid, max(whencreated) whencreated from "ANALYTICS"."SAGE_INTACCT"."AP_BILL" group by vendorid) AS APBB
          ON V.VENDORID = APBB.VENDORID
          LEFT JOIN "ANALYTICS"."SAGE_INTACCT"."CONTACT" CONTACT ON V.DISPLAYCONTACTKEY = CONTACT.RECORDNO
      GROUP BY
          V.VENDORID,
          V.NAME,
          V.COMPANY_LEGAL_NAME,
          V.VENDTYPE,
          V.VENDOR_CATEGORY,
          V.TERMNAME,
          V.PAYMETHODKEY,
          APB.TOTALDUE,
          V.STATUS,
          CASE WHEN CAST(V.ONETIME AS BOOLEAN) THEN 'Yes' ELSE 'No' END,
          COALESCE(CONTACT.MAILADDRESS_CITY, V.PAYTO_MAILADDRESS_CITY),
          COALESCE(CONTACT.MAILADDRESS_STATE, V.PAYTO_MAILADDRESS_STATE),
          V.WHENCREATED,
          PO.WHENCREATED,
          APBB.WHENCREATED,
          APP.WHENPAID
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

  dimension: legal_name {
    type: string
    label: "Legal Name"
    sql: ${TABLE}."Legal Name" ;;
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

  dimension: terms {
    type: string
    label: "Terms"
    sql: ${TABLE}."Terms" ;;
  }

  dimension: pay_method {
    type: string
    label: "Pay Method"
    sql: ${TABLE}."Pay Method" ;;
  }

  dimension: total_due {
    type: number
    value_format: "#,##0.00;(#,##0.00);-"
    label: "Total Due"
    sql: Coalesce(${TABLE}."Total Due",0) ;;
  }

  dimension: vendor_status {
    type: string
    label: "Vendor Status"
    sql: ${TABLE}."Vendor Status" ;;
  }

  dimension: one_time{
    type: string
    label: "One Time"
    sql: ${TABLE}."One Time" ;;
  }

  dimension: city {
    type: string
    label: "City"
    sql: ${TABLE}."City" ;;
  }

  dimension: state {
    type: string
    label: "State"
    sql: ${TABLE}."State" ;;
  }

  dimension: vendor_created {
    convert_tz:  no
    type: date
    label: "Vendor Created"
    sql: ${TABLE}."Vendor Created" ;;
  }

  dimension: last_billed {
    convert_tz:  no
    type: date
    label: "Last Billed"
    sql: ${TABLE}."Last Billed" ;;
  }

  dimension: last_po {
    convert_tz:  no
    type: date
    label: "Last PO"
    sql: ${TABLE}."Last PO" ;;
  }

  dimension: last_payment {
    convert_tz:  no
    type: date
    label: "Last Payment"
    sql: ${TABLE}."Last Payment" ;;
  }

  dimension: last_activity {
    convert_tz:  no
    type: date
    label: "Last Activity"
    sql: ${TABLE}."Last Activity" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      legal_name,
      vendor_type,
      vendor_category,
      terms,
      pay_method,
      total_due,
      vendor_status,
      one_time,
      city,
      state,
      vendor_created,
      last_billed,
      last_po,
      last_payment,
      last_activity
    ]
  }
}
