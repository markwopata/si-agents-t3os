view: intacct_dup_apa_apj_v2 {
  derived_table: {
    sql: WITH conv AS (SELECT PD.RECORDNO                                  AS HEADER_RECORDNO,
                     SUM(PDE.UIQTY - COALESCE(
                             VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0)) AS REMAINING_QUANTITY
              FROM ANALYTICS.INTACCT.PODOCUMENT PD
                       LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY PDE
                                 ON PD.DOCID = PDE.DOCHDRID
                                     AND PD.DOCPARID = 'Purchase Order'
                       LEFT JOIN (SELECT VI_CPO.CREATEDFROM        AS SOURCE_PO_DOCID,
                                         VI_CPOD.SOURCE_DOCLINEKEY AS SOURCE_PO_LINE_RECORDNO,
                                         SUM(VI_CPOD.UIQTY)        AS CONVERTED_QTY
                                  FROM ANALYTICS.INTACCT.PODOCUMENT VI_CPO
                                           LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY VI_CPOD
                                                     ON VI_CPOD.DOCHDRID = VI_CPO.DOCID
                                  WHERE VI_CPO.DOCPARID IN
                                        ('Vendor Invoice', 'Closed Purchase Order', 'Closed PO Non Posting')
                                    AND VI_CPO.CREATEDFROM IS NOT NULL
                                    AND VI_CPOD.SOURCE_DOCLINEKEY IS NOT NULL
                                  GROUP BY VI_CPO.CREATEDFROM,
                                           VI_CPOD.SOURCE_DOCLINEKEY) VI_OR_PO_QTY_CONV
                                 ON PD.DOCID = VI_OR_PO_QTY_CONV.SOURCE_PO_DOCID AND
                                    PDE.RECORDNO =
                                    VI_OR_PO_QTY_CONV.SOURCE_PO_LINE_RECORDNO
              WHERE PD.DOCPARID = 'Purchase Order'
              GROUP BY HEADER_RECORDNO
              HAVING REMAINING_QUANTITY > 0)
SELECT b.RECORDID                                                 AS BILL_NUMBER,
       r1.RECORD_URL                                              AS BILL_URL_SAGE,
       b.TOTALENTERED                                             AS BILL_AMOUNT,
       COALESCE(CAST(b.AUWHENCREATED AS DATE), b.WHENCREATED)     AS BILL_WHENCREATED,
       b.WHENPOSTED                                               AS BILL_POSTDATE,
       b.DOCNUMBER                                                AS BILL_PONUMBER,
       b.VENDORID                                                 AS BILL_VENDORID,
       b.VENDORNAME                                               AS BILL_VENDORNAME,
       u1.LOGINID                                                 AS BILL_USERID,
       por.DOCNO                                                  AS APA_POR_NUMBER,
       r2.RECORD_URL                                              AS APA_URL_SAGE,
       por.TOTAL                                                  AS APA_POR_TOTAL,
       COALESCE(CAST(por.AUWHENCREATED AS DATE), por.WHENCREATED) AS APA_POR_WHENCREATED,
       por.WHENPOSTED                                             AS APA_POR_POSTDATE,
       por.CUSTVENDID                                             AS APA_POR_VENDORID,
       por.CUSTVENDNAME                                           AS APA_POR_VENDOR,
       u2.LOGINID                                                 AS APA_POR_USERID,
       por.BLANKET_PO                                             AS APA_POR_BLANKET,
       conv.REMAINING_QUANTITY,
       por.STATE                                                  AS APA_POR_STATE
FROM ANALYTICS.INTACCT.APRECORD b
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT por
                   ON b.DOCNUMBER = por.DOCNO
                       AND por.DOCPARID = 'Purchase Order'
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL r1
                   ON b.RECORDNO = r1.RECORDNO AND r1.INTACCT_OBJECT = 'APBILL'
         LEFT JOIN ANALYTICS.INTACCT.USERINFO u1 ON b.CREATEDBY = u1.RECORDNO
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL r2
                   ON por.RECORDNO = r2.RECORDNO AND r2.INTACCT_OBJECT = 'PODOCUMENT'
         LEFT JOIN ANALYTICS.INTACCT.USERINFO u2 ON por.CREATEDBY = u2.RECORDNO
         LEFT JOIN conv ON por.RECORDNO = conv.HEADER_RECORDNO
WHERE REMAINING_QUANTITY > 0
  AND COALESCE(CAST(por.AUWHENCREATED AS DATE), por.WHENCREATED) >= '10/16/2023'
--   AND por.DOCNO = 'E106229'
ORDER BY BILL_NUMBER ;;
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

  dimension: bill_whencreated {
    type: date
    label: "Bill When Created"
    sql: ${TABLE}."BILL_WHENCREATED" ;;
  }

  dimension: bill_postdate {
    type: date
    label: "Bill Post Date"
    sql: ${TABLE}."BILL_POSTDATE" ;;
  }

  dimension: bill_ponumber {
    type: string
    label: "Bill PO Number"
    sql: ${TABLE}."BILL_PONUMBER" ;;
  }

  dimension: bill_vendorid {
    type: string
    label: "Bill Vendor ID"
    sql: ${TABLE}."BILL_VENDORID" ;;
  }

  dimension: bill_vendorname {
    type: string
    label: "Bill Vendor Name"
    sql: ${TABLE}."BILL_VENDORNAME" ;;
  }

  dimension: bill_userid {
    type: string
    label: "Bill User ID"
    sql: ${TABLE}."BILL_USERID" ;;
  }

  dimension: apa_por_number {
    type: string
    label: "APA POR Number"
    sql: ${TABLE}."APA_POR_NUMBER" ;;
    html: <a href="{{ apa_url_sage._value }}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: apa_url_sage {
    type: string
    sql: ${TABLE}."APA_URL_SAGE" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: apa_por_total {
    type: number
    label: "APA POR Total"
    sql: ${TABLE}."APA_POR_TOTAL" ;;
  }

  dimension: apa_por_whencreated {
    type: date
    label: "APA POR When Created"
    sql: ${TABLE}."APA_POR_WHENCREATED" ;;
  }

  dimension: apa_por_postdate {
    type: date
    label: "APA POR Post Date"
    sql: ${TABLE}."APA_POR_POSTDATE" ;;
  }

  dimension: apa_por_vendorid {
    type: string
    label: "APA POR Vendor ID"
    sql: ${TABLE}."APA_POR_VENDORID" ;;
  }

  dimension: apa_por_vendor {
    type: string
    label: "APA POR Vendor"
    sql: ${TABLE}."APA_POR_VENDOR" ;;
  }

  dimension: apa_por_userid {
    type: string
    label: "APA POR User ID"
    sql: ${TABLE}."APA_POR_USERID" ;;
  }

  dimension: apa_por_blanket {
    type: yesno
    label: "APA Blanket PO Flag"
    sql: ${TABLE}."APA_POR_BLANKET" ;;
  }

  dimension: remaining_quantity {
    type: number
    label: "Remaining Quantity"
    sql: ${TABLE}."REMAINING_QUANTITY" ;;
  }

  dimension: apa_por_state {
    type: string
    label: "APA POR State"
    sql: ${TABLE}."APA_POR_STATE" ;;
  }

  set: detail {
    fields: [
      bill_number,
      bill_url_sage,
      bill_amount,
      bill_whencreated,
      bill_postdate,
      bill_ponumber,
      bill_vendorid,
      bill_vendorname,
      bill_userid,
      apa_por_number,
      apa_url_sage,
      apa_por_total,
      apa_por_whencreated,
      apa_por_postdate,
      apa_por_vendorid,
      apa_por_vendor,
      apa_por_userid,
      apa_por_blanket,
      remaining_quantity,
      apa_por_state
    ]
  }
}
