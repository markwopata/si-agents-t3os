view: po_sage_sync_error {
  derived_table: {
    sql:
   WITH xml_errors AS (SELECT DOCUMENT_NUMBER,
                           RUN_TIMESTAMP,
                           XML,
                           CAST(GET(XMLGET(XMLGET(XMLGET(XMLGET(XMLGET(PARSE_XML(XML), 'operation'), 'result'),
                                                         'errormessage'), 'error', 0), 'description2'),
                                    '$') AS STRING)                                                     AS ERRORTYPE1,
                           CAST(GET(XMLGET(XMLGET(XMLGET(PARSE_XML(XML), 'errormessage'), 'error', 0), 'description2'),
                                    '$') AS STRING)                                                     AS ERRORTYPE2,
                           CASE
                               WHEN ERRORTYPE1 IS NULL THEN ERRORTYPE2
                               ELSE ERRORTYPE1
                               END                                                                      AS ERRORMESSAGE,
                           ROW_NUMBER() OVER (PARTITION BY DOCUMENT_NUMBER ORDER BY RUN_TIMESTAMP DESC) AS RN
                    FROM ANALYTICS.AP_ACCRUAL.CREATE_RECEIPTS_JOB_RESULTS
                    QUALIFY RN = 1)
SELECT DISTINCT CC.PR_DATE_CREATED                                  AS COSTCAPTURE_CREATED_DATE,
                CC_PO_NUMBER,
                INTACCT_PO_NUMBER,
                CC.ITEM_TYPE,
                COALESCE(CC.FULL_PART_DESCRIPTION, CC.NON_INV_ITEM) AS LINE_INFORMATION,
                CC.INTACCT_DEPT_FROM_PO_BRANCH                      AS BRANCH_ID_FROM_COST_CENTER,
                CC.INTACCT_DEPT_NAME_FROM_PO_BRANCH                 AS BRANCH_NAME_FROM_COST_CENTER,
                CC.INTACCT_DEPT_FROM_STORE                          AS BRANCH_ID_FROM_STORE,
                CC.INTACCT_DEPT_NAME_FROM_STORE                     AS BRANCH_NAME_FROM_STORE,
                CC.FINAL_DEPARTMENT_ID                              AS SAGE_BRANCH_ID,
                SAGE.TITLE                                          AS SAGE_BRANCH_NAME,
                SAGE.STATUS                                         AS SAGE_BRANCH_STATUS,
                V.VENDORID,
                V.NAME                                              AS VENDOR_NAME,
                COALESCE(
                        CASE
                            WHEN SAGE.DEPARTMENTID IS NULL THEN 'Department Mapping Missing'
                            WHEN SAGE.STATUS = 'active non-posting' THEN 'Active Non-Posting Location'
                            WHEN V.VENDORID IS NULL THEN 'Vendor Mapping Missing'
                            WHEN V.STATUS = 'inactive' THEN 'Inactive Vendor'
                            WHEN V.ONHOLD = 'TRUE' THEN 'Vendor on Hold'
                            WHEN CC.FINAL_DEPARTMENT_ID >= 1000000 THEN 'Corporate POs will NOT Sync to Sage'
                            ELSE NULL
                            END, ERR.ERRORMESSAGE
                )                                                   AS SYNC_ERROR_EXPLANATION
FROM ANALYTICS.FINANCIAL_SYSTEMS.COSTCAPTURE_PO_RECEIPT_DETAILS CC
         LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT SAGE ON CC.FINAL_DEPARTMENT_ID = SAGE.DEPARTMENTID
         LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT COST_CENTER
                   ON CAST(CC.ORDER_BRANCH_ID AS STRING) = COST_CENTER.DEPARTMENTID
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POD
                   ON CC.FK_T3_PURCHASE_ORDER_RECEIVER_ITEM_ID = POD.T3_LINE_ITEM_ID
         LEFT JOIN ANALYTICS.INTACCT.VENDOR V ON CC.VENDOR_ID = V.VENDORID
         LEFT JOIN xml_errors ERR ON TO_VARCHAR(CC.INTACCT_PO_NUMBER) = TO_VARCHAR(ERR.DOCUMENT_NUMBER)
WHERE POD.AUWHENCREATED IS NULL
  AND DATEDIFF(DAY, CC.PR_DATE_CREATED, CURRENT_DATE) > 0
ORDER BY CC.PR_DATE_CREATED DESC, INTACCT_PO_NUMBER
      ;;
  }

 measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: cc_po_number {
  type: number
  sql: ${TABLE}.CC_PO_NUMBER ;;
}

dimension: intacct_po_number {
  type: string
  sql: ${TABLE}.INTACCT_PO_NUMBER ;;
}

dimension: item_type {
  type: string
  sql: ${TABLE}.ITEM_TYPE ;;
}

dimension: line_information {
  type: string
  sql: ${TABLE}.LINE_INFORMATION ;;
}

dimension: branch_id_from_cost_center {
  type: string
  sql: ${TABLE}.BRANCH_ID_FROM_COST_CENTER ;;
}

dimension: branch_name_from_cost_center {
  type: string
  sql: ${TABLE}.BRANCH_NAME_FROM_COST_CENTER ;;
}

dimension: branch_id_from_store {
  type: string
  sql: ${TABLE}.BRANCH_ID_FROM_STORE ;;
}

dimension: branch_name_from_store {
  type: string
  sql: ${TABLE}.BRANCH_NAME_FROM_STORE ;;
}

dimension: sage_branch_id {
  type: string
  sql: ${TABLE}.SAGE_BRANCH_ID ;;
}

dimension: sage_branch_name {
  type: string
  sql: ${TABLE}.SAGE_BRANCH_NAME ;;
}

dimension: sage_branch_status {
  type: string
  sql: ${TABLE}.SAGE_BRANCH_STATUS ;;
}

dimension: vendor_id {
  type: string
  sql: ${TABLE}.VENDORID ;;
}

dimension: vendor_name {
  type: string
  sql: ${TABLE}.VENDOR_NAME ;;
}

dimension: sync_error_explanation {
  type: string
  sql: ${TABLE}.SYNC_ERROR_EXPLANATION ;;
}

dimension: costcapture_created_date {
  type: date
  sql: ${TABLE}.COSTCAPTURE_CREATED_DATE ;;
}

set: detail {
  fields: [
    cc_po_number,
    intacct_po_number,
    item_type,
    line_information,
    branch_id_from_cost_center,
    branch_name_from_cost_center,
    branch_id_from_store,
    branch_name_from_store,
    sage_branch_id,
    sage_branch_name,
    sage_branch_status,
    vendor_id,
    vendor_name,
    costcapture_created_date,
    sync_error_explanation
  ]
}
}
