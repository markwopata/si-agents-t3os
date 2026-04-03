view: cc_open_pos_and_concur_invs {
  derived_table: {
    sql:
SELECT
          VEND.EXTERNAL_ERP_VENDOR_REF                                        AS VENDOR_ID,
          VENDINT.NAME                                                        AS VENDOR_NAME,
          POH.PURCHASE_ORDER_NUMBER                                           AS PO_NUMBER,
          CAST(CONVERT_TIMEZONE('America/Chicago', POH.DATE_CREATED) AS DATE) AS DATE,
          BERP1.INTACCT_DEPARTMENT_ID                                         AS BRANCH_ID,
          CONCAT(BERP1.INTACCT_DEPARTMENT_ID, ' - ', BRCH1.NAME)              AS BRANCH,
          CONCAT(USER1.FIRST_NAME, ' ', USER1.LAST_NAME)                      AS CREATED_BY_NAME,
          USER1.EMAIL_ADDRESS                                                 AS CREATED_BY_EMAIL,
          GM.GM                                                               AS GM_NAME,
          GM.EMAIL                                                            AS GM_EMAIL,
          POH.STATUS                                                          AS PO_STATUS,
          CASE WHEN CONC_PO_POLICY.POLICY IS NULL THEN FALSE ELSE TRUE END    AS CONCUR_PO_INV,
          CASE WHEN CONC_INV_POLICY.POLICY IS NULL THEN FALSE ELSE TRUE END   AS CONCUR_PAY_INV,
          CASE WHEN CONC_INV_POLICY.POLICY IS NULL THEN 0 ELSE 1 END   AS CONCUR_PAY_INV_IND,
          datediff(day,CAST(CONVERT_TIMEZONE('America/Chicago', POH.DATE_CREATED) AS DATE),current_date) AS AGE_DAYS,
          CONCAT('https://costcapture.estrack.com/purchase-orders/',POH.PURCHASE_ORDER_ID,'/detail') AS URL,
          CONC_INV_POLICY.payment_due_date                      as PAYMENT_DUE_DATE,--kendall added 10/24/23
          CAST(CONVERT_TIMEZONE('America/Chicago', conc_inv_policy.invoice_date) AS DATE) AS invoice_date,
          conc_inv_policy.request_total,
          --conc_inv_policy.invoice_date                          as invoice_date,--kendall added 10/26/23
          conc_inv_policy.supplier_invoice_number               as supplier_invoice_number,
          datediff(day,CAST(CONVERT_TIMEZONE('America/Chicago', invoice_date) AS DATE),current_date) AS invoice_age,
          datediff(day, date, invoice_date) AS days_receipt_waiting_for_invoice,
          invoice_age - AGE_DAYS as invoice_age_delta_po_age

      FROM
          PROCUREMENT.PUBLIC.PURCHASE_ORDERS POH
              LEFT JOIN ES_WAREHOUSE.PUBLIC.USERS USER1 ON POH.CREATED_BY_ID = USER1.USER_ID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.BRANCH_ERP_REFS BERP1 ON POH.REQUESTING_BRANCH_ID = BERP1.BRANCH_ID
              LEFT JOIN ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS VEND ON POH.VENDOR_ID = VEND.ENTITY_ID
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VENDINT ON VEND.EXTERNAL_ERP_VENDOR_REF = VENDINT.VENDORID
              LEFT JOIN ES_WAREHOUSE.PUBLIC.MARKETS BRCH1 ON POH.REQUESTING_BRANCH_ID = BRCH1.MARKET_ID
              LEFT JOIN (SELECT DISTINCT
                             UNSUB.SUPPLIER_CODE                      AS VENDOR_ID,
                             CASE
                                 WHEN UNSUB.PURCHASE_ORDER_NUMBER = 'nan' THEN NULL
                                 ELSE UNSUB.PURCHASE_ORDER_NUMBER END AS PO_NUMBER,
                             UNSUB.POLICY                             AS POLICY,
                            unsub.payment_due_date,--kendall added 10/24/23
                            unsub.invoice_date,
                            unsub.supplier_invoice_number,
                            unsub.request_total

                         FROM
                             ANALYTICS.CONCUR.UNSUBMITTED_INVOICES UNSUB
                         WHERE
                               CAST(UNSUB.COGNOS_DATE AS DATE) = CURRENT_DATE
                           AND UNSUB.PURCHASE_ORDER_NUMBER IS NOT NULL
                           AND UNSUB.PURCHASE_ORDER_NUMBER != 'nan'
                           AND UNSUB.POLICY = 'Equipmentshare Invoice Policy') CONC_INV_POLICY
                        ON VEND.EXTERNAL_ERP_VENDOR_REF = CONC_INV_POLICY.VENDOR_ID
                            AND TO_CHAR(POH.PURCHASE_ORDER_NUMBER) = CONC_INV_POLICY.PO_NUMBER
              LEFT JOIN (SELECT DISTINCT
                             UNSUB.SUPPLIER_CODE                      AS VENDOR_ID,
                             CASE
                                 WHEN UNSUB.PURCHASE_ORDER_NUMBER = 'nan' THEN NULL
                                 ELSE UNSUB.PURCHASE_ORDER_NUMBER END AS PO_NUMBER,
                             UNSUB.POLICY                             AS POLICY
                         FROM
                             ANALYTICS.CONCUR.UNSUBMITTED_INVOICES UNSUB
                         WHERE
                               CAST(UNSUB.COGNOS_DATE AS DATE) = CURRENT_DATE
                           AND UNSUB.PURCHASE_ORDER_NUMBER IS NOT NULL
                           AND UNSUB.PURCHASE_ORDER_NUMBER != 'nan'
                           AND UNSUB.POLICY = 'Equipmentshare PO Policy') CONC_PO_POLICY

--select distinct policy from ANALYTICS.CONCUR.UNSUBMITTED_INVOICES
         -- select * from procurement.public.items where item_type = 'SERVICE'
         -- select * from procurement.public.non_inventory_items where non_inventory_item_id = 'ff7481a3-d2ba-41e4-a6a0-2f40f95cc6a5'
                        ON VEND.EXTERNAL_ERP_VENDOR_REF = CONC_PO_POLICY.VENDOR_ID AND
                           TO_CHAR(POH.PURCHASE_ORDER_NUMBER) = CONC_PO_POLICY.PO_NUMBER
              LEFT JOIN (SELECT
                             GM.MARKET_ID                             AS "MKTID",
                             CONCAT(GM.FIRST_NAME, ' ', GM.LAST_NAME) AS "GM",
                             GM.WORK_EMAIL                            AS "EMAIL",
                             GM.WORK_PHONE                            AS "PHONE",
                             GM.DIRECT_MANAGER_NAME                   AS "GM_SUPERVISOR"
                         FROM
                             "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" GM
                                 JOIN (SELECT
                                           EMP.MARKET_ID,
                                           MIN(EMPLOYEE_ID) AS "GM_ID"
                                       FROM
                                           "ANALYTICS"."PAYROLL"."COMPANY_DIRECTORY" EMP
                                       WHERE
                                             EMP.EMPLOYEE_STATUS = 'Active'
                                         AND EMP.EMPLOYEE_TITLE = 'General Manager'
                                       GROUP BY
                                           EMP.MARKET_ID) GM1 ON GM.EMPLOYEE_ID = GM1.GM_ID) GM
                        ON BERP1.INTACCT_DEPARTMENT_ID = GM.MKTID
      WHERE
          POH.COMPANY_ID = 1854
          and POH.PURCHASE_ORDER_NUMBER not in (
-----------------------added to remove a6000 rerent from -needs refactor
          select SPLIT_PART(documentno, '-', 1)
          from (
SELECT
    -- CASE
    --     WHEN CAST(CONVERT_TIMEZONE('America/Chicago', PRH.DATE_RECEIVED) AS DATE) <= LC.LAST_CLOSED
    --         THEN LC.LAST_CLOSED + 1
    --     ELSE CAST(CONVERT_TIMEZONE('America/Chicago', PRH.DATE_RECEIVED) AS DATE) END                AS DATE_ADJ_OLD,
    -- CASE
    --     WHEN DATE_ADJ_OLD = '2023-12-30' THEN '2023-12-31'
    --     WHEN DATE_ADJ_OLD = '2024-01-03' THEN '2024-01-04'
    --     ELSE DATE_ADJ_OLD END                                                                        AS DATE_ADJ,
    -- YEAR(DATE_ADJ)                                                                                   AS DATECREATED_YEAR,
    -- MONTH(DATE_ADJ)                                                                                  AS DATECREATED_MONTH,
    -- DAY(DATE_ADJ)                                                                                    AS DATECREATED_DAY,
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
  --AND PRH.RECEIVER_TYPE IN ('RECEIPT')
  -- AND ITM.ITEM_TYPE != 'SERVICE'
  -- AND INTPO.DOCNO IS NULL
  -- AND POH.PURCHASE_ORDER_NUMBER IS NOT NULL
  -- AND CONVERT_TIMEZONE('America/Chicago', PRH.DATE_CREATED) <
  --     DATEADD(MINUTE, -12, CONVERT_TIMEZONE('America/Chicago', CURRENT_TIMESTAMP(0)))
  -- AND COALESCE(VEND_REDIRECT.VENDOR_REDIRECT, VEND.EXTERNAL_ERP_VENDOR_REF) IS NOT NULL
  -- AND CASE
  --         WHEN ITM.ITEM_TYPE = 'INVENTORY' THEN COALESCE(BERPR.INTACCT_DEPARTMENT_ID,
  --                                                        TO_CHAR(TRUNC(STR.PARENT_BRANCH_ID, 0)))
  --         ELSE COALESCE(BERPR2.INTACCT_DEPARTMENT_ID, TO_CHAR(TRUNC(POH.REQUESTING_BRANCH_ID, 0))) END IS NOT NULL
  -- AND POH.REQUESTING_BRANCH_ID NOT IN (7521, 55924, 32198, 47399, 32199, 1491, 32200, 32197, 13481)
  -- AND VENDINT.STATUS = 'active'
  --     -- If we get more than 5 errors from a document number it will be ignored
  -- AND DOCUMENTNO NOT IN (SELECT
  --                            DOCUMENT_NUMBER
  --                        FROM
  --                            ANALYTICS.AP_ACCRUAL.CREATE_RECEIPTS_JOB_RESULTS
  --                        WHERE
  --                            RESULT = 'error'
  --                        GROUP BY DOCUMENT_NUMBER
  --                        HAVING
  --                            COUNT(DOCUMENT_NUMBER) > 5)
  --     -- If the document has already been successfully written it is ignored
  -- AND DOCUMENTNO NOT IN (SELECT
  --                            DOCUMENT_NUMBER
  --                        FROM
  --                            ANALYTICS.AP_ACCRUAL.CREATE_RECEIPTS_JOB_RESULTS
  --                        WHERE
  --                            RESULT = 'success')
  -- AND MISS_ITEM_CHK.PURCHASE_ORDER_RECEIVER_ID IS NULL
  -- AND ITEMID NOT IN ('A1310','A6315','A1308')
) where itemid = 'A6000'

   )


       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: request_total {
    type: string
    sql: ${TABLE}."REQUEST_TOTAL" ;;}

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: po_number {
    type: number
    sql: ${TABLE}."PO_NUMBER" ;;
    html:
    <a href="{{ url._value }}" style="color: blue;" target="_blank">{{ value }}</a>
    ;;
  }

  dimension: date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."DATE" ;;
    html:
    {% if age_days._value > 30 %}
    <font color="red">{{rendered_value}}</font>
    {% endif %};;
  }

  dimension: payment_due_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."PAYMENT_DUE_DATE" ;;
  }

  dimension: invoice_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension: supplier_invoice_number {
    type: string
    sql: ${TABLE}."SUPPLIER_INVOICE_NUMBER" ;;
  }


  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: created_by_name {
    type: string
    sql: ${TABLE}."CREATED_BY_NAME" ;;
  }

  dimension: created_by_email {
    type: string
    sql: ${TABLE}."CREATED_BY_EMAIL" ;;
  }

  dimension: gm_name {
    type: string
    sql: ${TABLE}."GM_NAME" ;;
  }

  dimension: gm_email {
    type: string
    sql: ${TABLE}."GM_EMAIL" ;;
  }

  dimension: po_status {
    type: string
    sql: ${TABLE}."PO_STATUS" ;;
  }

  dimension: concur_po_inv {
    type: yesno
    sql: ${TABLE}."CONCUR_PO_INV" ;;
  }

  dimension: concur_pay_inv {
    type: yesno
    sql: ${TABLE}."CONCUR_PAY_INV" ;;
  }

  dimension: concur_pay_inv_ind {
    type: number
    sql: ${TABLE}."CONCUR_PAY_INV_IND" ;;
    }

  dimension: age_days {
    type: number
    sql: ${TABLE}."AGE_DAYS" ;;
  }

  dimension: invoice_age {
    type: number
    sql: ${TABLE}."INVOICE_AGE" ;;
  }

  dimension: days_receipt_waiting_for_invoice {
    type: number
    sql: ${TABLE}."DAYS_RECEIPT_WAITING_FOR_INVOICE" ;;
  }

  dimension: invoice_age_delta_po_age {
    type: number
    sql: ${TABLE}."INVOICE_AGE_DELTA_PO_AGE" ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
    hidden:  yes
  }

    set: detail {
      fields: [
        vendor_id,
        vendor_name,
        po_number,
        date,
        branch_id,
        created_by_name
      ]
    }
  }
