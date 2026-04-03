view: one_sided_entries_pos {
  derived_table: {
    sql: SELECT --po.RECORDNO,
       po.DOCNO,
--        po.CREATEDFROM,
--        po.TOTAL,
       po.WHENCREATED,
       po.AUWHENCREATED,
       po.STATE,
       po.PONUMBER,
--        glr.AMOUNT,
--        glr.TRX_AMOUNT,
       SUM(gle.TR_TYPE) AS SUM,
--        gle.AMOUNT,
--        gle.ACCOUNTKEY,
       url.RECORD_URL
FROM ANALYTICS.INTACCT.PODOCUMENT po
         LEFT JOIN ANALYTICS.INTACCT.GLRESOLVE glr ON po.RECORDNO = glr.DOCHDRKEY
         LEFT JOIN ANALYTICS.INTACCT.GLENTRY gle ON glr.GLENTRYKEY = gle.RECORDNO
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL_VIEW url ON po.RECORDNO = url.RECORDNO AND url.INTACCT_OBJECT = 'PODOCUMENT'
WHERE po.DOCPARID IN ('Purchase Order', 'Closed Purchase Order')
  AND po.STATE != 'Draft'
--   AND glr.RECORDNO IS NULL
  AND po.AUWHENCREATED IS NOT NULL
--   AND gle.ENTRY_DATE > '2023-10-15'
GROUP BY po.DOCNO, po.WHENCREATED, po.AUWHENCREATED, po.STATE, po.PONUMBER, url.RECORD_URL
HAVING SUM != 0
ORDER BY po.AUWHENCREATED DESC ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: doc_no {
    type: string
    label: "Document Number"
    sql: ${TABLE}."DOCNO" ;;
    html: <a href="{{record_url._value}}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: record_url {
    type: string
    label: "PO URL Sage"
    sql: ${TABLE}."RECORD_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: whencreated {
    type: date
    label: "When Created"
    sql: ${TABLE}."WHENCREATED" ;;
  }

  dimension: auwhencreated {
    type: date
    label: "When Created (Audit)"
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

  dimension: check {
    type: number
    label: "Check"
    sql: ${TABLE}."SUM" ;;
  }

  set: detail {
    fields: [
      doc_no,
      record_url,
      whencreated,
      auwhencreated,
      state,
      po_number,
      check
    ]
  }
}
