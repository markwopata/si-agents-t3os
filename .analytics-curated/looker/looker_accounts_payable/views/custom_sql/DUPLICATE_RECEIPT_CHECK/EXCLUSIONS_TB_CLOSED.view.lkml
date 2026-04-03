view: exclusions_tb_closed {
  derived_table: {
    sql: SELECT DISTINCT
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
       AND REMAINING_QUANTITY > 0) TO_BE_AUTO_CLOSED
                   ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: message {
    type: string
    sql: ${TABLE}."MESSAGE" ;;
  }

  set: detail {
    fields: [
      po_number,
      message
    ]
  }


}
