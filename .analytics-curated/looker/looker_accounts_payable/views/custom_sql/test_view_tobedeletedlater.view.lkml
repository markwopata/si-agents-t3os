view: test_view_tobedeletedlater {
  derived_table: {
    sql: SELECT
          POH.CUSTVENDID AS VENDOR_ID,
          VEND.NAME AS VENDOR_NAME,
          POH.WHENCREATED AS PO_DATE,
          POH.DOCNO AS PO_NUMBER,
          SPLIT_PART(POH.DOCNO, '-', 0) AS BASE_PO_NUMBER,
          POH.STATUS AS STATUS,
          POH.T3_PO_CREATED_BY,
          POH.T3_PR_CREATED_BY,
          VEND.NAME
      FROM
          ANALYTICS.INTACCT.PODOCUMENT POH
              LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL ON POH.DOCID = POL.DOCHDRID
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON POH.CUSTVENDID = VEND.VENDORID
      WHERE
          POH.DOCPARID = 'Purchase Order'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: po_date {
    type: date
    sql: ${TABLE}."PO_DATE" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: base_po_number {
    type: string
    sql: ${TABLE}."BASE_PO_NUMBER" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: t3_po_created_by {
    type: string
    sql: ${TABLE}."T3_PO_CREATED_BY" ;;
  }

  dimension: t3_pr_created_by {
    type: string
    sql: ${TABLE}."T3_PR_CREATED_BY" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      po_date,
      po_number,
      base_po_number,
      status,
      t3_po_created_by,
      t3_pr_created_by,
      name
    ]
  }
}
