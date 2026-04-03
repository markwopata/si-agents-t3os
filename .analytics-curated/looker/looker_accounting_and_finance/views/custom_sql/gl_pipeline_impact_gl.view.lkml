view: gl_pipeline_impact_gl {
  derived_table: {
    sql: SELECT glb.BATCHNO,
       url.RECORD_URL,
       glb.JOURNAL,
       glb.BATCH_TITLE,
       glb.BATCH_DATE,
       glb.STATE,
       gle.ACCOUNTNO                                               AS ACCOUNT,
       d.DEPARTMENTID                                              AS LOCATION_CODE,
       d.TITLE                                                     AS LOCATION_NAME,
       d.DEPARTMENT_TYPE,
       ex.NAME                                                     AS EXPENSE_LINE,
       (TRX_AMOUNT * TR_TYPE)                                      AS AMOUNT,
       ROUND(CASE WHEN TR_TYPE = 1 THEN TRX_AMOUNT ELSE 0 END, 2)  AS DEBIT,
       ROUND(CASE WHEN TR_TYPE = -1 THEN TRX_AMOUNT ELSE 0 END, 2) AS CREDIT
FROM ANALYTICS.INTACCT.GLBATCH glb
         LEFT JOIN ANALYTICS.INTACCT.GLENTRY gle ON glb.RECORDNO = gle.BATCHNO
         LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE ex ON gle.GLDIMEXPENSE_LINE = ex.ID
         LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT d ON gle.DEPARTMENTKEY = d.RECORDNO
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL url ON glb.RECORDNO = url.RECORDNO AND url.INTACCT_OBJECT = 'GLBATCH'
WHERE glb.STATE NOT IN ('Posted', 'Declined') ;;
  }

  dimension: batch_no {
    type: string
    label: "Batch Number"
    sql: ${TABLE}."BATCHNO" ;;
    html: <a href="{{ record_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: record_url {
    type: string
    label: "Record URL"
    sql: ${TABLE}."RECORD_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: journal {
    type: string
    label: "Journal"
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: batch_title {
    type: string
    label: "Batch Title"
    sql: ${TABLE}."BATCH_TITLE" ;;
  }

  dimension_group: batch_date {
    type: time
    sql: ${TABLE}."Batch Date" ;;
    timeframes: [date, week, month, quarter, year]
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

  dimension: expense_line {
    type: string
    label: "Expense Line"
    sql: ${TABLE}."EXPENSE_LINE" ;;
  }

  dimension: amount {
    type: number
    label: "Amount"
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: debit {
    type: number
    label: "Debit"
    sql: ${TABLE}."DEBIT" ;;
  }

  dimension: credit {
    type: number
    label: "Credit"
    sql: ${TABLE}."CREDIT" ;;
  }

  dimension: department_type {
    type: string
    label: "Department Type"
    sql: ${TABLE}."DEPARTMENT_TYPE" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      batch_no,
      record_url,
      journal,
      batch_title,
      batch_date_date,
      state,
      account,
      location_code,
      location_name,
      department_type,
      expense_line,
      amount,
      debit,
      credit
    ]
  }
}
