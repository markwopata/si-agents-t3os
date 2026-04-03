view: out_of_balance_entries {
  derived_table: {
    sql: SELECT GLB.BATCH_DATE,
       GLB.BATCHNO,
       GLE.LOCATION,
--        GLE.ACCOUNTNO,
--        SUM(GLE.AMOUNT),
       SUM(CASE WHEN TR_TYPE = 1 THEN GLE.AMOUNT ELSE 0 END)       AS "DEBIT",
       SUM(CASE WHEN TR_TYPE = '-1' THEN GLE.AMOUNT ELSE 0 END)    AS "CREDIT",
       CASE WHEN ("DEBIT" - "CREDIT") = 0 THEN 'YES' ELSE 'NO' END AS "IN_BALANCE",
       "DEBIT" - "CREDIT"                                          AS "DIFF"

FROM "ANALYTICS"."INTACCT"."GLENTRY" GLE
         LEFT JOIN "ANALYTICS"."INTACCT"."GLBATCH" GLB
                   ON GLB.RECORDNO = GLE.BATCHNO

//WHERE GLB.BATCH_DATE >= '2023-11-29'
WHERE 1 = 1
--   AND GLB.BATCHNO = 14508
  AND GLB.BATCH_DATE >= '2023-10-16'
--   AND GLB.JOURNAL = 'GJ'
  AND GLB.STATE = 'Posted'

GROUP BY GLB.BATCH_DATE, GLB.BATCHNO, GLE.LOCATION
--        , GLE.ACCOUNTNO
HAVING "DIFF" != 0

ORDER BY GLB.BATCH_DATE DESC ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: batch_date {
    type: date
    label: "Batch Date"
    sql: ${TABLE}."BATCH_DATE" ;;
  }

  dimension: batchno {
    type: string
    label: "Batch Number"
    sql: ${TABLE}."BATCHNO" ;;
  }

  dimension: location {
    type: string
    label: "Location"
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: debit {
    type: number
    label: "Debit"
    sql: ${TABLE}."DEBIT" ;;
  }

  dimension: credit {
    type: number
    label: "Credit"
    sql: ${TABLE}."CREDIT" ;;
  }

  dimension: in_balance {
    type: string
    label: "In Balance"
    sql: ${TABLE}."IN_BALANCE" ;;
  }

  dimension: diff {
    type: number
    label: "Difference"
    sql: ${TABLE}."DIFF" ;;
  }

  set: detail {
    fields: [
      batch_date,
      batchno,
      location,
      debit,
      credit,
      in_balance,
      diff
    ]
  }
}
