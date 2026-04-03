view: closed_pos_no_gl_entry {
  derived_table: {
    sql: SELECT po.RECORDNO,
       po.DOCNO,
       po.CREATEDFROM,
       po.TOTAL,
       po.WHENCREATED,
       po.AUWHENCREATED,
       po.STATE,
       po.PONUMBER,
       url.RECORD_URL
FROM ANALYTICS.INTACCT.PODOCUMENT po
         LEFT JOIN ANALYTICS.INTACCT.GLRESOLVE glr ON po.RECORDNO = glr.DOCHDRKEY
         LEFT JOIN ANALYTICS.INTACCT.GLENTRY gle ON glr.GLENTRYKEY = gle.RECORDNO
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL_VIEW url ON po.RECORDNO = url.RECORDNO AND url.INTACCT_OBJECT = 'PODOCUMENT'
WHERE po.DOCPARID IN ('Purchase Order', 'Closed Purchase Order')
  AND po.STATE != 'Draft'
  AND glr.RECORDNO IS NULL
  AND po.AUWHENCREATED IS NOT NULL
  AND gle.ENTRY_DATE > '2023-10-15'
ORDER BY po.AUWHENCREATED DESC ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: recordno {
    type: string
    label: "Record No"
    sql: ${TABLE}."RECORDNO" ;;
    html: <a href="{{record_url._value}}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: record_url {
    type: string
    label: "Record URL"
    sql: ${TABLE}."RECORD_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: document_number {
    type: string
    label: "Document Number"
    sql: ${TABLE}."DOCNO" ;;
    html: <a href="{{record_url._value}}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: po_created_from {
    type: string
    label: "Created From"
    sql: ${TABLE}."CREATEDFROM" ;;
  }

  dimension: total {
    type: number
    label: "Total"
    sql: ${TABLE}."TOTAL" ;;
  }

  dimension: whencreated {
    type: date
    label: "Date Created"
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension: auwhencreated {
    type: date
    label: "Date Created (Audit)"
    sql: ${TABLE}."AUWHENCREATED" ;;
  }

  dimension: state {
    type: string
    label: "State"
    sql: ${TABLE}."STATE" ;;
  }

  dimension: po_number {
    type: string
    label: "PO Number"
    sql: ${TABLE}."PONUMBER" ;;
  }

  set: detail {
    fields: [
      recordno,
      record_url,
      document_number,
      po_created_from,
      total,
      whencreated,
      auwhencreated,
      state,
      po_number
    ]
  }
}
