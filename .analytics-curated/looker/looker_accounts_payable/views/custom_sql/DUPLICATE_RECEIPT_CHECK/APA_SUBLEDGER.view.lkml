view: apa_subledger {
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
          (PDE.UIQTY - COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0)) * PDE.UIPRICE AS EXT_COST_REMAIN,
          CHECK_THESE_POS.MESSAGE                                                  AS MESSAGE,
          CASE WHEN TO_CLOSE.PO_NUMBER IS NOT NULL THEN 'Will be closed tomorrow' ELSE NULL END AS CLOSE_FLAG
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
              JOIN (SELECT CHECK_THESE.PO_NUMBER,
                                 CHECK_THESE.MESSAGE
                          FROM
                              (SELECT DISTINCT
                                   INV_CHECK.PO_NUMBER                                                        AS PO_NUMBER,
                                   'This PO references an invoice number that a different PO also references' AS MESSAGE
                               FROM
                                   (SELECT
                                        POH.CUSTVENDID                                                                      AS VENDOR_ID,
                                        POH.DOCNO                                                                           AS PO_NUMBER,
                                        UPPER(POH.PONUMBER)                                                                 AS INVOICE_MEMO,
                                        REGEXP_REPLACE(POH.PONUMBER, '[^\\d]*')                                             AS NUMBER_ONLY,
                                        COUNT(*) OVER (PARTITION BY POH.CUSTVENDID,REGEXP_REPLACE(POH.PONUMBER, '[^\\d]*')) AS TEST
                                    FROM
                                        ANALYTICS.INTACCT.PODOCUMENT POH
                                    WHERE
                                          POH.DOCPARID = 'Purchase Order'
                                      AND POH.PONUMBER IS NOT NULL
                                      AND UPPER(POH.PONUMBER) LIKE ('%INV%')
                                      AND UPPER(POH.PONUMBER) NOT LIKE ('%INVENTORY%')
                          --   AND CAST(CONVERT_TIMEZONE('America/Chicago', POH.AUWHENCREATED) AS DATE) = '2024-05-15'
                                      AND POH.WHENCREATED <= {% date_end as_of_date %}
                                      AND REGEXP_REPLACE(
                                        POH.PONUMBER
                                        , '[^\\d]*') != '') INV_CHECK
                               WHERE
                                   INV_CHECK.TEST != 1

                               UNION

                               SELECT DISTINCT
                                   UNDER_CONVERTED.PO_NUMBER                                                       AS PO_NUMBER,
                                   'The bills converting this receipt are close to the full amount of the receipt' AS MESSAGE
                               FROM
                                   (SELECT
                                        PO_ORIG.VENDOR_ID,
                                        PO_ORIG.PO_NUMBER,
                                        ROUND(PO_ORIG.PO_ORIG_COST, 2)                                                             AS PO_ORIGINAL_COST,
                                        ROUND(CONVERTING_VIS.TOTAL_CONV_TO_VI, 2)                                                  AS VI_CONVERTED_COST,
                                        ROUND(COALESCE(CONVERTING_VIS.TOTAL_CONV_TO_VI, 0) - COALESCE(PO_ORIG.PO_ORIG_COST, 0), 3) AS DIFFERENCE,
                                        ABS(ROUND((COALESCE(CONVERTING_VIS.TOTAL_CONV_TO_VI, 0) - COALESCE(PO_ORIG.PO_ORIG_COST, 0)) /
                                                  (COALESCE(PO_ORIG.PO_ORIG_COST, 0)), 3))                                         AS VARIANCE
                                    FROM
                                        (SELECT
                                             POH.CUSTVENDID               AS VENDOR_ID,
                                             POH.DOCID                    AS DOCID,
                                             POH.DOCNO                    AS PO_NUMBER,
                                             POH.WHENCREATED              AS POST_DATE,
                                             SUM(POL.UIQTY * POL.UIPRICE) AS PO_ORIG_COST
                                         FROM
                                             ANALYTICS.INTACCT.PODOCUMENT POH
                                                 LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY POL ON POH.DOCID = POL.DOCHDRID
                                         WHERE
                                               POH.DOCPARID = 'Purchase Order'
                                           AND (POH.T3_PR_CREATED_BY IS NOT NULL
                                             OR CAST(CONVERT_TIMEZONE('America/Chicago', POH.AUWHENCREATED) AS DATE) >= '2023-10-16')
                                         GROUP BY ALL) PO_ORIG
                                            LEFT JOIN (SELECT
                                                           VIL.SOURCE_DOCID,
                                                           COUNT(DISTINCT VIH.DOCID)    AS VI_COUNT,
                                                           SUM(VIL.UIQTY * VIL.UIPRICE) AS TOTAL_CONV_TO_VI
                                                       FROM
                                                           ANALYTICS.INTACCT.PODOCUMENT VIH
                                                               LEFT JOIN ANALYTICS.INTACCT.PODOCUMENTENTRY VIL ON VIH.DOCID = VIL.DOCHDRID
                                                       WHERE
                                                             VIH.DOCPARID = 'Vendor Invoice'
                                                         AND VIL.SOURCE_DOCID IS NOT NULL
                                                         AND VIH.WHENPOSTED <= {% date_end as_of_date %}
                                                       GROUP BY
                                                           VIL.SOURCE_DOCID) CONVERTING_VIS ON PO_ORIG.DOCID = CONVERTING_VIS.SOURCE_DOCID
                                    WHERE
                                          PO_ORIG.PO_ORIG_COST != 0
                                      AND VARIANCE <= 0.5) UNDER_CONVERTED

                               UNION
                                SELECT * FROM(
                                  WITH
                                      DATA AS (SELECT DISTINCT
                                                   DOCHDRID,
                                                   DOCNO,
                                                   REGEXP_EXTRACT_ALL(DOCHDRID, '([^Purchase Order-]+)')      AS PO_NUMBER,
                                                   COUNT(*) OVER (PARTITION BY DOCHDRID)                      AS LINE_COUNT,
                                                   COUNT(DISTINCT DEPARTMENTID) OVER (PARTITION BY DOCHDRID)  AS NUM_DEPT_ON_PO,
                                                   SUM(POE.QTY_REMAINING) OVER (PARTITION BY DOCHDRID)        AS SUM_QTY_REMAINING,
                                                   DEPARTMENTID,
                                                   DEPARTMENTNAME,
                                                   POR.TOTAL,
                                                   POR.CUSTVENDID,
                                                   POR.CUSTVENDNAME,
                                                   POR.T3_PO_CREATED_BY,
                                                   POR.T3_PR_CREATED_BY,
                                                   COALESCE(CAST(POR.AUWHENCREATED AS DATE), POR.WHENCREATED) AS DATE_CREATED
                                               FROM
                                                   ANALYTICS.INTACCT.PODOCUMENTENTRY POE
                                                       LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT POR
                                                                 ON POE.DOCHDRID = POR.DOCID
                                               WHERE
                                                     POE.DOCPARID = 'Purchase Order'
                                                 AND (CAST(CONVERT_TIMEZONE('America/Chicago', POR.AUWHENCREATED) AS DATE) >= '2023-10-16' OR
                                                      POR.T3_PR_CREATED_BY IS NOT NULL)
                                                 AND POR.DOCPARID = 'Purchase Order'
                                                 AND POR.WHENCREATED <= {% date_end as_of_date %}
                                               QUALIFY
                                                   NUM_DEPT_ON_PO = 1
                                               ORDER BY DOCHDRID),
                                      DUPES AS (SELECT
                                                    DOCHDRID,
                                                    DOCNO,
                                                    PO_NUMBER[0]::VARCHAR                                                      AS PO_NUM,
                                                    COUNT(DISTINCT PO_NUM)
                                                          OVER (PARTITION BY DEPARTMENTID, TOTAL, CUSTVENDID, DATE_CREATED)    AS PO_COUNT,
                                                    CASE WHEN SUM_QTY_REMAINING = 0 THEN 'Converted' ELSE 'Open' END           AS STATE,
                                                    DEPARTMENTID,
                                                    DEPARTMENTNAME,
                                                    TOTAL,
                                                    CUSTVENDID,
                                                    CUSTVENDNAME,
                                                    DATE_CREATED,
                                                    T3_PO_CREATED_BY,
                                                    T3_PR_CREATED_BY,
                                                    COUNT_IF(STATE = 'Open')
                                                             OVER (PARTITION BY DEPARTMENTID, TOTAL, CUSTVENDID, DATE_CREATED) AS OPEN_CHECK,
                                                    COUNT(*)
                                                          OVER (PARTITION BY DEPARTMENTID, TOTAL, CUSTVENDID, DATE_CREATED)    AS DUP_CHECK
                                                FROM
                                                    DATA
                                                WHERE
                                                    DATA.TOTAL > 5000
                                                QUALIFY
                                                      DUP_CHECK > 1
                                                  --AND OPEN_CHECK != 0
                                                  AND PO_COUNT > 1)
                                  SELECT
                                      DOCNO                                AS PO_NUMBER,
                                      'Potential Duplicate Entered by Branch' AS MESSAGE
                                  FROM
                                      DUPES)) CHECK_THESE) CHECK_THESE_POS ON PD.DOCNO = CHECK_THESE_POS.PO_NUMBER
            LEFT JOIN (SELECT DISTINCT
    TO_BE_AUTO_CLOSED.DOCUMENTNO AS PO_NUMBER,
    'This will auto close tomorrow' as MESSAGE
FROM
    (SELECT
         PD.CUSTVENDID                                            AS VENDOR_ID,
         PD.DOCID                                                 AS CREATED_FROM,
         PD.DOCNO                                                 AS DOCUMENTNO,
         POS_TO_CLOSE.CLOSE_ON                                    AS CLOSE_DATE,
         YEAR(POS_TO_CLOSE.CLOSE_ON)                              AS YEAR,
         MONTH(POS_TO_CLOSE.CLOSE_ON)                             AS MONTH,
         DAY(POS_TO_CLOSE.CLOSE_ON)                               AS DAY,
         CASE
             WHEN PD.T3_PR_CREATED_BY IS NOT NULL OR LEFT(PD.DOCNO, 1) = 'E' THEN 'Closed Purchase Order'
             ELSE 'Closed PO Non Posting' END                     AS TRANS_TYPE,
         PDE.RECORDNO                                             AS SOURCELINEKEY,
         PDE.ITEMID                                               AS ITEMID,
         PDE.ITEMDESC                                             AS ITEMDESC,
         PDE.UIPRICE                                              AS PRICE,
         PDE.UIQTY - COALESCE(VI_OR_PO_QTY_CONV.CONVERTED_QTY, 0) AS REMAINING_QUANTITY,
         PDE.LOCATIONID                                           AS LOCATIONID,
         PDE.DEPARTMENTID                                         AS DEPARTMENTID,
         PDE.GLDIMEXPENSE_LINE                                    AS EXP_LINE_ID,
         EL.NAME                                                  AS EXP_LINE_NAME
     FROM
         ANALYTICS.INTACCT.PODOCUMENT PD
             LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND
                       ON PD.CUSTVENDID = VEND.VENDORID
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
                              VI_CPO.DOCPARID IN ('Vendor Invoice', 'Closed Purchase Order')
                          AND VI_CPO.CREATEDFROM IS NOT NULL
                          AND VI_CPOD.SOURCE_DOCLINEKEY IS NOT NULL
                        GROUP BY
                            VI_CPO.CREATEDFROM,
                            VI_CPOD.SOURCE_DOCLINEKEY) VI_OR_PO_QTY_CONV
                       ON PD.DOCID = VI_OR_PO_QTY_CONV.SOURCE_PO_DOCID AND
                          PDE.RECORDNO =
                          VI_OR_PO_QTY_CONV.SOURCE_PO_LINE_RECORDNO
             JOIN(SELECT *
                  FROM
                      (SELECT DISTINCT
                           TC.PO_NUMBER                                                        AS PO_NUMBER_TO_CLOSE,
                           COALESCE(CASE
                                        WHEN MIN(TC.DATE_TO_CLOSE_OVERRIDE) <= LC.LAST_CLOSED_DATE
                                            THEN LC.LAST_CLOSED_DATE + 1
                                        ELSE MIN(TC.DATE_TO_CLOSE_OVERRIDE) END, CURRENT_DATE) AS CLOSE_ON
                       FROM
                           ANALYTICS.INTACCT.GS_P_2_P_TO_CLOSE TC
                               LEFT JOIN (SELECT
                                              MAX(LAST_CLOSED_DATE) AS LAST_CLOSED_DATE
                                          FROM
                                              ANALYTICS.CONCUR.LAST_CLOSE_DATE_AP) LC
                       GROUP BY
                           TC.PO_NUMBER,
                           LC.LAST_CLOSED_DATE

                       UNION

                       SELECT DISTINCT
                           PO_NUMBERS_TO_CLOSE.PO_NUMBER_TO_CLOSE AS PO_NUMBER_TO_CLOSE,
                           CURRENT_DATE                           AS CLOSE_ON
                       FROM
                           (SELECT DISTINCT
                                ABD.LINE_ITEM_PURCHASE_ORDER AS PO_NUMBER_TO_CLOSE
                            FROM
                                ANALYTICS.CONCUR.APPROVED_BILL_DETAIL ABD
                                    JOIN(SELECT DISTINCT
                                             POH.CONCUR_IMAGE_ID AS REQUEST_ID,
                                             POH.PONUMBER        AS PO_NUMBER
                                         FROM
                                             ANALYTICS.INTACCT.PODOCUMENT POH
                                         WHERE
                                               POH.CREATEDFROM IS NULL
                                           AND POH.DOCPARID = 'Vendor Invoice') NO_MATCH
                                        ON ABD.REQUEST_ID = NO_MATCH.REQUEST_ID AND
                                           ABD.LINE_ITEM_PURCHASE_ORDER = NO_MATCH.PO_NUMBER
                            WHERE
                                ABD.POLICY_NAME IN ('*Equipmentshare PO Policy', '*Re Rent PO Policy') --originally had a match in Concur

                            UNION

                            SELECT DISTINCT
                                CPO.INTACCT_PO_TO_CLOSE AS PO_NUMBER_TO_CLOSE
                            FROM
                                ANALYTICS.CONCUR.EXC_HANDLE_03_CLOSE_POS CPO

                            UNION

                            SELECT DISTINCT
                                ABD.PO_NUMBER AS PO_NUMBER_TO_CLOSE
                            FROM
                                ANALYTICS.CONCUR.APPROVED_BILL_DETAIL ABD
                                    JOIN(SELECT DISTINCT
                                             POH.CONCUR_IMAGE_ID AS REQUEST_ID
                                         FROM
                                             ANALYTICS.INTACCT.PODOCUMENT POH
                                                 JOIN (SELECT
                                                           POH1.DOCNO AS PO_NUM
                                                       FROM
                                                           ANALYTICS.INTACCT.PODOCUMENT POH1
                                                       WHERE
                                                             POH1.DOCPARID = 'Purchase Order'
                                                         AND POH1.STATE = 'Pending') PENDING_PO
                                                      ON POH.DOCNO = PENDING_PO.PO_NUM
                                         WHERE
                                               POH.CREATEDFROM IS NOT NULL
                                           AND POH.DOCPARID = 'Vendor Invoice') NO_MATCH
                                        ON ABD.REQUEST_ID = NO_MATCH.REQUEST_ID
                            WHERE
                                ABD.POLICY_NAME IN ('*Equipmentshare PO Policy', '*Re Rent PO Policy')

                            UNION

                            SELECT DISTINCT
                                POH.DOCNO AS PO_NUMBER_TO_CLOSE
                            FROM
                                ANALYTICS.INTACCT.PODOCUMENT POH
                                    JOIN (SELECT DISTINCT
                                              TRIM(TO_CHAR(SPLIT_PART(POH.PURCHASE_ORDER_NUMBER, '-', 0))) AS T3_PO_NUMBER_BASE
                                          FROM
                                              PROCUREMENT.PUBLIC.PURCHASE_ORDERS POH
                                          WHERE
                                              POH.STATUS = 'ARCHIVED') T3_CLOSED
                                         ON TRIM(TO_CHAR(SPLIT_PART(POH.DOCNO, '-', 0))) = T3_CLOSED.T3_PO_NUMBER_BASE
                            WHERE
                                POH.DOCPARID = 'Purchase Order'

                            UNION

                            SELECT DISTINCT
                                POH.DOCNO AS PO_NUMBER_TO_CLOSE
                            FROM
                                ANALYTICS.INTACCT.PODOCUMENT POH
                                    JOIN (SELECT DISTINCT
                                              TRIM(TO_CHAR(SPLIT_PART(APH.DOCNUMBER, '-', 0))) AS T3_PO_NUMBER_BASE
                                          FROM
                                              ANALYTICS.INTACCT.APRECORD APH
                                          WHERE
                                                APH.DESCRIPTION2 IS NULL
                                            AND APH.DOCNUMBER IS NOT NULL) DIR_AP_BILL
                                         ON TRIM(TO_CHAR(SPLIT_PART(POH.DOCNO, '-', 0))) = DIR_AP_BILL.T3_PO_NUMBER_BASE
                            WHERE
                                POH.DOCPARID = 'Purchase Order'

                            UNION

                            SELECT DISTINCT
                                POH.DOCNO AS PO_NUMBER_TO_CLOSE
                            FROM
                                ANALYTICS.INTACCT.PODOCUMENT POH
                                    JOIN (SELECT DISTINCT
                                              TRIM(TO_CHAR(SPLIT_PART(ABD.PO_NUMBER, '-', 0))) AS T3_PO_NUMBER_BASE
                                          FROM
                                              ANALYTICS.CONCUR.APPROVED_BILL_DETAIL ABD
                                          WHERE
                                              ABD.POLICY_NAME = '*Equipmentshare Invoice Policy') CONC_PAYABLE
                                         ON TRIM(TO_CHAR(SPLIT_PART(POH.DOCNO, '-', 0))) =
                                            CONC_PAYABLE.T3_PO_NUMBER_BASE
                            WHERE
                                POH.DOCPARID = 'Purchase Order') PO_NUMBERS_TO_CLOSE
                               LEFT JOIN ANALYTICS.INTACCT.PODOCUMENT INT_POH
                                         ON PO_NUMBERS_TO_CLOSE.PO_NUMBER_TO_CLOSE = INT_POH.DOCNO
                       WHERE
                            INT_POH.T3_PR_CREATED_BY IS NOT NULL
                         OR LEFT(DOCNO, 1) = 'E')) POS_TO_CLOSE ON PD.DOCNO = POS_TO_CLOSE.PO_NUMBER_TO_CLOSE
             LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE EL ON PDE.GLDIMEXPENSE_LINE = EL.ID
     WHERE
           PD.DOCPARID = 'Purchase Order'
       AND PD.STATE IN ('Partially Converted', 'Pending')
       AND REMAINING_QUANTITY > 0) TO_BE_AUTO_CLOSED) TO_CLOSE ON TO_CLOSE.PO_NUMBER = PD.DOCNO
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
  dimension: message {type: string sql: ${TABLE}."MESSAGE" ;;}
  dimension: close_flag {type: string sql: ${TABLE}."CLOSE_FLAG" ;;}

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
      ext_cost_remain,
      message,
      close_flag
    ]
  }
  filter: as_of_date {
    type: date
  }
}
