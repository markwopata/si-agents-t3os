view: ap_accrual_rev_entry {
  derived_table: {
    sql: SELECT
    'GJ'                                                                                  AS JOURNAL,
    CAST({% date_end date_filter %} AS DATE)                                                            AS DATE,
    CAST({% date_end date_filter %} AS DATE) + 1                                                        AS REVERSEDATE,
    CONCAT('AP ACCRUAL MONTH END ENTRY ', TO_CHAR(CAST({% date_end date_filter %} AS DATE), 'YYYY-mm')) AS DESCRIPTION,
    AL.ACCOUNT                                                                            AS ACCT_NO,
    AL.ENTITY                                                                             AS LOCATION_ID,
    AL.LOCATION                                                                           AS DEPT_ID,
    EL.NAME                                                                               AS EXPENSE_LINE,
    LN.NAME                                                                               AS LOAN,
    TI.NAME                                                                               AS TRANS_IDENTIFIER,
    CONCAT('APAccrual;Vendor_ID;', AL.VENDOR_ID, ';Vendor_Name;', AL.VENDOR_NAME, ';PO_Number;',
           COALESCE(CASE WHEN AL.PO_NUMBER = 'nan' THEN NULL ELSE AL.PO_NUMBER END, ''), ';Bill_Number;',
           COALESCE(AL.BILL_NUMBER, ''))                                                  AS MEMO,
    CASE WHEN ROUND(AL.LINE_AMOUNT, 2) > 0 THEN ABS(ROUND(AL.LINE_AMOUNT, 2)) END         AS DEBIT,
    CASE WHEN ROUND(AL.LINE_AMOUNT, 2) < 0 THEN ABS(ROUND(AL.LINE_AMOUNT, 2)) END         AS CREDIT,
    AL.SOURCE                                                                             AS SOURCE
FROM
    (SELECT
         APH.VENDORID                    AS VENDOR_ID,
         VEND.NAME                       AS VENDOR_NAME,
         APH.RECORDID                    AS BILL_NUMBER,
         APH.WHENCREATED                 AS BILL_DATE,
         APH.WHENPOSTED                  AS DATE_POSTED,
         APH.DOCNUMBER                   AS PO_NUMBER,
         APL.ACCOUNTNO                   AS ACCOUNT,
         APL.LOCATIONID                  AS ENTITY,
         APL.DEPARTMENTID                AS LOCATION,
         APL.GLDIMEXPENSE_LINE           AS EXPENSE_LINE,
         APL.AMOUNT                      AS LINE_AMOUNT,
         APL.GLDIMUD_LOAN                AS LOAN,
         APL.GLDIMTRANSACTION_IDENTIFIER AS TRANS_IDENTIFIER,
         '01_INTACCT'                    AS SOURCE
     FROM
         ANALYTICS.INTACCT.APRECORD APH
             LEFT JOIN ANALYTICS.INTACCT.APDETAIL APL ON APH.RECORDNO = APL.RECORDKEY
             LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
     WHERE
           APH.RECORDTYPE = 'apbill'
       AND APH.WHENCREATED <= {% date_end date_filter %}
       AND APH.WHENPOSTED > {% date_end date_filter %}
       AND APL.LOCATIONID = 'E1'

     UNION ALL

     SELECT DISTINCT
         --DSPA.REQUEST_ID,
         DSPA.VENDOR_ID        AS VENDOR_ID,
         VEND.NAME             AS VENDOR_NAME,
         DSPA.INVOICE_NUMBER   AS BILL_NUMBER,
         DSPA.INVOICE_DATE     AS BILL_DATE,
         '2023-12-01'          AS DATE_POSTED,
         DSPA.HEADER_PO_NUMBER AS PO_NUMBER,
         '1310'                AS ACCOUNT,
         'E1'                  AS ENTITY,
         MIN(DSPA.DEPT_ID)     AS LOCATION,
         NULL                  AS EXPENSE_LINE,
         DSPA.SHIPPING_AMOUNT  AS LINE_AMOUNT,
         NULL                  AS LOAN,
         NULL                  AS TRANS_IDENTIFIER,
         '03_CONCUR_INV_FRT'   AS SOURCE
     FROM
         ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL DSPA
             JOIN (SELECT
                       MAX(COGNOS_DATE) AS MOST_RECENT
                   FROM
                       ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL) LAST
                  ON DSPA.COGNOS_DATE = LAST.MOST_RECENT
             LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM NEW_ITEM
                       ON DSPA.ITEM_ID = NEW_ITEM.OG_ITEM_ID
             LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON DSPA.VENDOR_ID = VEND.VENDORID
             JOIN(SELECT DISTINCT
                      REQUEST_ID
                  FROM
                      ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL DSPA
                          JOIN (SELECT
                                    MAX(COGNOS_DATE) AS MOST_RECENT
                                FROM
                                    ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL) LAST
                               ON DSPA.COGNOS_DATE = LAST.MOST_RECENT
                          LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM NEW_ITEM
                                    ON DSPA.ITEM_ID = NEW_ITEM.OG_ITEM_ID
                  WHERE
                        COALESCE(NEW_ITEM.NEW_ITEM_ID, DSPA.ITEM_ID) = 'A1301'
                    AND DSPA.INVOICE_DATE <= {% date_end date_filter %}) INV_LINES
                 ON DSPA.REQUEST_ID = INV_LINES.REQUEST_ID
     GROUP BY
         DSPA.REQUEST_ID,
         DSPA.VENDOR_ID,
         VEND.NAME,
         DSPA.INVOICE_NUMBER,
         DSPA.INVOICE_DATE,
         DSPA.HEADER_PO_NUMBER,
         DSPA.SHIPPING_AMOUNT

     UNION ALL

     SELECT
         PBA.VENDOR_ID                      AS VENDOR_ID,
         VEND.NAME                          AS VENDOR_NAME,
         PBA.INVOICE_NUMBER                 AS BILL_NUMBER,
         PBA.INVOICE_DATE                   AS BILL_DATE,
         '2023-12-01'                      AS DATE_POSTED,
         CASE
             WHEN PBA.PO_LINE_PO_NUMBER = 'nan' THEN NULL
             ELSE PBA.PO_LINE_PO_NUMBER END AS PO_NUMBER,
         SUBSTR(CASE
                    WHEN NEW_ITEM.NEW_ITEM_ID IS NULL
                        THEN (CASE WHEN LEFT(PBA.ITEM_ID, 1) != 'A' THEN NULL ELSE PBA.ITEM_ID END)
                    ELSE NEW_ITEM.NEW_ITEM_ID END, 2,
                10)                         AS ACCOUNT,
         'E1'                               AS ENTITY,
         PBA.DEPT_ID                        AS LOCATION,
         PBA.EXPENSE_LINE                   AS EXPENSE_LINE,
--     PBA.QUANTITY * PBA.UNIT_PRICE                                             AS LINE_AMOUNT,
--     CASE WHEN INV_BILLS.REQUEST_ID IS NULL THEN 'No' ELSE 'Yes' END           AS X_BILL_HAS_INV_LINE,
--     CASE
--         WHEN BILL_TOTS.TOTAL_EXC_TAXFRT = 0 THEN 0
--         ELSE (PBA.QUANTITY * PBA.UNIT_PRICE) / BILL_TOTS.TOTAL_EXC_TAXFRT END AS X_LINE_SPREAD,
--     ROUND(LINE_AMOUNT + ((LINE_SPREAD) * BILL_TOTS.TAX_AMOUNT) +
--           CASE WHEN INV_BILLS.REQUEST_ID IS NULL THEN ((LINE_SPREAD) * BILL_TOTS.SHIPPING_AMOUNT) ELSE 0 END,
--           2)                                                                  AS X_LINE_AMT,
--     ROUND((PBA.QUANTITY * PBA.UNIT_PRICE) + ((CASE
--                                                   WHEN BILL_TOTS.TOTAL_EXC_TAXFRT = 0 THEN 0
--                                                   ELSE (PBA.QUANTITY * PBA.UNIT_PRICE) / BILL_TOTS.TOTAL_EXC_TAXFRT END) *
--                                              BILL_TOTS.TAX_AMOUNT) +
--           CASE
--               WHEN INV_BILLS.REQUEST_ID IS NULL THEN ((CASE
--                                                            WHEN BILL_TOTS.TOTAL_EXC_TAXFRT = 0 THEN 0
--                                                            ELSE (PBA.QUANTITY * PBA.UNIT_PRICE) / BILL_TOTS.TOTAL_EXC_TAXFRT END) *
--                                                       BILL_TOTS.SHIPPING_AMOUNT)
--               ELSE 0 END,
--           2)                           AS LINE_AMT_RAW,
         ROUND(COALESCE((ROUND((PBA.QUANTITY * PBA.UNIT_PRICE) + ((CASE
                                                                       WHEN BILL_TOTS.TOTAL_EXC_TAXFRT = 0 THEN 0
                                                                       ELSE (PBA.QUANTITY * PBA.UNIT_PRICE) / BILL_TOTS.TOTAL_EXC_TAXFRT END) *
                                                                  BILL_TOTS.TAX_AMOUNT) +
                               CASE
                                   WHEN INV_BILLS.REQUEST_ID IS NULL THEN ((CASE
                                                                                WHEN BILL_TOTS.TOTAL_EXC_TAXFRT = 0
                                                                                    THEN 0
                                                                                ELSE (PBA.QUANTITY * PBA.UNIT_PRICE) / BILL_TOTS.TOTAL_EXC_TAXFRT END) *
                                                                           BILL_TOTS.SHIPPING_AMOUNT)
                                   ELSE 0 END,
                               2)) - (PBA.QUANTITY * RECPT_BALANCE.PO_LINE_UNIT_PRICE),
                        (ROUND((PBA.QUANTITY * PBA.UNIT_PRICE) + ((CASE
                                                                       WHEN BILL_TOTS.TOTAL_EXC_TAXFRT = 0 THEN 0
                                                                       ELSE (PBA.QUANTITY * PBA.UNIT_PRICE) / BILL_TOTS.TOTAL_EXC_TAXFRT END) *
                                                                  BILL_TOTS.TAX_AMOUNT) +
                               CASE
                                   WHEN INV_BILLS.REQUEST_ID IS NULL THEN ((CASE
                                                                                WHEN BILL_TOTS.TOTAL_EXC_TAXFRT = 0
                                                                                    THEN 0
                                                                                ELSE (PBA.QUANTITY * PBA.UNIT_PRICE) / BILL_TOTS.TOTAL_EXC_TAXFRT END) *
                                                                           BILL_TOTS.SHIPPING_AMOUNT)
                                   ELSE 0 END,
                               2))),
               2)                           AS LINE_AMOUNT,
         NULL                               AS LOAN,
         NULL                               AS TRANS_IDENTIFIER,
         '02_CONCUR_DELTA'                  AS SOURCE
     FROM
         ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL PBA
             JOIN (SELECT MAX(COGNOS_DATE) AS MOST_RECENT FROM ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL) LAST
                  ON PBA.COGNOS_DATE = LAST.MOST_RECENT
             LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON PBA.VENDOR_ID = VEND.VENDORID
             LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM NEW_ITEM ON PBA.ITEM_ID = NEW_ITEM.OG_ITEM_ID
             LEFT JOIN(SELECT DISTINCT
                           REQUEST_ID
                       FROM
                           ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL DSPA
                               JOIN (SELECT
                                         MAX(COGNOS_DATE) AS MOST_RECENT
                                     FROM
                                         ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL) LAST
                                    ON DSPA.COGNOS_DATE = LAST.MOST_RECENT
                               LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM NEW_ITEM
                                         ON DSPA.ITEM_ID = NEW_ITEM.OG_ITEM_ID
                       WHERE
                           COALESCE(NEW_ITEM.NEW_ITEM_ID, DSPA.ITEM_ID) = 'A1301') INV_BILLS
                      ON PBA.REQUEST_ID = INV_BILLS.REQUEST_ID
             LEFT JOIN(SELECT
                           DSPA.REQUEST_ID,
                           DSPA.SHIPPING_AMOUNT,
                           DSPA.TAX_AMOUNT,
                           SUM(DSPA.QUANTITY * DSPA.UNIT_PRICE)                                          AS TOTAL_EXC_TAXFRT,
                           SUM(DSPA.QUANTITY * DSPA.UNIT_PRICE) + DSPA.SHIPPING_AMOUNT + DSPA.TAX_AMOUNT AS TOTAL
                       FROM
                           ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL DSPA
                               JOIN (SELECT
                                         MAX(COGNOS_DATE) AS MOST_RECENT
                                     FROM
                                         ANALYTICS.CONCUR.DAILY_SNAPSHOT_PENDING_APPROVAL) LAST
                                    ON DSPA.COGNOS_DATE = LAST.MOST_RECENT
                               LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM NEW_ITEM
                                         ON DSPA.ITEM_ID = NEW_ITEM.OG_ITEM_ID
                       GROUP BY
                           DSPA.REQUEST_ID,
                           DSPA.SHIPPING_AMOUNT,
                           DSPA.TAX_AMOUNT) BILL_TOTS ON PBA.REQUEST_ID = BILL_TOTS.REQUEST_ID
             LEFT JOIN(SELECT
                           PD.CUSTVENDID                                                            AS VENDOR_ID,
                           PD.DOCNO                                                                 AS PO_NUMBER,
                           PDE.RECORDNO                                                             AS PO_LINE_RECORDNO,
                           SUBSTR(COALESCE(ITM_TRANS.NEW_ITEM_ID, PDE.ITEMID), 2, 4)                AS ACCOUNT,
                           PDE.GLDIMEXPENSE_LINE                                                    AS EXP_LINE_ID,
                           PDE.DEPARTMENTID                                                         AS DEPT_ID,
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
                                                VI_CPO.DOCPARID IN
                                                ('Vendor Invoice', 'Closed Purchase Order', 'Closed PO Non Posting')
                                            AND VI_CPO.CREATEDFROM IS NOT NULL
                                            AND VI_CPOD.SOURCE_DOCLINEKEY IS NOT NULL
                                          GROUP BY
                                              VI_CPO.CREATEDFROM,
                                              VI_CPOD.SOURCE_DOCLINEKEY) VI_OR_PO_QTY_CONV
                                         ON PD.DOCID = VI_OR_PO_QTY_CONV.SOURCE_PO_DOCID AND
                                            PDE.RECORDNO =
                                            VI_OR_PO_QTY_CONV.SOURCE_PO_LINE_RECORDNO
                               LEFT JOIN ANALYTICS.FINANCIAL_SYSTEMS.OGITEM_TO_NEWITEM ITM_TRANS
                                         ON PDE.ITEMID = ITM_TRANS.OG_ITEM_ID
                       WHERE
                             PD.DOCPARID = 'Purchase Order'
                         AND (CAST(CONVERT_TIMEZONE('America/Chicago', PD.AUWHENCREATED) AS DATE) > '2023-10-15' OR
                              PD.T3_PR_CREATED_BY IS NOT NULL)
                         AND EXT_COST_REMAIN != 0) RECPT_BALANCE ON PBA.PO_LINE_PO_NUMBER = RECPT_BALANCE.PO_NUMBER AND
                                                                    PBA.PO_LINE_RECORDNO =
                                                                    RECPT_BALANCE.PO_LINE_RECORDNO
     WHERE
           CAST(PBA.INVOICE_DATE AS DATE) <= {% date_end date_filter %}
       AND SUBSTR(CASE
                      WHEN NEW_ITEM.NEW_ITEM_ID IS NULL
                          THEN (CASE WHEN LEFT(PBA.ITEM_ID, 1) != 'A' THEN NULL ELSE PBA.ITEM_ID END)
                      ELSE NEW_ITEM.NEW_ITEM_ID END, 2, 10) IS NOT NULL) AL
        LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE EL ON AL.EXPENSE_LINE = EL.ID
        LEFT JOIN ANALYTICS.INTACCT.UD_LOAN LN ON AL.LOAN = LN.ID
        LEFT JOIN ANALYTICS.INTACCT.TRANSACTION_IDENTIFIER TI ON AL.TRANS_IDENTIFIER = TI.ID
WHERE
      ROUND(AL.LINE_AMOUNT, 2) != 0
  AND SOURCE != '02_CONCUR_DELTA'
  AND AL.ACCOUNT != '2014'
ORDER BY
    AL.VENDOR_ID ASC,
    AL.BILL_NUMBER ASC,
    AL.SOURCE ASC;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: date {
    convert_tz: no
   type: date
   sql: ${TABLE}."DATE" ;;
  }

  dimension: reversedate {
   convert_tz: no
    type: date
    sql: ${TABLE}."REVERSEDATE" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: acct_no {
    type: string
    sql: ${TABLE}."ACCT_NO" ;;
  }

  dimension: location_id {
   type: string
   sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: dept_id {
   type: string
    sql: ${TABLE}."DEPT_ID" ;;
  }

  dimension: expense_line {
   type: string
    sql: ${TABLE}."EXPENSE_LINE" ;;
  }

  dimension: loan {
   type: string
    sql: ${TABLE}."LOAN" ;;
  }

  dimension: trans_identifier {
    type: string
    sql: ${TABLE}."TRANS_IDENTIFIER" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  measure: debit {
    type: sum
    sql: ${TABLE}."DEBIT" ;;
  }
  measure: credit {
    type: sum
    sql: ${TABLE}."CREDIT" ;;
  }
  dimension: source {
   type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  set: detail {
    fields: [
     journal,
     date,
     reversedate,
     description,
     acct_no,
     location_id,
     dept_id,
     expense_line,
     loan,
     trans_identifier,
     memo,
     debit,
     credit,
     source
    ]
  }

 filter: date_filter {
  convert_tz: no
   type: date
  }
}
