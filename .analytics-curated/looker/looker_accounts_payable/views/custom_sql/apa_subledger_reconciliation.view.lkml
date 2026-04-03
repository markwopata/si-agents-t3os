view: apa_subledger_reconciliation {
  derived_table: {
    sql: SELECT
    PD.CUSTVENDID                                                            AS VENDOR_ID,
    VEND.NAME                                                                AS VENDOR_NAME,
    PD.DOCNO                                                                 AS PO_NUMBER,
    PD.WHENCREATED                                                           AS PO_POSTING_DATE,
    PD.STATE                                                                 AS PO_STATE,
    PDE.LINE_NO + 1                                                          AS PO_LINE,
    PDE.RECORDNO                                                             AS PO_LINE_RECORDNO,
    PDE.ITEMID                                                               AS ITEM_ID_ORIGINAL,
    COALESCE(ITM_TRANS.NEW_ITEM_ID, PDE.ITEMID)                              AS ITEM_ID_CURRENT,
    SUBSTR(COALESCE(ITM_TRANS.NEW_ITEM_ID, PDE.ITEMID), 2, 4)                AS ACCOUNT,
    PDE.GLDIMEXPENSE_LINE                                                    AS EXP_LINE_ID,
    EL.NAME                                                                  AS EXP_LINE_NAME,
    PDE.DEPARTMENTID                                                         AS DEPT_ID,
    DEPT.TITLE                                                               AS DEPT_NAME,
    PDE.LOCATIONID                                                           AS ENTITY,
    PDE.UIQTY                                                                AS QTY_ORIGINAL,
    COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0)                             AS QTY_CONVERTED,
    (PDE.UIQTY - COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0))               AS QTY_REMAINING,
    PDE.UIPRICE                                                              AS PO_LINE_UNIT_PRICE,
    (PDE.UIQTY - COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0)) * PDE.UIPRICE AS EXT_COST_REMAIN
FROM
    ANALYTICS.INTACCT.PODOCUMENT PD
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY PDE
                  ON PD.DOCID = PDE.DOCHDRID
                      AND PD.DOCPARID = 'Purchase Order'
        LEFT JOIN (SELECT
                       VI_CPO.CREATEDFROM        AS SOURCE_PO_DOCID,
                       VI_CPOD.SOURCE_DOCLINEKEY AS SOURCE_PO_LINE_RECORDNO,
                       SUM(VI_CPOD.UIQTY)        AS CONVERTED_QTY
                   FROM
                       ANALYTICS.INTACCT.PODOCUMENT VI_CPO
                           LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY VI_CPOD
                                     ON VI_CPOD.DOCHDRID = VI_CPO.DOCID
                   WHERE
                         VI_CPO.DOCPARID IN ('Vendor Invoice', 'Closed Purchase Order', 'Closed PO Non Posting')
                     AND VI_CPO.CREATEDFROM IS NOT NULL
                     AND VI_CPOD.SOURCE_DOCLINEKEY IS NOT NULL
                     AND COALESCE(VI_CPO.WHENPOSTED, VI_CPO.WHENCREATED) <= {% date_end as_of_date %}
                   GROUP BY
                       VI_CPO.CREATEDFROM,
                       VI_CPOD.SOURCE_DOCLINEKEY) VI_OR_PO_QTY_CONV
                  ON PD.DOCID = VI_OR_PO_QTY_CONV.SOURCE_PO_DOCID AND
                     PDE.RECORDNO =
                     VI_OR_PO_QTY_CONV.SOURCE_PO_LINE_RECORDNO
        LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM ITM_TRANS ON PDE.ITEMID = ITM_TRANS.OG_ITEM_ID
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON PD.CUSTVENDID = VEND.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE EL ON PDE.GLDIMEXPENSE_LINE = EL.ID
        LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON PDE.DEPARTMENTID = DEPT.DEPARTMENTID
WHERE
    PD.DOCPARID = 'Purchase Order'
  AND (CAST(CONVERT_TIMEZONE('America/Chicago', PD.AUWHENCREATED) AS DATE) > '2023-10-15' OR
       PD.T3_PR_CREATED_BY IS NOT NULL) --THIS IS IDENTIFYING THE RECEIPTS ONLY
  AND (PDE.UIQTY - COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0)) * PDE.UIPRICE != 0
--   AND EXT_COST_REMAIN != 0
  AND (PDE.UIQTY - COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0)) >= 0 --THIS IS TO PREVENT OVER-CONVERSIONS FROM DISPLAYING NEGATIVES
--   AND QTY_REMAINING >= 0
  AND PD.WHENCREATED <= {% date_end as_of_date %}
  AND PD.STATE NOT IN ('Closed', 'Draft', 'In Progress')
  AND PD.DOCNO NOT IN('387320','392958','395168','395243','670257','394480','603626-2','392949','394841','394665','392143','693489','394765','387915','386962')
ORDER BY
  PD.CUSTVENDID ASC,
  PD.DOCNO ASC,
  PDE.LINE_NO ASC
      ;;
  }

  measure: count {type: count drill_fields: [detail*]}
  dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  dimension: vendor_name {type: string sql: ${TABLE}."VENDOR_NAME" ;;}
  dimension: po_number {type: string sql: ${TABLE}."PO_NUMBER" ;;}
  dimension: po_posting_date {convert_tz: no type: date sql: ${TABLE}."PO_POSTING_DATE" ;;}
  dimension: po_state {type: string sql: ${TABLE}."PO_STATE" ;;}
  dimension: po_line {type: number sql: ${TABLE}."PO_LINE" ;;}
  dimension: po_line_recordno {type: string sql: ${TABLE}."PO_LINE_RECORDNO" ;;}
  dimension: item_id_original {type: string sql: ${TABLE}."ITEM_ID_ORIGINAL" ;;}
  dimension: item_id_current {type: string sql: ${TABLE}."ITEM_ID_CURRENT" ;;}
  dimension: account {type: string sql: ${TABLE}."ACCOUNT" ;;}
  dimension: exp_line_id {type: string sql: ${TABLE}."EXP_LINE_ID" ;;}
  dimension: exp_line_name {type: string sql: ${TABLE}."EXP_LINE_NAME" ;;}
  dimension: dept_id {type: string sql: ${TABLE}."DEPT_ID" ;;}
  dimension: dept_name {type: string sql: ${TABLE}."DEPT_NAME" ;;}
  dimension: entity {type: string sql: ${TABLE}."ENTITY" ;;}
  measure: qty_original {type: sum sql: ${TABLE}."QTY_ORIGINAL" ;;}
  measure: qty_converted {type: sum sql: ${TABLE}."QTY_CONVERTED" ;;}
  measure: qty_remaining {type: sum sql: ${TABLE}."QTY_REMAINING" ;;}
  dimension: po_line_unit_price {type: number sql: ${TABLE}."PO_LINE_UNIT_PRICE" ;;}
  measure: ext_cost_remain {type: sum sql: ${TABLE}."EXT_COST_REMAIN" ;;}

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      po_number,
      po_posting_date,
      po_state,
      po_line,
      po_line_recordno,
      item_id_original,
      item_id_current,
      account,
      exp_line_id,
      exp_line_name,
      dept_id,
      dept_name,
      entity,
      qty_original,
      qty_converted,
      qty_remaining,
      po_line_unit_price,
      ext_cost_remain
    ]
  }
  filter: as_of_date {
    type: date
  }
}
