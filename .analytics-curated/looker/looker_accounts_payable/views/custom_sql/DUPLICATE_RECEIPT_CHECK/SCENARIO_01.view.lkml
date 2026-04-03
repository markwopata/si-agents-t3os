view: scenario_01 {
  derived_table: {
    sql: SELECT DISTINCT
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
       AND REGEXP_REPLACE(POH.PONUMBER, '[^\\d]*') != '') INV_CHECK
WHERE
    INV_CHECK.TEST != 1
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
