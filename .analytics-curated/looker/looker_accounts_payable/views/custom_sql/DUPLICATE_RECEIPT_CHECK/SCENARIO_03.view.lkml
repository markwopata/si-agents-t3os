view: scenario_03 {
  derived_table: {
    sql: WITH
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
                  DATA.TOTAL > 5000
              QUALIFY
                    DUP_CHECK > 1
                AND OPEN_CHECK != 0
                AND PO_COUNT > 1)
SELECT
    DOCHDRID                                AS PO_NUMBER,
    'Potential Duplicate Entered by Branch' AS MESSAGE
FROM
    DUPES
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
