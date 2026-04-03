view: gl_pipeline_impact_ap {
  derived_table: {
    sql: SELECT aph.RECORDID       AS BILL_NUMBER,
       url.RECORD_URL,
       aph.VENDORID,
       aph.VENDORNAME,
       aph.AUWHENCREATED  AS DATE_CREATED,
       aph.WHENCREATED    AS BILL_DATE,
       aph.DOCNUMBER      AS PO_REFERENCE,
       aph.STATE,
       apd.ACCOUNTNO      AS ACCOUNT,
       apd.DEPARTMENTID   AS LOCATION_CODE,
       apd.DEPARTMENTNAME AS LOCATION_NAME,
       d.DEPARTMENT_TYPE,
       ex.NAME            AS EXPENSE_LINE,
       apd.AMOUNT         AS LINE_AMOUNT,
       aph.TOTALENTERED   AS BILL_TOTAL
FROM ANALYTICS.INTACCT.APRECORD aph
         LEFT JOIN ANALYTICS.INTACCT.APDETAIL apd ON aph.RECORDNO = apd.RECORDKEY
         LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT d ON apd.DEPARTMENTID = d.DEPARTMENTID
         LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE ex ON apd.GLDIMEXPENSE_LINE = ex.ID
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL url ON aph.RECORDNO = url.RECORDNO AND url.INTACCT_OBJECT = 'APBILL'
WHERE aph.STATE = 'Draft'
  AND aph.RECORDTYPE = 'apbill' ;;
  }

  dimension: bill_number {
    type: string
    label: "Bill Number"
    sql: ${TABLE}."BILL_NUMBER" ;;
    html: <a href="{{ record_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: record_url {
    type: string
    label: "Record URL"
    sql: ${TABLE}."RECORD_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: vendor_id {
    type: string
    label: "Vendor ID"
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: vendor_name {
    type: string
    label: "Vendor Name"
    sql: ${TABLE}."VENDORNAME" ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
    timeframes: [date, week, month, quarter, year]
  }

  dimension_group: bill_date {
    type: time
    sql: ${TABLE}."BILL_DATE" ;;
    timeframes: [date, week, month, quarter, year]
  }

  dimension: po_reference {
    type: string
    label: "PO Reference"
    sql: ${TABLE}."PO_REFERENCE" ;;
  }

  dimension: state {
    type: string
    label: "State"
    sql: ${TABLE}."STATE" ;;
  }

  dimension: account {
    type: string
    label: "Account"
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: location_code {
    type: string
    label: "Location Code"
    sql: ${TABLE}."LOCATION_CODE" ;;
  }

  dimension: location_name {
    type: string
    label: "Location Name"
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: department_type {
    type: string
    label: "Department Type"
    sql: ${TABLE}."DEPARTMENT_TYPE" ;;
  }

  dimension: expense_line {
    type: string
    label: "Expense Line"
    sql: ${TABLE}."EXPENSE_LINE" ;;
  }

  dimension: line_amount {
    type: number
    label: "Line Amount"
    sql: ${TABLE}."LINE_AMOUNT" ;;
  }

  dimension: bill_total {
    type: number
    label: "Bill Total"
    sql: ${TABLE}."BILL_TOTAL" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      bill_number,
      record_url,
      vendor_id,
      vendor_name,
      created_date,
      bill_date_date,
      po_reference,
      state,
      account,
      location_code,
      location_name,
      department_type,
      expense_line,
      line_amount,
      bill_total
    ]
  }
}
