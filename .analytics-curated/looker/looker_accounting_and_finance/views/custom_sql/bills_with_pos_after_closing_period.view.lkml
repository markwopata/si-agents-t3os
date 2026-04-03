view: bills_with_pos_after_closing_period {
  derived_table: {
    sql: SELECT APH.VENDORID                                                                                 AS VENDOR_ID,
       VEND.NAME                                                                                    AS VENDOR_NAME,
       APH.RECORDID                                                                                 AS BILL_NUMBER,
       AP_URL.RECORD_URL                                                                            AS BILL_SAGE_URL,
       APH.WHENCREATED                                                                              AS BILL_DATE,
       APH.WHENPOSTED                                                                               AS BILL_POST_DATE,
       APH.WHENDUE                                                                                  AS DUE_DATE,
       CASE WHEN APH.DOCNUMBER = 'nan' THEN NULL ELSE APH.DOCNUMBER END                             AS PO_OR_REFERENCE,
       APH.STATE                                                                                    AS STATE,
       APH.DESCRIPTION                                                                              AS HEADER_DESCRIPTION,
       CASE WHEN LEFT(APH.YOOZ_URL, 23) = 'https://www2.justyoozit' THEN NULL ELSE APH.YOOZ_URL END AS URL,
       APD.ITEMID                                                                                   AS BILL_ITEM_ID,
       APD.ACCOUNTNO                                                                                AS BILL_ACCT,
       APD.DEPARTMENTID                                                                             AS BILL_DEPT_ID,
       APD.LOCATIONID                                                                               AS BILL_ENTITY,
       APD.ENTRYDESCRIPTION                                                                         AS BILL_LINE_DESC,
       BILL_EL.NAME                                                                                 AS BILL_EXP_LINE,
       APD.AMOUNT                                                                                   AS BILL_AMT,
       POH.PONUMBER                                                                                 AS PO_NUMBER,
       PO_URL.RECORD_URL                                                                            AS PO_SAGE_URL,
       POH.WHENCREATED                                                                              AS PO_POST_DATE,
       POL.ITEMID                                                                                   AS PO_ITEM_ID,
       SUBSTR(COALESCE(OTN.NEW_ITEM_ID, POL.ITEMID), 2, 4)                                          AS PO_ACCT,
       POL.DEPARTMENTID                                                                             AS PO_DEPT_ID,
       POL.LOCATIONID                                                                               AS PO_ENTITY,
       POL.MEMO                                                                                     AS PO_LINE_DESC,
       PO_EL.NAME                                                                                   AS PO_EXP_LINE,
       POL.TOTAL                                                                                    AS PO_AMT

FROM ANALYTICS.INTACCT.APRECORD APH
         LEFT JOIN ANALYTICS.INTACCT.APDETAIL APD ON APH.RECORDNO = APD.RECORDKEY
         LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT VIH ON APH.DESCRIPTION2 = VIH.DOCID AND VIH.DOCPARID = 'Vendor Invoice'
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY VIL ON VIH.DOCID = VIL.DOCHDRID AND APD.LINE_NO - 1 = VIL.LINE_NO
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT POH ON VIL.SOURCE_DOCID = POH.DOCID AND POH.DOCPARID = 'Purchase Order'
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL ON VIL.SOURCE_DOCLINEKEY = POL.RECORDNO
         LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM OTN ON POL.ITEMID = OTN.OG_ITEM_ID
         LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE BILL_EL ON APD.GLDIMEXPENSE_LINE = BILL_EL.ID
         LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE PO_EL ON POL.GLDIMEXPENSE_LINE = PO_EL.ID
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL_VIEW PO_URL
                   ON POH.RECORDNO = PO_URL.RECORDNO AND PO_URL.INTACCT_OBJECT = 'PODOCUMENT'
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL_VIEW AP_URL
                   ON APH.RECORDNO = AP_URL.RECORDNO AND AP_URL.INTACCT_OBJECT = 'APBILL'
WHERE 1 = 1
  AND APH.WHENPOSTED <= LAST_DAY(CURRENT_DATE, MONTH)
  AND APH.WHENPOSTED >= '2023-10-16'
  AND APH.RECORDTYPE = 'apbill'
  AND POH.DOCNO IS NOT NULL
  --AND POH.WHENCREATED <= '2024-12-31' -- removed 2.12.25, hard coded end date
  AND POH.WHENCREATED > LAST_DAY(APH.WHENPOSTED, MONTH)
ORDER BY APH.WHENPOSTED DESC ;;
  }

  dimension: vendor_id {
    type: string
    label: "Vendor ID"
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    label: "Vendor Name"
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: bill_number {
    type: string
    label: "Bill Number"
    sql: ${TABLE}."BILL_NUMBER" ;;
    html: <a href="{{bill_sage_url._value}}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: bill_sage_url {
    type: string
    label: "Bill Sage URL"
    sql: ${TABLE}."BILL_SAGE_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension_group: bill_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    label: "Bill Date"
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension_group: bill_post_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    label: "Bill Post Date"
    sql: ${TABLE}."BILL_POST_DATE" ;;
  }

  dimension_group: due_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    label: "Due Date"
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: po_or_reference {
    type: string
    label: "PO OR Reference"
    sql: ${TABLE}."PO_OR_REFERENCE" ;;
  }

  dimension: state {
    type: string
    label: "State"
    sql: ${TABLE}."STATE" ;;
  }

  dimension: header_description {
    type: string
    label: "Header Description"
    sql: ${TABLE}."HEADER_DESCRIPTION" ;;
  }

  dimension: file_url {
    type: string
    label: "File URL"
    sql: ${TABLE}."URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: bill_item_id {
    type: string
    label: "Bill Item ID"
    sql: ${TABLE}."BILL_ITEM_ID" ;;
  }

  dimension: bill_acct {
    type: string
    label: "Bill Account Number"
    sql: ${TABLE}."BILL_ACCT" ;;
  }

  dimension: bill_dept_id {
    type: string
    label: "Bill Dept ID"
    sql: ${TABLE}."BILL_DEPT_ID" ;;
  }

  dimension: bill_entity {
    type: string
    label: "Bill Entity"
    sql: ${TABLE}."BILL_ENTITY" ;;
  }

  dimension: bill_line_desc {
    type: string
    label: "Bill Line Desc"
    sql: ${TABLE}."BILL_LINE_DESC" ;;
  }

  dimension: bill_exp_line {
    type: string
    label: "Bill Expense Line"
    sql: ${TABLE}."BILL_EXP_LINE" ;;
  }

  dimension: bill_amt {
    type: number
    label: "Bill Amount"
    sql: ${TABLE}."BILL_AMT" ;;
  }

  dimension: po_number {
    type: string
    label: "PO Number"
    sql: ${TABLE}."PO_NUMBER" ;;
    html: <a href="{{po_sage_url._value}}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: po_sage_url {
    type: string
    label: "PO Sage URL"
    sql: ${TABLE}."PO_SAGE_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension_group: po_post_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    label: "PO Post Date"
    sql: ${TABLE}."PO_POST_DATE" ;;
  }

  dimension: po_item_id {
    type: string
    label: "PO Item ID"
    sql: ${TABLE}."PO_ITEM_ID" ;;
  }

  dimension: po_acct {
    type: string
    label: "PO Account Number"
    sql: ${TABLE}."PO_ACCT" ;;
  }

  dimension: po_dept_id {
    type: string
    label: "PO Dept ID"
    sql: ${TABLE}."PO_DEPT_ID" ;;
  }

  dimension: po_entity {
    type: string
    label: "PO Entity"
    sql: ${TABLE}."PO_ENTITY" ;;
  }

  dimension: po_line_desc {
    type: string
    label: "PO Line Desc"
    sql: ${TABLE}."PO_LINE_DESC" ;;
  }

  dimension: po_exp_line {
    type: string
    label: "PO Expense Line"
    sql: ${TABLE}."PO_EXP_LINE" ;;
  }

  dimension: po_amt {
    type: number
    label: "PO Amount"
    sql: ${TABLE}."PO_AMT" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      bill_number,
      bill_sage_url,
      bill_date_date,
      bill_post_date_date,
      due_date_date,
      po_or_reference,
      state,
      header_description,
      file_url,
      bill_item_id,
      bill_acct,
      bill_dept_id,
      bill_entity,
      bill_line_desc,
      bill_exp_line,
      bill_amt,
      po_number,
      po_sage_url,
      po_post_date_date,
      po_item_id,
      po_acct,
      po_dept_id,
      po_entity,
      po_line_desc,
      po_exp_line,
      po_amt
    ]
  }
}
