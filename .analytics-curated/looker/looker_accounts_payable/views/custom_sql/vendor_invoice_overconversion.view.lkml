view: vendor_invoice_overconversion {
  derived_table: {
    sql: SELECT
    PD.DOCNO                                                                 AS PO_NUMBER,
    CONCAT('Purchase Order-', PD.DOCNO)                                      AS PO_NUMBER_FORMATTED,
    PDE.RECORDNO                                                             AS PO_LINE_RECORDNO,
    (PDE.UIQTY - COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0)) * PDE.UIPRICE AS EXT_COST_REMAIN,
    PDE.UIQTY                                                                AS QTY_ORIGINAL,
    COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0)                             AS QTY_CONVERTED,
    (PDE.UIQTY - COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0))               AS QTY_REMAINING,
    PD._ES_UPDATE_TIMESTAMP                                                  AS ES_TIMESTAMP,
    CONVERT_TIMEZONE('America/Chicago', VI_OR_PO_QTY_CONV.LAST_CONV_DATE)    AS LAST_ACTIVITY
FROM
    ANALYTICS.INTACCT.PODOCUMENT PD
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY PDE
                  ON PD.DOCID = PDE.DOCHDRID
                      AND PD.DOCPARID = 'Purchase Order'
        LEFT JOIN (SELECT
                       VI_CPO.CREATEDFROM        AS SOURCE_PO_DOCID,
                       VI_CPOD.SOURCE_DOCLINEKEY AS SOURCE_PO_LINE_RECORDNO,
                       MAX(VI_CPO.AUWHENCREATED) AS LAST_CONV_DATE,
                       SUM(VI_CPOD.UIQTY)        AS CONVERTED_QTY
                   FROM
                       ANALYTICS.INTACCT.PODOCUMENT VI_CPO
                           LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY VI_CPOD
                                     ON VI_CPOD.DOCHDRID = VI_CPO.DOCID
                   WHERE
                         VI_CPO.DOCPARID IN ('Vendor Invoice', 'Closed Purchase Order', 'Closed PO Non Posting')
                     AND VI_CPO.CREATEDFROM IS NOT NULL
                     AND VI_CPOD.SOURCE_DOCLINEKEY IS NOT NULL
                   GROUP BY
                       VI_CPO.CREATEDFROM,
                       VI_CPOD.SOURCE_DOCLINEKEY) VI_OR_PO_QTY_CONV
                  ON PD.DOCID = VI_OR_PO_QTY_CONV.SOURCE_PO_DOCID AND
                     PDE.RECORDNO =
                     VI_OR_PO_QTY_CONV.SOURCE_PO_LINE_RECORDNO
        LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM ITM_TRANS ON PDE.ITEMID = ITM_TRANS.OG_ITEM_ID
WHERE
      PD.DOCPARID = 'Purchase Order'
  AND (CAST(CONVERT_TIMEZONE('America/Chicago', PD.AUWHENCREATED) AS DATE) > '2023-10-15' OR
       PD.T3_PR_CREATED_BY IS NOT NULL)
--   AND EXT_COST_REMAIN != 0
  AND VI_OR_PO_QTY_CONV.LAST_CONV_DATE >= '2024-02-10'
  AND QTY_REMAINING < 0
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_number {
    type: string
    label: "PO Number"
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: po_number_formatted {
    type: string
    label: "Formatted PO Number"
    sql: ${TABLE}."PO_NUMBER_FORMATTED" ;;
  }

  dimension: po_line_recordno {
    type: string
    label: "PO Line Record Number"
    sql: ${TABLE}."PO_LINE_RECORDNO" ;;
  }

  dimension: ext_cost_remain {
    type: string
    label: "Extra Cost Remaining"
    sql: ${TABLE}."EXT_COST_REMAIN" ;;
  }

  dimension: qty_original {
    type: string
    label: "Original Quantity"
    sql: ${TABLE}."QTY_ORIGINAL" ;;
  }

  dimension: qty_converted {
    type: string
    label: "Quantity Converted"
    sql: ${TABLE}."QTY_CONVERTED" ;;
  }

  dimension: qty_remaining {
    type: string
    label: "Quantity Remaining"
    sql: ${TABLE}."QTY_REMAINING" ;;
  }

  dimension: last_activity {
    type:  date_time
    label: "Last Activity"
    sql: ${TABLE}."LAST_ACTIVITY" ;;
  }

  set: detail {
    fields: [
      po_number,
      po_number_formatted,
      po_line_recordno,
      ext_cost_remain,
      qty_original,
      qty_converted,
      qty_remaining,
      last_activity
    ]
  }
}
