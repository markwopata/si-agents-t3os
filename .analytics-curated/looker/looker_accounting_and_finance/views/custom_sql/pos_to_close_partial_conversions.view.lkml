view: pos_to_close_partial_conversions {
  derived_table: {
    sql: WITH t1 AS (SELECT b.RECORDID                                             AS BILL_NUMBER,
                   r1.RECORD_URL                                          AS BILL_URL_SAGE,
                   b.TOTALENTERED                                         AS BILL_AMOUNT,
                   COALESCE(CAST(b.AUWHENCREATED AS DATE), b.WHENCREATED) AS BILL_WHENCREATED,
                   b.DOCNUMBER                                            AS BILL_PONUMBER,
                   b.VENDORID                                             AS BILL_VENDORID,
                   b.VENDORNAME                                           AS BILL_VENDORNAME,
                   u1.LOGINID                                             AS BILL_USERID,
                   p.DOCNO                                                AS APA_POR_NUMBER,
                   r2.RECORD_URL                                          AS APA_URL_SAGE,
                   p.TOTAL                                                AS APA_POR_TOTAL,
                   COALESCE(CAST(p.AUWHENCREATED AS DATE), p.WHENCREATED) AS APA_POR_WHENCREATED,
                   p.CUSTVENDID                                           AS APA_POR_VENDORID,
                   p.CUSTVENDNAME                                         AS APA_POR_VENDOR,
                   u2.LOGINID                                             AS APA_POR_USERID,
                   p.BLANKET_PO                                           AS APA_POR_BLANKET,
                   p.STATE                                                AS APA_POR_STATE,
                   SUM(b.TOTALENTERED) OVER (PARTITION BY p.DOCNO)        AS SUM_OF_BILLS
            FROM ANALYTICS.INTACCT.APRECORD b
                     LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT p
                               ON b.DOCNUMBER = p.DOCNO
                                   AND p.DOCPARID = 'Purchase Order'
                     LEFT JOIN ANALYTICS.INTACCT.RECORD_URL r1
                               ON b.RECORDNO = r1.RECORDNO AND r1.INTACCT_OBJECT = 'APBILL'
                     LEFT JOIN ANALYTICS.INTACCT.USERINFO u1 ON b.CREATEDBY = u1.RECORDNO
                     LEFT JOIN ANALYTICS.INTACCT.RECORD_URL r2
                               ON p.RECORDNO = r2.RECORDNO AND r2.INTACCT_OBJECT = 'PODOCUMENT'
                     LEFT JOIN ANALYTICS.INTACCT.USERINFO u2 ON p.CREATEDBY = u2.RECORDNO
            WHERE p.STATE IN ('Partially Converted')
              AND COALESCE(CAST(p.AUWHENCREATED AS DATE), p.WHENCREATED) >= '10/16/2023'
--   AND p.DOCNO = '829095'
            ORDER BY APA_POR_NUMBER)
SELECT *
FROM t1
WHERE SUM_OF_BILLS >= APA_POR_TOTAL
ORDER BY APA_POR_NUMBER ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: bill_number {
    type: string
    label: "Bill Number"
    sql: ${TABLE}."BILL_NUMBER" ;;
    html: <a href="{{bill_url_sage._value}}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: bill_url_sage {
    type: string
    label: "Bill URL Sage"
    sql: ${TABLE}."BILL_URL_SAGE" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: bill_amount {
    type: number
    label: "Bill Amount"
    sql: ${TABLE}."BILL_AMOUNT" ;;
  }

  dimension: bill_created {
    type: date
    label: "Bill Created Date"
    sql: ${TABLE}."BILL_WHENCREATED";;
  }

  dimension_group: bill_created_group {
    type: time
    label: "Bill Created"
    sql: ${TABLE}."BILL_WHENCREATED" ;;
  }

  dimension: bill_po_number {
    type: string
    label: "Bill PO Number"
    sql: ${TABLE}."BILL_PONUMBER" ;;
  }

  dimension: bill_vendor_id {
    type: string
    label: "Bill Vendor ID"
    sql: ${TABLE}."BILL_VENDORID" ;;
  }

  dimension: bill_vendor_name {
    type: string
    label: "Bill Vendor Name"
    sql: ${TABLE}."BILL_VENDORNAME" ;;
  }

  dimension: bill_user_id {
    type: string
    label: "Bill User ID"
    sql: ${TABLE}."BILL_USERID" ;;
  }

  dimension: apa_por_number {
    type: string
    label: "APA POR Number"
    sql: ${TABLE}."APA_POR_NUMBER" ;;
    html: <a href="{{apa_url_sage._value}}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: apa_url_sage {
    type: string
    label: "APA URL Sage"
    sql: ${TABLE}."APA_URL_SAGE" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: apa_por_total {
    type: number
    label: "APA POR Total"
    sql: ${TABLE}."APA_POR_TOTAL" ;;
  }

  dimension: apa_por_created {
    type: date
    label: "APA POR Created Date"
    sql: ${TABLE}."APA_POR_WHENCREATED" ;;
  }

  dimension_group: apa_por_created_group {
    type: time
    label: "APA POR Created"
    sql: ${TABLE}."APA_POR_WHENCREATED" ;;
  }

  dimension: apa_por_vendor_id {
    type: string
    label: "APA POR Vendor ID"
    sql: ${TABLE}."APA_POR_VENDORID" ;;
  }

  dimension: apa_por_vendor_name {
    type: string
    label: "APA POR Vendor Name"
    sql: ${TABLE}."APA_POR_VENDOR" ;;
  }

  dimension: apa_por_user_id {
    type: string
    label: "APA POR User ID"
    sql: ${TABLE}."APA_POR_USERID" ;;
  }

  dimension: blanket_po {
    type: yesno
    label: "Blanket PO"
    sql: ${TABLE}."APA_POR_BLANKET" ;;
  }

  dimension: apa_por_state {
    type: string
    label: "APA POR State"
    sql: ${TABLE}."APA_POR_STATE" ;;
  }

  dimension: sum_of_bills {
    type: number
    label: "Sum of Bills"
    sql: ${TABLE}."SUM_OF_BILLS" ;;
  }

  set: detail {
    fields: [
      bill_number,
      bill_url_sage,
      bill_amount,
      bill_created,
      bill_po_number,
      bill_vendor_id,
      bill_vendor_name,
      bill_user_id,
      apa_por_number,
      apa_url_sage,
      apa_por_total,
      apa_por_created,
      apa_por_vendor_id,
      apa_por_vendor_name,
      apa_por_user_id,
      blanket_po,
      apa_por_state,
      sum_of_bills
    ]
  }

}
