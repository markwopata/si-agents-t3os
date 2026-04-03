view: concur_dup_inv_for_deletion {
  derived_table: {
    sql: SELECT DISTINCT
    CONCAT('<?xml version="1.0" encoding="UTF-8"?><PaymentRequest><RequestID>', DUP_INVOICES_AGGR.REQUEST_ID,
           '</RequestID><EmployeeLoginId>joshua.bromer@equipmentshare.com</EmployeeLoginId></PaymentRequest>') AS IMPORT_THIS,
    DUP_INVOICES_AGGR.REQUEST_ID                                                                               AS REQUEST_ID,
    DUP_INVOICES_AGGR.REASON,
    DUP_INVOICES_AGGR.VENDOR_ID,
    VENDB.NAME                                                                                                 AS VENDOR_NAME,
    DUP_INVOICES_AGGR.BILL_NUMBER
FROM
    (SELECT -- Step 001 If the unsubmitted bill matches to one that exists in Intacct already
            INVH.REQUEST_ID,
            '1 - Bill matches one in Intacct' AS REASON,
            INVH.SUPPLIER_CODE                AS VENDOR_ID,
            INVH.INVOICE_NUMBER               AS BILL_NUMBER

     FROM
         ANALYTICS.CONCUR.INVOICE_HEADER_SNAPSHOT INVH
             LEFT JOIN(SELECT
                           APINT.VENDORID         AS VENDOR_ID,
                           APINT.RECORDID         AS BILL_NUMBER,
                           APINT.TRX_TOTALENTERED AS AMOUNT
                       FROM
                           ANALYTICS.INTACCT.APRECORD APINT
                       WHERE
                           APINT.RECORDTYPE = 'apbill') INT_AP
                      ON INVH.SUPPLIER_CODE = INT_AP.VENDOR_ID AND INVH.INVOICE_NUMBER = INT_AP.BILL_NUMBER AND
                         INVH.REQUEST_TOTAL = INT_AP.AMOUNT
     WHERE
           INVH.APPROVAL_STATUS IN ('Not Submitted', 'Sent Back To Employee')
       AND INVH.PAYMENT_STATUS = 'Not Paid'
       AND INT_AP.BILL_NUMBER IS NOT NULL
       AND INVH.IS_DELETED = 'No'

     UNION

     SELECT
         PRELIM_STAGE2.REQUEST_ID,
         PRELIM_STAGE2.REASON,
         PRELIM_STAGE2.VENDOR_ID,
         PRELIM_STAGE2.BILL_NUMBER
     FROM
         (SELECT --If the unsubmitted bill matches to other unsubmitted bills in Concur, it will isolate all but the oldest one, which will stay with the AP owner
                 INVH.REQUEST_ID,
                 '2 - Bill matches to other unsubmitted in Concur' AS REASON,
                 INVH.SUPPLIER_CODE                                AS VENDOR_ID,
                 INVH.INVOICE_NUMBER                               AS BILL_NUMBER,
                 CASE
                     WHEN RANK() OVER (PARTITION BY CONCAT(INVH.SUPPLIER_CODE, '|', INVH.INVOICE_NUMBER, '|',
                                                           INVH.REQUEST_TOTAL) ORDER BY INVH.REQUEST_KEY) > 1
                         THEN 'DELETE'
                     ELSE 'LEAVE' END                              AS ACTION
          FROM
              ANALYTICS.CONCUR.INVOICE_HEADER_SNAPSHOT INVH
                  LEFT JOIN (SELECT
                                 CONCAT(
                                         INVH.SUPPLIER_CODE, '|', INVH.INVOICE_NUMBER, '|',
                                         INVH.REQUEST_TOTAL) AS RECORD,
                                 COUNT(
                                         INVH.REQUEST_KEY)   AS BILL_COUNT
                             FROM
                                 ANALYTICS.CONCUR.INVOICE_HEADER_SNAPSHOT INVH
                             WHERE
                                     INVH.APPROVAL_STATUS IN (
                                                              'Not Submitted', 'Sent Back To Employee')
                               AND   INVH.PAYMENT_STATUS = 'Not Paid'
                               AND   INVH.IS_DELETED = 'No'
                             GROUP BY
                                 CONCAT(
                                         INVH.SUPPLIER_CODE, '|', INVH.INVOICE_NUMBER, '|', INVH.REQUEST_TOTAL)
                             HAVING
                                 BILL_COUNT > 1) DUPCOUNT
                            ON CONCAT(INVH.SUPPLIER_CODE, '|', INVH.INVOICE_NUMBER, '|', INVH.REQUEST_TOTAL) =
                               DUPCOUNT.RECORD
          WHERE
                  INVH.APPROVAL_STATUS IN (
                                           'Not Submitted', 'Sent Back To Employee')
            AND   INVH.PAYMENT_STATUS = 'Not Paid'
            AND   DUPCOUNT.RECORD IS NOT NULL
            AND   INVH.IS_DELETED = 'No') PRELIM_STAGE2
     WHERE
         PRELIM_STAGE2.ACTION = 'DELETE'

     UNION

     SELECT -- Step 003 If the unsubmitted bill matches a submitted bill in Concur that is awaiting approval, it will isolate the unsubmitted one for deletion.
            INVH.REQUEST_ID,
            '3 - Bill matches to other bill awaiting approval in Concur' AS REASON,
            INVH.SUPPLIER_CODE                                           AS VENDOR_ID,
            INVH.INVOICE_NUMBER                                          AS BILL_NUMBER
     FROM
         ANALYTICS.CONCUR.INVOICE_HEADER_SNAPSHOT INVH
             LEFT JOIN (SELECT
                            INVH2.*
                        FROM
                            ANALYTICS.CONCUR.INVOICE_HEADER_SNAPSHOT INVH2
                        WHERE
                                INVH2.APPROVAL_STATUS NOT IN ('Not Submitted', 'Sent Back To Employee', 'Approved')
                          AND   INVH2.PAYMENT_STATUS = 'Not Paid') TB_APPROVED
                       ON INVH.SUPPLIER_CODE = TB_APPROVED.SUPPLIER_CODE AND
                          INVH.INVOICE_NUMBER = TB_APPROVED.INVOICE_NUMBER AND
                          INVH.REQUEST_TOTAL = TB_APPROVED.REQUEST_TOTAL
     WHERE
           INVH.APPROVAL_STATUS IN ('Not Submitted', 'Sent Back To Employee')
       AND INVH.PAYMENT_STATUS = 'Not Paid'
       AND TB_APPROVED.REQUEST_KEY IS NOT NULL
       AND INVH.IS_DELETED = 'No') DUP_INVOICES_AGGR
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VENDB ON DUP_INVOICES_AGGR.VENDOR_ID = VENDB.VENDORID
ORDER BY
    DUP_INVOICES_AGGR.REASON,
    DUP_INVOICES_AGGR.REQUEST_ID
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: import_this {
    type: string
    sql: ${TABLE}."IMPORT_THIS" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: request_id {
    type: string
    sql: ${TABLE}."REQUEST_ID" ;;
  }

  dimension: reason {
    type: string
    sql: ${TABLE}."REASON" ;;
  }

  set: detail {
    fields: [vendor_id, vendor_name, bill_number, import_this, request_id, reason]
  }
}
