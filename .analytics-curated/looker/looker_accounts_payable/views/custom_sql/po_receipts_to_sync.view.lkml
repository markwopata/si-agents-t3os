view: po_receipts_to_sync {
  derived_table: {
    sql: WITH data AS (SELECT DOCUMENT_NUMBER,
                     RUN_TIMESTAMP,
                     CAST(GET(XMLGET(XMLGET(XMLGET(XMLGET(XMLGET(PARSE_XML(XML), 'operation'), 'result'),
                                                   'errormessage'), 'error', 0), 'description2'),
                              '$') AS STRING)                                         AS          ERRORTYPE1,
                     CAST(GET(XMLGET(XMLGET(XMLGET(PARSE_XML(XML), 'errormessage'), 'error', 0), 'description2'),
                              '$') AS STRING)                                         AS          ERRORTYPE2,
                     CASE WHEN ERRORTYPE1 IS NULL THEN ERRORTYPE2 ELSE ERRORTYPE1 END AS          ERRORMESSAGE,
                     ROW_NUMBER() OVER (PARTITION BY DOCUMENT_NUMBER ORDER BY RUN_TIMESTAMP DESC) RN
              FROM ANALYTICS.AP_ACCRUAL.CREATE_RECEIPTS_JOB_RESULTS
              -- WHERE RESULT = 'error'
-- AND DOCUMENT_NUMBER = '1199451'
              QUALIFY RN = 1
              ORDER BY RUN_TIMESTAMP DESC),
     results AS (SELECT DISTINCT DOCUMENT_NUMBER, RUN_TIMESTAMP, ERRORMESSAGE
                 FROM data)
SELECT CAST(PRH.DATE_RECEIVED AS DATE)                                          AS "receipt_date",
       CONVERT_TIMEZONE('America/Chicago', PRH.DATE_CREATED)                    AS "when_created",
       VEND.EXTERNAL_ERP_VENDOR_REF                                             AS "vendorid",
       CONCAT(POH.PURCHASE_ORDER_NUMBER, SFX.SUFFIX)                            AS "documentno",
       CONCAT(POH.CREATED_BY_ID, ' - ', USER1.FIRST_NAME, ' ', USER1.LAST_NAME) AS "t3_po_created_by",
       CONCAT(PRH.CREATED_BY_ID, ' - ', USER2.FIRST_NAME, ' ', USER2.LAST_NAME) AS "t3_pr_created_by",
       results.ERRORMESSAGE AS "error_message"
FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" PRH
         JOIN "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" POH ON POH.PURCHASE_ORDER_ID = PRH.PURCHASE_ORDER_ID
         JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USER1 ON USER1.USER_ID = POH.CREATED_BY_ID
         JOIN "ES_WAREHOUSE"."PUBLIC"."USERS" USER2 ON USER2.USER_ID = PRH.CREATED_BY_ID
    --THIS JOIN PULLS THE BRANCH ON THE STORE ID OR THE PARENT OF THE STORE ID
         LEFT JOIN
     (SELECT STR1.STORE_ID,
             COALESCE(STR1.BRANCH_ID, STR2.BRANCH_ID) AS "PARENT_BRANCH_ID"
      FROM "ES_WAREHOUSE"."INVENTORY"."STORES" STR1
               LEFT JOIN "ES_WAREHOUSE"."INVENTORY"."STORES" STR2 ON STR1.PARENT_ID = STR2.STORE_ID
      WHERE STR1.COMPANY_ID = 1854) AS STR ON PRH.STORE_ID = STR.STORE_ID
         LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."BRANCH_ERP_REFS" BERPR ON STR.PARENT_BRANCH_ID = BERPR.BRANCH_ID
         LEFT JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" VEND ON POH.VENDOR_ID = VEND.ENTITY_ID
         LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VENDINT ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
    --THIS NEXT PART IS WHERE THE PO SUFFIX IS DETERMINED. IF THE RANK OF THE DATE RECEIVED FOR EACH PO IS 1, THERE WILL BE NO SUFFIX. OTHERWISE, IT WILL RETURN '-2','-3',...ETC
         LEFT JOIN
     (SELECT PURCHASE_ORDER_RECEIVER_ID,
             CASE
                 WHEN RANK() OVER (PARTITION BY PURCHASE_ORDER_ID ORDER BY DATE_CREATED ASC) > 1 THEN CONCAT('-',
                                                                                                             (RANK() OVER (PARTITION BY PURCHASE_ORDER_ID ORDER BY DATE_CREATED ASC)))
                 ELSE '' END AS "SUFFIX"
      FROM "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS") SFX
     ON PRH.PURCHASE_ORDER_RECEIVER_ID = SFX.PURCHASE_ORDER_RECEIVER_ID
         --THIS JOIN IS NECESSARY BECAUSE SOMETIMES THE DISPLAY CONTACT NAME IS NOT SHOWN ON THE VENDOR RECORD, INSTEAD A DISPLAYCONTACTKEY IS SPECIFIED
         LEFT JOIN "ANALYTICS"."INTACCT"."CONTACT" CONTACT ON VENDINT.DISPLAYCONTACTKEY = CONTACT.RECORDNO
         LEFT JOIN "ANALYTICS"."INTACCT"."PODOCUMENT" INTPO
                   ON CONCAT(POH.PURCHASE_ORDER_NUMBER, SFX.SUFFIX) = INTPO.DOCNO
         LEFT JOIN results ON CONCAT(POH.PURCHASE_ORDER_NUMBER, SFX.SUFFIX) = results.DOCUMENT_NUMBER
WHERE POH.COMPANY_ID = 1854
  AND PRH.RECEIVER_TYPE = 'RECEIPT'
  AND INTPO.DOCNO IS NULL
  AND POH.REQUESTING_BRANCH_ID not in (7521, 55924, 32198, 47399, 32199, 1491, 32200, 32197, 13481, 26563)
ORDER BY "receipt_date" DESC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: receipt_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."receipt_date" ;;
  }

  dimension_group: when_created {
    convert_tz: no
    type: time
    sql: ${TABLE}."when_created" ;;
  }

  dimension: vendorid {
    type: string
    sql: ${TABLE}."vendorid" ;;
  }

  dimension: documentno {
    type: string
    sql: ${TABLE}."documentno" ;;
  }

  dimension: t3_po_created_by {
    type: string
    sql: ${TABLE}."t3_po_created_by" ;;
  }

  dimension: t3_pr_created_by {
    type: string
    sql: ${TABLE}."t3_pr_created_by" ;;
  }

  dimension: error_message {
    type: string
    sql: ${TABLE}."error_message" ;;
  }

  set: detail {
    fields: [
      receipt_date,
      when_created_time,
      vendorid,
      documentno,
      t3_po_created_by,
      t3_pr_created_by,
      error_message
    ]
  }
}
