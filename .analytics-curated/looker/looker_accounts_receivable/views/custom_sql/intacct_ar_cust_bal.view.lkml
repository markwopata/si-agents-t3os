view: intacct_ar_cust_bal {
  derived_table: {
    sql: SELECT
          ARR.RECORDNO AS "Recordno",
          ARR.CUSTOMERID AS "Customer_ID",
          COMP.NAME AS "Customer_Name",
          CAST(ARR.WHENPOSTED AS DATE) AS "Post_Date",
          ARR.RECORDTYPE AS "Transaction_Type",
          COALESCE(ARR.RECORDID,ARR.DOCNUMBER,'') AS "Document",
          COALESCE(ARR.DESCRIPTION,'') AS "Description",
          COALESCE(ROUND(ARR.TOTALENTERED,2),0) AS "Original_Amount",
          COALESCE(ROUND(ARINVPMT.AMOUNT_PAID,2),0) AS "Amt_Paid",
          COALESCE(ROUND(ARDET1.AMT,2),0) AS "Amt_Pmt_Appl",
          COALESCE(ROUND(-1*CMAPPL.AMOUNT_PAID,2),0) AS "Amt_CM_Appl",
          ROUND(COALESCE(ARR.TOTALENTERED,0) - (COALESCE(ARINVPMT.AMOUNT_PAID,0)+COALESCE(ARDET1.AMT,0)+COALESCE((-1*CMAPPL.AMOUNT_PAID),0)),2) AS "Balance_Amount"
      FROM
          "ANALYTICS"."INTACCT"."ARRECORD" ARR
          LEFT JOIN
              (SELECT
                  RECORDKEY,
                  SUM(AMOUNT) AS "AMOUNT_PAID"
               FROM "ANALYTICS"."INTACCT"."ARINVOICEPAYMENT"
               WHERE PAYMENTDATE <= {% date_end date_filter %}
               GROUP BY RECORDKEY) AS ARINVPMT ON ARR.RECORDNO = ARINVPMT.RECORDKEY
          LEFT JOIN
              (SELECT
                  ARD.RECORDKEY,
                  SUM(ARIP.AMOUNT) AS "AMT"
               FROM "ANALYTICS"."INTACCT"."ARDETAIL" ARD
                  LEFT JOIN
                      "ANALYTICS"."INTACCT"."ARDETAIL" ARIP ON ARD.RECORDNO = ARIP.PARENTENTRY
               WHERE ARIP.ENTRY_DATE <= {% date_end date_filter %}
               GROUP BY ARD.RECORDKEY) AS ARDET1 ON ARR.RECORDNO = ARDET1.RECORDKEY
          LEFT JOIN
              (SELECT
                  PARENTPYMT,
                  SUM(AMOUNT) AS "AMOUNT_PAID"
               FROM "ANALYTICS"."INTACCT"."ARINVOICEPAYMENT"
               WHERE PAYMENTDATE <= {% date_end date_filter %}
               GROUP BY PARENTPYMT) AS CMAPPL ON ARR.RECORDNO = CMAPPL.PARENTPYMT
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANY_ERP_REFS" COMERP ON TRY_CAST(ARR.CUSTOMERID AS INTEGER) = COMERP.COMPANY_ID
          LEFT JOIN "ES_WAREHOUSE"."PUBLIC"."COMPANIES" COMP ON COMERP.COMPANY_ID = COMP.COMPANY_ID
      WHERE
          ARR.WHENPOSTED <= {% date_end date_filter %}
      ORDER BY
          ARR.CUSTOMERID,
          ARR.RECORDTYPE,
          COALESCE(ARR.RECORDID,ARR.DOCNUMBER)
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: recordno {
    type: number
    sql: ${TABLE}."Recordno" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."Customer_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."Customer_Name" ;;
  }

  dimension: post_date {
    type: date
    sql: ${TABLE}."Post_Date" ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."Transaction_Type" ;;
  }

  dimension: document {
    type: string
    sql: ${TABLE}."Document" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."Description" ;;
  }

  dimension: original_amount {
    type: number
    sql: ${TABLE}."Original_Amount" ;;
  }

  dimension: amt_paid {
    type: number
    sql: ${TABLE}."Amt_Paid" ;;
  }

  dimension: amt_pmt_appl {
    type: number
    sql: ${TABLE}."Amt_Pmt_Appl" ;;
  }

  dimension: amt_cm_appl {
    type: number
    sql: ${TABLE}."Amt_CM_Appl" ;;
  }

  dimension: balance_amount {
    type: number
    sql: ${TABLE}."Balance_Amount" ;;
  }

  set: detail {
    fields: [
      recordno,
      customer_id,
      customer_name,
      post_date,
      transaction_type,
      document,
      description,
      original_amount,
      amt_paid,
      amt_pmt_appl,
      amt_cm_appl,
      balance_amount
    ]
  }

  filter: date_filter {
    type: date
  }
}
