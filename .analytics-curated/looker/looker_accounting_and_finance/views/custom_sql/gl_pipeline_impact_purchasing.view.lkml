view: gl_pipeline_impact_purchasing {
  derived_table: {
    sql: SELECT poh.DOCNO,
       url.RECORD_URL,
       poh.WHENCREATED,
       poh.DOCPARID,
       poh.STATE,
--        pol.ITEMID,
       TRY_CAST(SUBSTRING(pol.ITEMID, 2) AS INT) AS ACCOUNT,
       pol.DEPARTMENTID                          AS LOCATION_CODE,
       d.TITLE                                   AS LOCATION_NAME,
       d.DEPARTMENT_TYPE,
       ex.NAME                                   AS EXPENSE_LINE,
       pol.TOTAL
FROM ANALYTICS.INTACCT.PODOCUMENT poh
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY pol ON pol.DOCHDRID = poh.DOCID
         LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE ex ON pol.GLDIMEXPENSE_LINE = ex.ID
         LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT d ON pol.DEPARTMENTID = d.DEPARTMENTID
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL url ON poh.RECORDNO = url.RECORDNO AND url.INTACCT_OBJECT = 'PODOCUMENT'
WHERE poh.DOCPARID IN ('Purchase Order', 'Purchase Order Entry', 'Closed Purchase Order', 'Vendor Invoice')
  AND poh.STATE NOT IN ('Closed', 'Converted') ;;
  }

  dimension: doc_no {
    type: string
    label: "Document Number"
    sql: ${TABLE}."DOCNO" ;;
    html: <a href="{{ record_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: record_url {
    type: string
    label: "Record URL"
    sql: ${TABLE}."RECORD_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension_group: created {
    type: time
    sql: ${TABLE}."WHENCREATED" ;;
    timeframes: [date, week, month, quarter, year]
  }

  dimension: record_type {
    type: string
    label: "Record Type"
    sql: ${TABLE}."DOCPARID" ;;
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
    sql: ${TABLE}."TOTAL" ;;
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
      doc_no,
      record_url,
      created_date,
      record_type,
      state,
      account,
      location_code,
      location_name,
      department_type,
      expense_line,
      amount
    ]
  }
}
