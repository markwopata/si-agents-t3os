view: ap_payments {
  derived_table: {
    sql: SELECT
    APRH.VENDORID AS "Vendor_ID",
    VEND.NAME AS "Vendor_Name",
    VEND.VENDTYPE AS "Vendor_Type",
    VEND.VENDOR_CATEGORY AS "Vendor_Category",
    VEND.REPORTING_CATEGORY AS "Reporting_Category",
    VEND.TERMNAME AS "Terms",
    APBPMT.PAYMENTDATE AS "Payment_Date",
    APRHPAY.STATE AS "State",
    COA.ACCOUNTNO AS "Account",
    COA.TITLE AS "Account_Name",
    SUM(APBPMT.AMOUNT) AS "Amount"
FROM
    "ANALYTICS"."INTACCT"."APBILLPAYMENT" APBPMT
    LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRH ON APBPMT.RECORDKEY = APRH.RECORDNO AND APRH.RECORDTYPE IN ('apbill','apadjustment')
    LEFT JOIN "ANALYTICS"."INTACCT"."APDETAIL" APRD ON APBPMT.PAIDITEMKEY = APRD.RECORDNO AND APRH.RECORDNO = APRD.RECORDKEY
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VEND ON APRH.VENDORID = VEND.VENDORID
    LEFT JOIN "ANALYTICS"."INTACCT"."GLACCOUNT" COA ON
    CASE
     WHEN APRD.ACCOUNTNO = '2014' THEN SUBSTRING(APRD.ITEMID, 2, 4) ELSE APRD.ACCOUNTNO END = COA.ACCOUNTNO
    LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRHPAY ON APBPMT.PAYMENTKEY = APRHPAY.RECORDNO
WHERE
    APBPMT.PAYMENTDATE >= {% date_start date_filter %}
    AND APBPMT.PAYMENTDATE <= {% date_end date_filter %}
    AND APBPMT.PAYMENTKEY = APBPMT.PARENTPYMT --WHEN THESE DON'T EQUAL IT IS A CREDIT MEMO APPLICATION I THINK
    AND APRHPAY.RECORDTYPE = 'appayment'
GROUP BY
    ALL
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."Vendor_ID";;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."Vendor_Name" ;;
  }

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."Vendor_Type" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."Vendor_Category" ;;
  }

  dimension: reporting_category {
    type: string
    sql: ${TABLE}."Reporting_Category" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."Terms" ;;
  }

  dimension: payment_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."Payment_Date" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."State" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."Account" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."Account_Name" ;;
  }

  measure: amount {
    type: sum
    value_format: "#,##0.00"
    sql: ${TABLE}."Amount" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor_type,
      vendor_category,
      reporting_category,
      terms,
      payment_date,
      state,
      account,
      account_name,
      amount
    ]
  }

  filter: date_filter {
    convert_tz: no
    type: date
  }
}
