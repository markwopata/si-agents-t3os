view: concur_bill_detail_with_tax_frt {
  derived_table: {
    sql: SELECT
          CVIE.REQUEST_KEY                                                         AS CONCUR_REQUEST_KEY,
          CVIE.REQUEST_ID                                                          AS CONCUR_IMAGE_ID,
          CVIE.INVOICE_DATE                                                        AS BILL_DATE,
          CASE
               WHEN CVIE.INVOICE_DATE <= LCD.LAST_CLOSED_DATE THEN LCD.LAST_CLOSED_DATE + 1
               ELSE CVIE.INVOICE_DATE END                                          AS DATE_POSTED,
          YEAR(CVIE.INVOICE_DATE)                                                  AS DATECREATED_YEAR,
          MONTH(CVIE.INVOICE_DATE)                                                 AS DATECREATED_MONTH,
          DAY(CVIE.INVOICE_DATE)                                                   AS DATECREATED_DAY,
          YEAR(CASE
                   WHEN CVIE.INVOICE_DATE <= LCD.LAST_CLOSED_DATE THEN LCD.LAST_CLOSED_DATE + 1
                   ELSE CVIE.INVOICE_DATE END)                                     AS DATEPOSTED_YEAR,
          MONTH(CASE
                    WHEN CVIE.INVOICE_DATE <= LCD.LAST_CLOSED_DATE THEN LCD.LAST_CLOSED_DATE + 1
                    ELSE CVIE.INVOICE_DATE END)                                    AS DATEPOSTED_MONTH,
          DAY(CASE
                  WHEN CVIE.INVOICE_DATE <= LCD.LAST_CLOSED_DATE THEN LCD.LAST_CLOSED_DATE + 1
                  ELSE CVIE.INVOICE_DATE END)                                      AS DATEPOSTED_DAY,
          CASE
              WHEN CVIE.POLICY_NAME = '*Equipmentshare PO Policy' AND REQ_CONV_TO_PYBL.REQUESTKEY IS NULL THEN 'YES'
              ELSE 'NO' END                                                        AS MATCHED,
          CASE
              WHEN CVIE.POLICY_NAME = '*Equipmentshare PO Policy' AND REQ_CONV_TO_PYBL.REQUESTKEY IS NULL THEN
                  CONCAT('Purchase Order-', CVIE.LINE_ITEM_PURCHASE_ORDER)
              ELSE NULL END                                                        AS CREATEDFROM,
          CVIE.VENDOR_CODE                                                         AS VENDORID,
          VEND.NAME                                                                AS VENDOR_NAME,
          CVIE.LINE_ITEM_PURCHASE_ORDER                                            AS REFERENCENO,
          CONCAT(CVIE.VENDOR_INVOICE_NUMBER,
                 IFNULL(VEND_INV_SUF.INV_SUFFIX, ''))                              AS VENDORDOCNO,
          CASE
              WHEN (VEND_INV_SUF.INV_SFX1 = 1 OR VEND_INV_SUF.INV_SFX1 IS NULL) THEN CVIE.SHIPPING_AMOUNT
              ELSE 0 END                                                           AS FRT_AMT_TOT,
          CVIE.ASSOCIATED_PO_LINE_ITEM_EXTERNAL_ID                                 AS LINE_PO_KEY,
          CVIE.JOURNAL_ACCOUNT_CODE                                                AS ITEM_ID,
          CVIE.COL_141                                                             AS ITEM_DESC,
          CVIE.LINE_ITEM_CUSTOM_1                                                  AS BRANCH,
          CVIE.LINE_ITEM_DESCRIPTION                                               AS MEMO,
          CVIE.LINE_ITEM_QUANTITY                                                  AS QTY,
          ROUND((((CASE
                       WHEN CVIE.DEBIT_OR_CREDIT = 'DR' THEN CVIE.JOURNAL_GROSS_AMOUNT
                       ELSE (CVIE.JOURNAL_GROSS_AMOUNT * -1) END) - CVIE.PRORATED_SHIPPING) / CVIE.LINE_ITEM_QUANTITY),
                6)                                                                 AS UNIT_PRICE_OLD,
          CVIE.LINE_ITEM_AMOUNT_WITHOUT_VAT / CVIE.LINE_ITEM_QUANTITY              AS UNIT_PRICE,
          CVIE.LINE_ITEM_AMOUNT_WITHOUT_VAT + CVIE.PRORATED_SHIPPING + (ROUND((((CASE
                        WHEN CVIE.DEBIT_OR_CREDIT = 'DR' THEN CVIE.JOURNAL_GROSS_AMOUNT
                        ELSE (CVIE.JOURNAL_GROSS_AMOUNT * -1) END) -
                   CVIE.PRORATED_SHIPPING) / CVIE.LINE_ITEM_QUANTITY),
                 6) * CVIE.LINE_ITEM_QUANTITY) - CVIE.LINE_ITEM_AMOUNT_WITHOUT_VAT AS TOTAL,
          CVIE.LINE_ITEM_AMOUNT_WITHOUT_VAT                                        AS EXT_COST,
          CVIE.PRORATED_SHIPPING                                                   AS FREIGHT,
          (ROUND((((CASE
                        WHEN CVIE.DEBIT_OR_CREDIT = 'DR' THEN CVIE.JOURNAL_GROSS_AMOUNT
                        ELSE (CVIE.JOURNAL_GROSS_AMOUNT * -1) END) -
                   CVIE.PRORATED_SHIPPING) / CVIE.LINE_ITEM_QUANTITY),
                 6) * CVIE.LINE_ITEM_QUANTITY) - CVIE.LINE_ITEM_AMOUNT_WITHOUT_VAT AS TAX,
          CVIE.BATCH_ID                                                            AS BATCH_ID,
          CVIE.BATCH_DATE                                                          AS BATCH_DATE,
          CVIE.EMPLOYEE_ID                                                         AS EMPLOYEE,
          CVIE.POLICY_NAME                                                         AS POLICY_NAME,
          ITEM_TO_GL.ACCOUNT                                                       AS ACCOUNT,
          COA.TITLE                                                                AS ACCOUNT_NAME
      FROM
          ANALYTICS.CONCUR.APPROVED_BILL_DETAIL CVIE
              LEFT JOIN (SELECT
                             LCD1.LAST_CLOSED_DATE
                         FROM
                             "ANALYTICS"."CONCUR"."LAST_CLOSE_DATE_AP" LCD1
                                 JOIN (SELECT MAX(LAST_MODIFIED) AS "MAX" FROM "ANALYTICS"."CONCUR"."LAST_CLOSE_DATE_AP") LCD2
                                      ON LCD1.LAST_MODIFIED = LCD2.MAX) LCD
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON CVIE.VENDOR_CODE = VEND.VENDORID
              LEFT JOIN (SELECT
                             BILL_PO_COUNT.REQUEST_KEY,
                             BILL_PO_NUM.LINE_ITEM_PURCHASE_ORDER,
                             BILL_PO_NUM.INV_SFX1,
                             CONCAT(' (', BILL_PO_NUM.INV_SFX1, ' of ', COUNT(BILL_PO_COUNT.LINE_ITEM_PURCHASE_ORDER),
                                    ')') AS INV_SUFFIX
                         FROM
                             (SELECT DISTINCT
                                  REQUEST_KEY,
                                  VENDOR_INVOICE_NUMBER,
                                  LINE_ITEM_PURCHASE_ORDER
                              FROM
                                  ANALYTICS.CONCUR.APPROVED_BILL_DETAIL) BILL_PO_COUNT
                                 JOIN
                                 (SELECT
                                      BILL_PO_COUNT.REQUEST_KEY,
                                      BILL_PO_COUNT.VENDOR_INVOICE_NUMBER,
                                      BILL_PO_COUNT.LINE_ITEM_PURCHASE_ORDER,
                                      RANK()
                                              OVER (PARTITION BY BILL_PO_COUNT.REQUEST_KEY ORDER BY BILL_PO_COUNT.LINE_ITEM_PURCHASE_ORDER ASC) AS INV_SFX1
                                  FROM
                                      (SELECT DISTINCT
                                           REQUEST_KEY,
                                           VENDOR_INVOICE_NUMBER,
                                           LINE_ITEM_PURCHASE_ORDER
                                       FROM
                                           ANALYTICS.CONCUR.APPROVED_BILL_DETAIL) BILL_PO_COUNT) BILL_PO_NUM
                                 ON BILL_PO_COUNT.REQUEST_KEY = BILL_PO_NUM.REQUEST_KEY
                         GROUP BY
                             BILL_PO_COUNT.REQUEST_KEY,
                             BILL_PO_NUM.LINE_ITEM_PURCHASE_ORDER,
                             BILL_PO_NUM.INV_SFX1
                         HAVING
                             COUNT(BILL_PO_COUNT.LINE_ITEM_PURCHASE_ORDER) > 1) VEND_INV_SUF
                        ON CVIE.REQUEST_KEY = VEND_INV_SUF.REQUEST_KEY AND
                           CVIE.LINE_ITEM_PURCHASE_ORDER = VEND_INV_SUF.LINE_ITEM_PURCHASE_ORDER
              LEFT JOIN (SELECT DISTINCT
                             VIE3.REQUEST_KEY,
                             VIE3.PO_NUMBER,
                             CASE
                                 WHEN VIE3.TOTAL_AMOUNT = INTPO3.AMOUNT_PENDING THEN 'CONVERT_PO'
                                 ELSE 'CONVERT_EXTRACT' END AS MATCH_TYPE
                         FROM
                             ANALYTICS.CONCUR.APPROVED_BILL_DETAIL VIE3
                                 LEFT JOIN(SELECT
                                               POH.DOCNO,
                                               POH.CUSTVENDID,
                                               SUM((POL.UIQTY - POL.QTY_CONVERTED) * POL.UIPRICE) AS AMOUNT_PENDING
                                           FROM
                                               ANALYTICS.INTACCT.PODOCUMENT POH
                                                   LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL ON POH.DOCID = POL.DOCHDRID
                                           WHERE
                                               POH.DOCPARID = 'Purchase Order'
                                           GROUP BY
                                               POH.DOCNO, POH.CUSTVENDID) INTPO3
                                          ON VIE3.PO_NUMBER = INTPO3.DOCNO AND VIE3.VENDOR_CODE = INTPO3.CUSTVENDID
                         WHERE
                               VIE3.REQUEST_CUSTOM_7 = 'Y'
                           AND VIE3.PO_NUMBER IS NOT NULL) VI_MATCH_TYPE ON CVIE.REQUEST_KEY = VI_MATCH_TYPE.REQUEST_KEY
              LEFT JOIN (SELECT
                             POCRK.CONCUR_REQUEST_KEY
                         FROM
                             ANALYTICS.INTACCT.PODOCUMENT POCRK
                         WHERE
                               POCRK.DOCPARID = 'Vendor Invoice'
                           AND POCRK.CONCUR_REQUEST_KEY IS NOT NULL) POCRK2
      --                   ON VI_MATCH_TYPE.REQUEST_KEY = POCRK2.CONCUR_REQUEST_KEY
                        ON CVIE.REQUEST_KEY = POCRK2.CONCUR_REQUEST_KEY
              LEFT JOIN ANALYTICS.INTACCT.APRECORD APH
                        ON CVIE.VENDOR_CODE = APH.VENDORID AND CONCAT(CVIE.VENDOR_INVOICE_NUMBER,
                                                                      IFNULL(VEND_INV_SUF.INV_SUFFIX, '')) = APH.RECORDID
              LEFT JOIN ANALYTICS.CONCUR.SYNC_LOG_VI SLVI
                        ON CVIE.REQUEST_KEY = SLVI.CONCUR_REQUEST_KEY AND CONCAT(CVIE.VENDOR_INVOICE_NUMBER,
                                                                                 IFNULL(VEND_INV_SUF.INV_SUFFIX, '')) =
                                                                          SLVI.BILL_NUMBER
              LEFT JOIN(SELECT DISTINCT
                            CONCUR_REQUEST_KEY AS REQUESTKEY
                        FROM
                            ANALYTICS.CONCUR.CONCUR_EXCEPTIONS
                        WHERE
                              OVERRIDE_TYPE = 'CONV_TO_PYBL'
                          AND OBJECT_TYPE = 'VI'
                          AND ACTIVE = TRUE) AS REQ_CONV_TO_PYBL ON CVIE.REQUEST_KEY = REQ_CONV_TO_PYBL.REQUESTKEY
              LEFT JOIN(SELECT DISTINCT
                            CONCUR_REQUEST_KEY AS REQUESTKEY
                        FROM
                            ANALYTICS.CONCUR.CONCUR_EXCEPTIONS
                        WHERE
                              OVERRIDE_TYPE = 'DO_NOT_SYNC'
                          AND OBJECT_TYPE = 'VI'
                          AND ACTIVE = TRUE) AS REQ_DO_NOT_SYNC ON CVIE.REQUEST_KEY = REQ_DO_NOT_SYNC.REQUESTKEY
              LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.ITEMID_TO_GL_ACCOUNT ITEM_TO_GL
                  ON CVIE.JOURNAL_ACCOUNT_CODE = ITEM_TO_GL.ITEM_ID
              LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT COA ON ITEM_TO_GL.ACCOUNT = COA.ACCOUNTNO
      WHERE
      --       (VI_MATCH_TYPE.MATCH_TYPE != 'CONVERT_PO' OR VI_MATCH_TYPE.MATCH_TYPE IS NULL)
      POCRK2.CONCUR_REQUEST_KEY IS NOT NULL
      AND CVIE.LINE_ITEM_QUANTITY != 0
      --   AND APH.RECORDNO IS NULL
      --   AND CVIE.LINE_ITEM_QUANTITY != 0
      --   AND SLVI.CONCUR_REQUEST_KEY IS NULL
      --   AND REQ_DO_NOT_SYNC.REQUESTKEY IS NULL
      --   AND VEND.STATUS = 'active'
      --   AND CVIE.REQUEST_KEY = '148961'
      ORDER BY
          CVIE.REQUEST_KEY,
          CONCAT(CVIE.VENDOR_INVOICE_NUMBER,
                 IFNULL(VEND_INV_SUF.INV_SUFFIX, ''))
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: concur_request_key {
    type: number
    sql: ${TABLE}."CONCUR_REQUEST_KEY" ;;
  }

  dimension: concur_image_id {
    type: string
    sql: ${TABLE}."CONCUR_IMAGE_ID" ;;
  }

  dimension: bill_date {
    type: date
    sql: ${TABLE}."BILL_DATE" ;;
  }

  dimension: date_posted {
    type: date
    sql: ${TABLE}."DATE_POSTED" ;;
  }

  dimension: datecreated_year {
    type: number
    sql: ${TABLE}."DATECREATED_YEAR" ;;
  }

  dimension: datecreated_month {
    type: number
    sql: ${TABLE}."DATECREATED_MONTH" ;;
  }

  dimension: datecreated_day {
    type: number
    sql: ${TABLE}."DATECREATED_DAY" ;;
  }

  dimension: dateposted_year {
    type: number
    sql: ${TABLE}."DATEPOSTED_YEAR" ;;
  }

  dimension: dateposted_month {
    type: number
    sql: ${TABLE}."DATEPOSTED_MONTH" ;;
  }

  dimension: dateposted_day {
    type: number
    sql: ${TABLE}."DATEPOSTED_DAY" ;;
  }

  dimension: matched {
    type: string
    sql: ${TABLE}."MATCHED" ;;
  }

  dimension: createdfrom {
    type: string
    sql: ${TABLE}."CREATEDFROM" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDORID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: referenceno {
    type: string
    sql: ${TABLE}."REFERENCENO" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."VENDORDOCNO" ;;
  }

  dimension: frt_amt_tot {
    type: number
    sql: ${TABLE}."FRT_AMT_TOT" ;;
  }

  dimension: line_po_key {
    type: string
    sql: ${TABLE}."LINE_PO_KEY" ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }

  dimension: item_desc {
    type: string
    sql: ${TABLE}."ITEM_DESC" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: qty {
    type: number
    sql: ${TABLE}."QTY" ;;
  }

  dimension: unit_price_old {
    type: number
    sql: ${TABLE}."UNIT_PRICE_OLD" ;;
  }

  dimension: unit_price {
    type: number
    sql: ${TABLE}."UNIT_PRICE" ;;
  }

  dimension: total {
    type: number
    sql: ${TABLE}."TOTAL" ;;
  }

  dimension: ext_cost {
    type: number
    sql: ${TABLE}."EXT_COST" ;;
  }

  dimension: freight {
    type: number
    sql: ${TABLE}."FREIGHT" ;;
  }

  dimension: tax {
    type: number
    sql: ${TABLE}."TAX" ;;
  }

  dimension: batch_id {
    type: number
    sql: ${TABLE}."BATCH_ID" ;;
  }

  dimension: batch_date {
    type: date
    sql: ${TABLE}."BATCH_DATE" ;;
  }

  dimension: employee {
    type: string
    sql: ${TABLE}."EMPLOYEE" ;;
  }

  dimension: policy_name {
    type: string
    sql: ${TABLE}."POLICY_NAME" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."ACCOUNT" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  set: detail {
    fields: [
      concur_request_key,
      concur_image_id,
      bill_date,
      date_posted,
      datecreated_year,
      datecreated_month,
      datecreated_day,
      dateposted_year,
      dateposted_month,
      dateposted_day,
      matched,
      createdfrom,
      vendor_id,
      vendor_name,
      referenceno,
      bill_number,
      frt_amt_tot,
      line_po_key,
      item_id,
      item_desc,
      branch,
      memo,
      qty,
      unit_price_old,
      unit_price,
      total,
      ext_cost,
      freight,
      tax,
      batch_id,
      batch_date,
      employee,
      policy_name,
      account,
      account_name
    ]
  }
}
