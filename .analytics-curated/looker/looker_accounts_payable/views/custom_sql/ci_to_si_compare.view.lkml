view: ci_to_si_compare {
  derived_table: {
    sql: SELECT DISTINCT
    ABD.REQUEST_KEY                                                       AS REQUEST_KEY,
    ABD.REQUEST_ID                                                        AS REQUEST_ID,
    ABD.VENDOR_CODE                                                       AS VENDOR_ID,
    V.NAME                                                                AS VENDOR_NAME,
    ABD.VENDOR_INVOICE_NUMBER                                             AS ORIG_BILL_NUMBER,
    ABD.TOTAL_AMOUNT                                                      AS AMOUNT_CONCUR,
    COALESCE(SAGE.AMOUNT, 0)                                              AS AMOUNT_INTACCT,
    ROUND(COALESCE(SAGE.AMOUNT, 0) - ABD.TOTAL_AMOUNT, 2)                 AS AMOUNT_DELTA,
    CASE WHEN SAGE.CONCUR_INVOICE_ID IS NULL THEN 'Missing?' ELSE '-' END AS IN_SAGE,
    COALESCE(SAGE.COUNTED,0)                                              AS SAGE_BILL_COUNT,
    ABD.BATCH_ID                                                          AS BATCH_ID,
    ABD.BATCH_DATE                                                        AS BATCH_DATE,
FROM
    ANALYTICS.CONCUR.APPROVED_BILL_DETAIL ABD
        LEFT JOIN ANALYTICS.INTACCT.VENDOR V ON ABD.VENDOR_CODE = V.VENDORID
        LEFT JOIN(SELECT
                      APH.CONCUR_IMAGE_ID       AS CONCUR_INVOICE_ID,
                      COUNT(APH.RECORDNO)       AS COUNTED,
                      SUM(APH.TRX_TOTALENTERED) AS AMOUNT
                  FROM
                      ANALYTICS.INTACCT.APRECORD APH
                  WHERE
                      APH.RECORDTYPE = 'apbill'
                  GROUP BY ALL) SAGE ON ABD.REQUEST_ID = SAGE.CONCUR_INVOICE_ID
WHERE
      ABD.BATCH_DATE >= '2024-01-01'
GROUP BY ALL
      ;;
  }

  measure: count {type: count drill_fields: [detail*]}
  dimension:request_key {type: string sql: ${TABLE}."REQUEST_KEY" ;;}
  dimension:request_id {type: string sql: ${TABLE}."REQUEST_ID" ;;}
  dimension:vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  dimension:vendor_name {type: string sql: ${TABLE}."VENDOR_NAME" ;;}
  dimension:orig_bill_number {type: string sql: ${TABLE}."ORIG_BILL_NUMBER" ;;}
  measure:amount_concur {type: sum sql: ${TABLE}."AMOUNT_CONCUR" ;;}
  measure:amount_intacct {type: sum sql: ${TABLE}."AMOUNT_INTACCT" ;;}
  measure:amount_delta {type: sum sql: ${TABLE}."AMOUNT_DELTA" ;;}
  dimension:in_sage {type: string sql: ${TABLE}."IN_SAGE" ;;}
  measure:sage_bill_count {type: sum sql: ${TABLE}."SAGE_BILL_COUNT" ;;}
  dimension:batch_id {type: string sql: ${TABLE}."BATCH_ID" ;;}
  dimension:batch_date {convert_tz: no type: date sql: ${TABLE}."BATCH_DATE" ;;}

  set: detail {
    fields: [
        request_key,
        request_id,
        vendor_id,
        vendor_name,
        orig_bill_number,
        amount_concur,
        amount_intacct,
        amount_delta,
        in_sage,
        sage_bill_count,
        batch_id,
        batch_date
    ]
  }
}
