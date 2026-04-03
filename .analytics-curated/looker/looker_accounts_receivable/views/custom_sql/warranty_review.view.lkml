view: warranty_review {
  derived_table: {
    sql:

WITH detail AS (
  SELECT
    gle.RECORDNO,
    gle.ENTRY_DATE,
    LAST_DAY(gle.ENTRY_DATE) AS MONTH_ENDING,
    gle.ACCOUNTNO,
    gle.DEPARTMENT,
    gle.TR_TYPE,
    CASE
      WHEN glb.JOURNAL = 'GJ' THEN (gle.AMOUNT * gle.TR_TYPE)
      ELSE (glr.AMOUNT * gle.TR_TYPE)
    END AS NET_AMOUNT,
    gle.BATCHTITLE,
    glb.JOURNAL,
    glb.BATCHNO,
    glr.PRRECORDKEY,
    glr.PRENTRYKEY,
    arr.RECORDTYPE AS AR_RECORD_TYPE,
    arr.CUSTOMERID AS AR_CUST_ID,
    arr.CUSTOMERNAME AS AR_CUST_NAME,
    ard.ENTRYDESCRIPTION AS AR_PAYMENT_ID,
    apr.RECORDID AS BILL_NUMBER,
    apr.VENDORID AS AP_VEND_ID,
    apr.VENDORNAME AS AP_VEND_NAME,
    apr.DOCNUMBER,
    CASE
      WHEN apr.DOCNUMBER LIKE 'WTY_%' THEN RIGHT(apr.DOCNUMBER, LEN(apr.DOCNUMBER) - 11)
    END AS AP_PAYMENT_ID,
    COALESCE(AR_PAYMENT_ID, AP_PAYMENT_ID) AS PAYMENT_ID
  FROM ANALYTICS.INTACCT.GLENTRY gle
  LEFT JOIN ANALYTICS.INTACCT.GLBATCH glb ON gle.BATCHNO = glb.RECORDNO
  LEFT JOIN ANALYTICS.INTACCT.GLRESOLVE glr ON gle.RECORDNO = glr.GLENTRYKEY
  LEFT JOIN ANALYTICS.INTACCT.ARRECORD arr ON glr.PRRECORDKEY = arr.RECORDNO AND glb.JOURNAL = 'ARJ'
  LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ard ON arr.RECORDNO = ard.RECORDKEY AND glb.JOURNAL = 'ARJ'
  LEFT JOIN ANALYTICS.INTACCT.APRECORD apr ON glr.PRRECORDKEY = apr.RECORDNO AND glb.JOURNAL = 'APJ'
  WHERE gle.ACCOUNTNO = '2303'
),

payment_summary AS (
  SELECT
    COALESCE(
      ard.ENTRYDESCRIPTION,  -- AR_PAYMENT_ID
      CASE
        WHEN apr.DOCNUMBER LIKE 'WTY_%'
          THEN RIGHT(apr.DOCNUMBER, LEN(apr.DOCNUMBER) - 11)
      END                    -- AP_PAYMENT_ID
    ) AS PAYMENT_ID,

    SUM(CASE
          WHEN glb.JOURNAL = 'GJ' THEN (gle.AMOUNT * gle.TR_TYPE)
          ELSE (glr.AMOUNT * gle.TR_TYPE)
        END) AS TOTAL_NET_AMOUNT

  FROM ANALYTICS.INTACCT.GLENTRY gle
  LEFT JOIN ANALYTICS.INTACCT.GLBATCH glb ON gle.BATCHNO = glb.RECORDNO
  LEFT JOIN ANALYTICS.INTACCT.GLRESOLVE glr ON gle.RECORDNO = glr.GLENTRYKEY
  LEFT JOIN ANALYTICS.INTACCT.ARRECORD arr ON glr.PRRECORDKEY = arr.RECORDNO AND glb.JOURNAL = 'ARJ'
  LEFT JOIN ANALYTICS.INTACCT.ARDETAIL ard ON arr.RECORDNO = ard.RECORDKEY AND glb.JOURNAL = 'ARJ'
  LEFT JOIN ANALYTICS.INTACCT.APRECORD apr ON glr.PRRECORDKEY = apr.RECORDNO AND glb.JOURNAL = 'APJ'
  WHERE gle.ACCOUNTNO = '2303'
  GROUP BY
    COALESCE(
      ard.ENTRYDESCRIPTION,
      CASE
        WHEN apr.DOCNUMBER LIKE 'WTY_%'
          THEN RIGHT(apr.DOCNUMBER, LEN(apr.DOCNUMBER) - 11)
      END
    )
)

SELECT bd.*
FROM detail bd
JOIN payment_summary ps ON bd.PAYMENT_ID = ps.PAYMENT_ID
WHERE ps.TOTAL_NET_AMOUNT != 0
;;}

  dimension: recordno {
    type: string
    sql: ${TABLE}.RECORDNO ;;
  }

  dimension: entry_date {
    type: date
    sql: ${TABLE}.ENTRY_DATE ;;
  }

  dimension: month_ending {
    type: date
    sql: ${TABLE}.MONTH_ENDING ;;
  }

  dimension: accountno {
    type: string
    sql: ${TABLE}.ACCOUNTNO ;;
  }

  dimension: department {
    type: string
    sql: ${TABLE}.DEPARTMENT ;;
  }

  dimension: tr_type {
    type: number
    sql: ${TABLE}.TR_TYPE ;;
  }

  measure: net_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}.NET_AMOUNT ;;
  }

  dimension: batchtitle {
    type: string
    sql: ${TABLE}.BATCHTITLE ;;
  }

  dimension: journal {
    type: string
    sql: ${TABLE}.JOURNAL ;;
  }

  dimension: batchno {
    type: string
    sql: ${TABLE}.BATCHNO ;;
  }

  dimension: prrecordkey {
    type: string
    sql: ${TABLE}.PRRECORDKEY ;;
  }

  dimension: prentrykey {
    type: string
    sql: ${TABLE}.PRENTRYKEY ;;
  }

  dimension: ar_record_type {
    type: string
    sql: ${TABLE}.AR_RECORD_TYPE ;;
  }

  dimension: ar_cust_id {
    type: string
    sql: ${TABLE}.AR_CUST_ID ;;
  }

  dimension: ar_cust_name {
    type: string
    sql: ${TABLE}.AR_CUST_NAME ;;
  }

  dimension: ar_payment_id {
    type: string
    sql: ${TABLE}.AR_PAYMENT_ID ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}.BILL_NUMBER ;;
  }

  dimension: ap_vend_id {
    type: string
    sql: ${TABLE}.AP_VEND_ID ;;
  }

  dimension: ap_vend_name {
    type: string
    sql: ${TABLE}.AP_VEND_NAME ;;
  }

  dimension: docnumber {
    type: string
    sql: ${TABLE}.DOCNUMBER ;;
  }

  dimension: ap_payment_id {
    type: string
    sql: ${TABLE}.AP_PAYMENT_ID ;;
  }

  dimension: payment_id {
    type: string
    sql: ${TABLE}."PAYMENT_ID" ;;
    html: <a href='https://admin.equipmentshare.com/#/home/payments/{{ payment_id._value }}' target='_blank' style='color: blue;'>{{ payment_id._value | escape }}</a> ;;}

  set: payment_detail_fields {
    fields: [
      recordno,
      entry_date,
      month_ending,
      accountno,
      department,
      tr_type,
      net_amount,
      batchtitle,
      journal,
      batchno,
      prrecordkey,
      prentrykey,
      ar_record_type,
      ar_cust_id,
      ar_cust_name,
      ar_payment_id,
      bill_number,
      ap_vend_id,
      ap_vend_name,
      docnumber,
      ap_payment_id,
      payment_id
    ]
  }

  measure: payment_detail_count {
    type: count
    label: "View Details"
    drill_fields: [payment_detail_fields*]
  }




  filter: entry_date_filter {
    type: date
    default_value: "1 day"  # This means today
    sql: ${entry_date} >= {% date_start entry_date_filter %} ;;
  }
}
