view: unconverted_po_entry {
  derived_table: {
    sql: SELECT
    POE.RECORDNO                                           AS "POE_Recordno",
    POE.DOCNO                                              AS "POE_Number",
    POE.DOCID                                              AS "Document_ID",
    PO.DOCNO                                               AS "Converted_To_PO",
    CAST(POE.WHENCREATED AS DATE)                          AS "PO_Date",
    CONVERT_TIMEZONE('America/Chicago', POE.AUWHENCREATED) AS "Created_On",
    CONVERT_TIMEZONE('America/Chicago', POE.WHENMODIFIED)  AS "Modified_On"
FROM
    analytics.intacct.PODOCUMENT POE
        LEFT JOIN (SELECT DOCNO FROM analytics.intacct.PODOCUMENT WHERE DOCPARID = 'Purchase Order') PO
                  ON POE.DOCNO = PO.DOCNO
WHERE
      POE.DOCPARID = 'Purchase Order Entry'
  AND POE.STATE = 'Pending'
  AND CAST(CONVERT_TIMEZONE('America/Chicago', POE.AUWHENCREATED) AS DATE) >= '2021-08-10'
  AND PO.DOCNO IS NULL
ORDER BY
    POE.WHENMODIFIED ASC
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: poe_recordno {
    type: number
    sql: ${TABLE}."POE_Recordno" ;;
  }

  dimension: poe_number {
    type: string
    sql: ${TABLE}."POE_Number" ;;
  }

  dimension: document_id {
    type: string
    sql: ${TABLE}."Document_ID" ;;
  }

  dimension: converted_to_po {
    type: string
    sql: ${TABLE}."Converted_To_PO" ;;
  }

  dimension: po_date {
    type: date
    sql: ${TABLE}."PO_Date" ;;
  }

  dimension_group: created_on {
    type: time
    sql: ${TABLE}."Created_On" ;;
  }

  dimension_group: modified_on {
    type: time
    sql: ${TABLE}."Modified_On" ;;
  }

  set: detail {
    fields: [
      poe_recordno,
      poe_number,
      document_id,
      converted_to_po,
      po_date,
      created_on_time,
      modified_on_time
    ]
  }
}
