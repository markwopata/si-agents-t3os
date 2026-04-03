view: sync_alert_from_t3 {
    derived_table: {
      sql: SELECT
CONVERT_TIMEZONE('America/Chicago', PRH.DATE_RECEIVED) as date_rec,
    CASE
        WHEN CAST(CONVERT_TIMEZONE('America/Chicago', PRH.DATE_RECEIVED) AS DATE) <= LC.LAST_CLOSED
            THEN LC.LAST_CLOSED + 1
        ELSE CAST(CONVERT_TIMEZONE('America/Chicago', PRH.DATE_RECEIVED) AS DATE) END                AS DATE_ADJ_OLD,
    CASE
        WHEN DATE_ADJ_OLD = '2023-12-30' THEN '2023-12-31'
        WHEN DATE_ADJ_OLD = '2024-01-03' THEN '2024-01-04'
        ELSE DATE_ADJ_OLD END                                                                        AS DATE_ADJ,
    YEAR(DATE_ADJ)                                                                                   AS DATECREATED_YEAR,
    MONTH(DATE_ADJ)                                                                                  AS DATECREATED_MONTH,
    DAY(DATE_ADJ)                                                                                    AS DATECREATED_DAY,
    COALESCE(VEND_REDIRECT.VENDOR_REDIRECT, VEND.EXTERNAL_ERP_VENDOR_REF)                            AS VENDORID,
    CONCAT(POH.PURCHASE_ORDER_NUMBER, SFX.SUFFIX, CASE
                                                      WHEN PRH.RECEIVER_TYPE = 'ADJUSTMENT' THEN 'A'
                                                      ELSE '' END)                                   AS DOCUMENTNO,
    LEFT(POH.REFERENCE, 118)                                                                         AS REFERENCENO,
    VENDINT.TERMNAME                                                                                 AS TERMNAME,
    COALESCE(NULLIF(RETURNTOCONTACT.CONTACTNAME, ''),
             CONTACT.CONTACTNAME)                                                                    AS RETURNTO_CONTACTNAME,
    COALESCE(NULLIF(PAYTOCONTACT.CONTACTNAME, ''),
             CONTACT.CONTACTNAME)                                                                    AS PAYTO_CONTACTNAME,
    CONCAT(POH.CREATED_BY_ID, ' - ', USER1.FIRST_NAME, ' ',
           USER1.LAST_NAME)                                                                          AS T3_PO_CREATED_BY,
    CONCAT(PRH.CREATED_BY_ID, ' - ', USER2.FIRST_NAME, ' ',
           USER2.LAST_NAME)                                                                          AS T3_PR_CREATED_BY,
    PRH.STORE_ID                                                                                     AS RECEIVED_TO_STORE,
    CASE
        WHEN
            ITM.ITEM_TYPE = 'INVENTORY'
            THEN
            'A1301'
        ELSE
            (CASE
                 WHEN
                     ITM.ITEM_TYPE != 'INVENTORY'
                     THEN
                     LEFT(NINV.NAME, 5)
                 ELSE
                     'XXXX'
                END)
        END                                                                                          AS ITEMID,
    PRL.ACCEPTED_QUANTITY + PRL.REJECTED_QUANTITY                                                    AS QUANTITY,
    'Each'                                                                                           AS UNIT,
    PRL.PRICE_PER_UNIT                                                                               AS PRICE,
    'E1'                                                                                             AS LOCATIONID,
    CASE
        WHEN ITM.ITEM_TYPE = 'INVENTORY' THEN COALESCE(BERPR.INTACCT_DEPARTMENT_ID,
                                                       TO_CHAR(TRUNC(STR.PARENT_BRANCH_ID, 0)))
        ELSE COALESCE(BERPR2.INTACCT_DEPARTMENT_ID, TO_CHAR(TRUNC(POH.REQUESTING_BRANCH_ID, 0))) END AS DEPARTMENT_ID,
    LEFT(POL.DESCRIPTION, 254)                                                                       AS MEMO,
    PRL.PURCHASE_ORDER_RECEIVER_ITEM_ID                                                              AS PO_LINE_REC_ITEM_ID
FROM
    PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS PRH
        JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS PRL
             ON PRL.PURCHASE_ORDER_RECEIVER_ID = PRH.PURCHASE_ORDER_RECEIVER_ID
        JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDERS POH ON POH.PURCHASE_ORDER_ID = PRH.PURCHASE_ORDER_ID
        JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS POL
             ON POL.PURCHASE_ORDER_LINE_ITEM_ID = PRL.PURCHASE_ORDER_LINE_ITEM_ID
        JOIN ES_WAREHOUSE.PUBLIC.USERS USER1 ON USER1.USER_ID = POH.CREATED_BY_ID
        JOIN ES_WAREHOUSE.PUBLIC.USERS USER2 ON USER2.USER_ID = PRH.CREATED_BY_ID
        LEFT JOIN PROCUREMENT.PUBLIC.ITEMS ITM ON POL.ITEM_ID = ITM.ITEM_ID
        LEFT JOIN PROCUREMENT.PUBLIC.NON_INVENTORY_ITEMS NINV ON NINV.ITEM_ID = POL.ITEM_ID
        --THIS JOIN PULLS THE BRANCH ON THE STORE ID OR THE PARENT OF THE STORE ID
        LEFT JOIN
        (SELECT
             STR1.STORE_ID,
             COALESCE(STR1.BRANCH_ID, STR2.BRANCH_ID) AS "PARENT_BRANCH_ID"
         FROM
             ES_WAREHOUSE.INVENTORY.STORES STR1
                 LEFT JOIN ES_WAREHOUSE.INVENTORY.STORES STR2 ON STR1.PARENT_ID = STR2.STORE_ID
         WHERE
             STR1.COMPANY_ID = 1854) AS STR ON PRH.STORE_ID = STR.STORE_ID
        LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERPR ON STR.PARENT_BRANCH_ID = BERPR.BRANCH_ID
        LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS VEND ON POH.VENDOR_ID = VEND.ENTITY_ID
        --          LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.COST_CAPTURE_VENDOR_REDIRECT CCVR
--                    ON VEND.EXTERNAL_ERP_VENDOR_REF = CCVR.ORIGINAL_VENDOR_ID AND ACTIVE_END_DATE IS NULL
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND_REDIRECT ON VEND.EXTERNAL_ERP_VENDOR_REF = VEND_REDIRECT.VENDORID
        --LEFT JOIN "ANALYTICS"."SAGE_INTACCT"."VENDOR" VENDINT ON COALESCE(CCVR.CORRECT_VENDOR_ID,VEND.EXTERNAL_ERP_VENDOR_REF) = VENDINT.VENDORID
        LEFT JOIN ANALYTICS.INTACCT.VENDOR VENDINT
                  ON COALESCE(VEND_REDIRECT.VENDOR_REDIRECT, VEND.EXTERNAL_ERP_VENDOR_REF) = VENDINT.VENDORID
        --THIS NEXT PART IS WHERE THE PO SUFFIX IS DETERMINED. IF THE RANK OF THE DATE RECEIVED FOR EACH PO IS 1, THERE WILL BE NO SUFFIX. OTHERWISE, IT WILL RETURN '-2','-3',...ETC
        LEFT JOIN
        (SELECT
             PURCHASE_ORDER_RECEIVER_ID,
             CASE
                 WHEN RANK() OVER (PARTITION BY PURCHASE_ORDER_ID ORDER BY DATE_CREATED ASC) > 1 THEN CONCAT('-',
                                                                                                             (RANK() OVER (PARTITION BY PURCHASE_ORDER_ID ORDER BY DATE_CREATED ASC)))
                 ELSE '' END AS "SUFFIX"
         FROM
             "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS") SFX
        ON PRH.PURCHASE_ORDER_RECEIVER_ID = SFX.PURCHASE_ORDER_RECEIVER_ID
            --THIS JOIN IS NECESSARY BECAUSE SOMETIMES THE DISPLAY CONTACT NAME IS NOT SHOWN ON THE VENDOR RECORD, INSTEAD A DISPLAYCONTACTKEY IS SPECIFIED
        LEFT JOIN ANALYTICS.INTACCT.CONTACT CONTACT ON VENDINT.DISPLAYCONTACTKEY = CONTACT.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.CONTACT PAYTOCONTACT ON VENDINT.PAYTOKEY = PAYTOCONTACT.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.CONTACT RETURNTOCONTACT ON VENDINT.RETURNTOKEY = RETURNTOCONTACT.RECORDNO
        LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT INTPO
                  ON CONCAT(POH.PURCHASE_ORDER_NUMBER, SFX.SUFFIX, IFF(PRH.RECEIVER_TYPE = 'ADJUSTMENT', 'A', '')) =
                     INTPO.DOCNO
        LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERPR2 ON POH.REQUESTING_BRANCH_ID = BERPR2.BRANCH_ID
        JOIN ANALYTICS.INTACCT.DEPARTMENT DEPARTMENT
             ON DEPARTMENT_ID = DEPARTMENT.DEPARTMENTID
                 AND DEPARTMENT.STATUS = 'active'
        LEFT JOIN (SELECT DISTINCT
                       PRL.PURCHASE_ORDER_RECEIVER_ID
                   FROM
                       PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS PRL
                           LEFT JOIN PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS POL
                                     ON PRL.PURCHASE_ORDER_LINE_ITEM_ID = POL.PURCHASE_ORDER_LINE_ITEM_ID
                           LEFT JOIN PROCUREMENT.PUBLIC.ITEMS ITM ON POL.ITEM_ID = ITM.ITEM_ID
                   WHERE
                       ITM.ITEM_ID IS NULL) MISS_ITEM_CHK
                  ON PRH.PURCHASE_ORDER_RECEIVER_ID = MISS_ITEM_CHK.PURCHASE_ORDER_RECEIVER_ID
        LEFT JOIN (SELECT MAX(LAST_CLOSED_DATE) AS LAST_CLOSED FROM ANALYTICS.CONCUR.LAST_CLOSE_DATE_AP) LC
WHERE
      POH.COMPANY_ID = 1854
  AND PRH.RECEIVER_TYPE IN ('RECEIPT')
  AND ITM.ITEM_TYPE != 'SERVICE'
  AND INTPO.DOCNO IS NULL
  AND POH.PURCHASE_ORDER_NUMBER IS NOT NULL
  AND CONVERT_TIMEZONE('America/Chicago', PRH.DATE_CREATED) <
      DATEADD(MINUTE, -12, CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP(0)))
  AND COALESCE(VEND_REDIRECT.VENDOR_REDIRECT, VEND.EXTERNAL_ERP_VENDOR_REF) IS NOT NULL
  AND CASE
          WHEN ITM.ITEM_TYPE = 'INVENTORY' THEN COALESCE(BERPR.INTACCT_DEPARTMENT_ID,
                                                         TO_CHAR(TRUNC(STR.PARENT_BRANCH_ID, 0)))
          ELSE COALESCE(BERPR2.INTACCT_DEPARTMENT_ID, TO_CHAR(TRUNC(POH.REQUESTING_BRANCH_ID, 0))) END IS NOT NULL
  AND POH.REQUESTING_BRANCH_ID NOT IN (7521, 55924, 32198, 47399, 32199, 1491, 32200, 32197, 13481)
  AND VENDINT.STATUS = 'active'
      -- If we get more than 5 errors from a document number it will be ignored
  AND DOCUMENTNO NOT IN (SELECT
                             DOCUMENT_NUMBER
                         FROM
                             ANALYTICS.AP_ACCRUAL.CREATE_RECEIPTS_JOB_RESULTS
                         WHERE
                             RESULT = 'error'
                         GROUP BY DOCUMENT_NUMBER
                         HAVING
                             COUNT(DOCUMENT_NUMBER) > 5)
      -- If the document has already been successfully written it is ignored
  AND DOCUMENTNO NOT IN (SELECT
                             DOCUMENT_NUMBER
                         FROM
                             ANALYTICS.AP_ACCRUAL.CREATE_RECEIPTS_JOB_RESULTS
                         WHERE
                             RESULT = 'success')
  AND MISS_ITEM_CHK.PURCHASE_ORDER_RECEIVER_ID IS NULL
  AND ITEMID NOT IN ('A1310','A6315')
and CONVERT_TIMEZONE('America/Chicago', PRH.DATE_RECEIVED) >= DATEADD(DAY, -5, CURRENT_DATE())
and CONVERT_TIMEZONE('America/Chicago', PRH.DATE_RECEIVED) <= DATEADD(hour, -3, current_timestamp())
and documentno not in ('1685009','1685974')
;;
    }

  dimension_group: date_rec {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_REC" ;;}

    # dimension_group: date_synced {
    #   type: time
    #   timeframes: [raw, time, date, week, month, quarter, year]
    #   datatype: timestamp
    #   sql: ${formatted_date_sync} ;;
    # }

    # dimension_group: formatted_date_sync {
    #   type: time
    #   timeframes: [raw, time, date, week, month, quarter, year]
    #   convert_tz: yes
    #   value_format: "%Y-%m-%d %H:%M:%S.%f"  # Format to match your timestamp
    #   sql: CONVERT_TIMEZONE('UTC', ${TABLE}."DATE_SYNCED") ;;
    # }

    # dimension_group: order_date{
    # type: time
    # timeframes: [date, week, month, year]
    # datatype: date
    # sql: ${TABLE}.order_date;;

    # }



    # dimension_group: date_synced {
    #   type: time

    #   sql: ${TABLE}."DATE_SYNCED" ;;
    # }

    # dimension: timestamp_date_sync {
    #   type: time
    #   sql: ${TABLE}.date_sync ;;
    #   convert_tz: no
    #   timeframes: [hour, day, week, month, year]
    # }
    dimension: DOCUMENTNO {
      type: string
      sql: ${TABLE}."DOCUMENTNO" ;;
    }
    # dimension: po_number {
    #   type: string
    #   sql: ${TABLE}."PO_NUMBER" ;;
    # }
    measure: count {
      type: count
    }


 }
