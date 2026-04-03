view: scenario_02 {
  derived_table: {
    sql: SELECT DISTINCT
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
