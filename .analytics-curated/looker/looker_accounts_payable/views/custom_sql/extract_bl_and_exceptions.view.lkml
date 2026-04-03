view: extract_bl_and_exceptions {
  derived_table: {
    sql: SELECT DISTINCT ABD.REQUEST_KEY,
                ABD.REQUEST_ID,
                ABD.VENDOR_CODE                                                                       AS VENDOR_ID,
                VEND.NAME                                                                             AS VENDOR_NAME,
                CASE
                    WHEN VEND.STATUS = 'active' THEN '-'
                    ELSE CASE WHEN VEND.STATUS IS NULL THEN 'Not in Intacct' ELSE VEND.STATUS END END AS VENDOR_STATUS,
                ABD.VENDOR_INVOICE_NUMBER                                                             AS BILL_NUMBER,
                CASE WHEN APRH.RECORDNO IS NOT NULL THEN 'BILL_EXISTS' ELSE '-' END                   AS BILL_EXISTS,
                ABD.PO_NUMBER                                                                         AS PO_ON_HEADER,
                CORPFIX.VALIDATE                                                                      AS VALIDATE_CORP_CODING,
                CASE
                    WHEN DEPT.STATUS IN ('inactive', 'active non-posting') OR DEPT.STATUS IS NULL
                        THEN 'Invalid Department'
                    ELSE '-' END                                                                      AS VALIDATE_DEPARTMENT,
                CASE
                    WHEN POD.STATE = 'Converted' THEN 'Matched PO already converted'
                    WHEN POD.STATE = 'Closed' THEN 'Matched PO is closed'
                    ELSE ''
                END                                                                                  AS MATCHED_PO_ISSUE,
                ABD.BATCH_ID,
                ABD.BATCH_DATE,
                ABD._ES_UPDATE_TIMESTAMP                                                              AS SNOWFLAKE_IMPORT,
                APRH.DESCRIPTION2                                                                     AS RELATED_VI,
                POH2.CREATEDBY,
                POH2.RECORDNO,
                ABD.SHIPPING_AMOUNT                                                                   AS SHIPPING,
                ABD.TAX_AMOUNT                                                                        AS TAX,
                ABD.TOTAL_AMOUNT                                                                      AS TOTAL,
                ABD.POLICY_NAME
FROM ANALYTICS.CONCUR.APPROVED_BILL_DETAIL ABD
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT POD
            ON ABD.PO_NUMBER = POD.DOCNO
                AND POD.DOCPARID = 'Purchase Order'
         LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON ABD.VENDOR_CODE = VEND.VENDORID
         LEFT JOIN ANALYTICS.CONCUR.SYNC_LOG_VI SLVI ON ABD.REQUEST_KEY = SLVI.CONCUR_REQUEST_KEY
         LEFT JOIN(SELECT DISTINCT CONCUR_REQUEST_KEY AS REQUESTKEY
                   FROM ANALYTICS.CONCUR.EXC_HANDLE_02_DONTSYNC
                   where CONCUR_REQUEST_KEY <> 'nan'--Kendall added wed,jul 19,2023 in response to report failure 'nan' causing report to fail
) AS REQ_DO_NOT_SYNC ON ABD.REQUEST_KEY = REQ_DO_NOT_SYNC.REQUESTKEY
         LEFT JOIN ANALYTICS.INTACCT.APRECORD APRH ON
    ABD.VENDOR_CODE = APRH.VENDORID
        AND ABD.VENDOR_INVOICE_NUMBER = APRH.RECORDID
        AND APRH.RECORDTYPE = 'apbill'
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT POH
                   ON ABD.REQUEST_KEY = POH.CONCUR_REQUEST_KEY AND POH.DOCPARID = 'Vendor Invoice'
         LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT POH2
                   ON APRH.DESCRIPTION2 = POH2.DOCID AND POH2.CREATEDBY IN ('404', '1337')
         LEFT JOIN(SELECT DISTINCT ABD.REQUEST_KEY  AS REQUEST_KEY,
                                   CASE
                                       WHEN VALIDATE.DEPARTMENT IS NULL THEN 'Invalid Combination'
                                       ELSE '-' END AS VALIDATE
                   FROM ANALYTICS.CONCUR.APPROVED_BILL_DETAIL ABD
                            LEFT JOIN(SELECT DISTINCT DELI.DEPARTMENT,
                                                      DELI.EXPENSE_LINE_ID,
                                                      DELI.ITEM
                                      FROM ANALYTICS.FINANCIAL_SYSTEMS.ALL_VALID_EXPENSE_LINE_MAPPINGS DELI) VALIDATE
                                     ON ABD.LINE_ITEM_CUSTOM_1 = VALIDATE.DEPARTMENT AND
                                        ABD.LINE_ITEM_CUSTOM_20 = VALIDATE.EXPENSE_LINE_ID AND
                                        ABD.JOURNAL_ACCOUNT_CODE = VALIDATE.ITEM
                   WHERE LEN(TRY_TO_NUMERIC(ABD.LINE_ITEM_CUSTOM_1)) >= 7) CORPFIX
                  ON ABD.REQUEST_KEY = CORPFIX.REQUEST_KEY
         LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON ABD.LINE_ITEM_CUSTOM_1 = DEPT.DEPARTMENTID
WHERE SLVI.CONCUR_REQUEST_KEY IS NULL
  AND REQ_DO_NOT_SYNC.REQUESTKEY IS NULL
  AND POH.RECORDNO IS NULL
ORDER BY ABD.BATCH_ID ASC,
         ABD.VENDOR_CODE ASC,
         ABD.VENDOR_INVOICE_NUMBER ASC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: request_key {
    type: number
    sql: ${TABLE}."REQUEST_KEY" ;;
  }

  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: vendor_status {
    type: string
    sql: ${TABLE}."VENDOR_STATUS" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: bill_exists {
    type: string
    sql: ${TABLE}."BILL_EXISTS" ;;
  }

  dimension: po_on_header {
    type: string
    sql: ${TABLE}."PO_ON_HEADER" ;;
  }

  dimension: validate_corp_coding {
    type: string
    sql: ${TABLE}."VALIDATE_CORP_CODING" ;;
  }

  dimension: validate_department {
    type: string
    sql: ${TABLE}."VALIDATE_DEPARTMENT" ;;
  }

  dimension: matched_po_issue {
    type: string
    sql: ${TABLE}."MATCHED_PO_ISSUE" ;;
  }

  dimension: batch_id {
    type: number
    sql: ${TABLE}."BATCH_ID" ;;
  }

  dimension: batch_date {
    type: date
    sql: ${TABLE}."BATCH_DATE" ;;
  }

  dimension_group: snowflake_import {
    type: time
    sql: ${TABLE}."SNOWFLAKE_IMPORT" ;;
  }

  dimension: related_vi {
    type: string
    sql: ${TABLE}."RELATED_VI" ;;
  }

  dimension: createdby {
    type: number
    sql: ${TABLE}."CREATEDBY" ;;
  }

  dimension: recordno {
    type: string
    sql: ${TABLE}."RECORDNO" ;;
  }

  dimension: shipping {
    type: number
    sql: ${TABLE}."SHIPPING" ;;
  }

  dimension: tax {
    type: number
    sql: ${TABLE}."TAX" ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}."TOTAL" ;;
  }

  dimension: policy_name {
    type: string
    sql: ${TABLE}."POLICY_NAME" ;;
  }

  set: detail {
    fields: [
      request_key,
      request_id,
      vendor_id,
      vendor_name,
      vendor_status,
      bill_number,
      bill_exists,
      po_on_header,
      validate_corp_coding,
      validate_department,
      matched_po_issue,
      batch_id,
      batch_date,
      snowflake_import_time,
      related_vi,
      createdby,
      recordno,
      shipping,
      tax,
      total
    ]
  }
}
