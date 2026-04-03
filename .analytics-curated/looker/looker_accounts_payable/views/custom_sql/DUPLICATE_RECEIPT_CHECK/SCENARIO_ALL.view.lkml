view: scenario_all {
  derived_table: {
    sql: SELECT CHECK_THESE.PO_NUMBER,
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
            AND POH.WHENCREATED <= {
              % date_end as_of_date %}
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
                               AND VIH.WHENPOSTED <= {
                                 % date_end as_of_date %}
                             GROUP BY
                                 VIL.SOURCE_DOCID) CONVERTING_VIS ON PO_ORIG.DOCID = CONVERTING_VIS.SOURCE_DOCID
          WHERE
                PO_ORIG.PO_ORIG_COST != 0
            AND VARIANCE <= 0.5) UNDER_CONVERTED

     UNION

        WITH
            DATA AS (SELECT DISTINCT
                         DOCHDRID,
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
                          DATA.TOTAL < 5000
                      QUALIFY
                            DUP_CHECK > 1
                        AND OPEN_CHECK != 0
                        AND PO_COUNT > 1)
        SELECT
            DOCHDRID                                AS PO_NUMBER,
            'Potential Duplicate Entered by Branch' AS MESSAGE
        FROM
            DUPES) CHECK_THESE
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

  filter: as_of_date {
    type: date
  }

}
