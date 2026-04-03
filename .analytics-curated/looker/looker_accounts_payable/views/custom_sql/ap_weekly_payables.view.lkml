view: ap_weekly_payables {
  derived_table: {
    sql: SELECT
          APRHPAY.financialaccount as "Account_Name",
          APPAY.VENDORID AS "Vendor_ID",
          VEND.NAME AS "Vendor_Name",
          VEND.VENDTYPE AS "Vendor_Type",
          VEND.VENDOR_CATEGORY AS "Vendor_Category",
          APRHPAY.paymenttype as "Payment_Method",
          APRHPAY.state as "Payment_Status",
          VEND.TERMNAME AS "Terms",
          APRHPAY.PAYMENTDATE AS "Payment_Date",
          APBPMT.AMOUNT AS "Payment_Amount",
          APPAY.YOOZ_URL AS "Attachment_Present",
          VEND.TOTALDUE AS "Total_Vendor_Due",
          APPAY.MEGAENTITYID AS "Entity",
          APPAY.DESCRIPTION AS "Payment_Description",
          COA.ACCOUNTNO AS "GL_Number",
          COA.TITLE AS "GL_Description",
          INFO.DESCRIPTION AS "Payment_Submitter",
          --TIMEZONE('America/Chicago', APPAY._ES_UPDATE_TIMESTAMP) AS "Update_Timestamp_Central"
          --CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(APBPMT._ES_UPDATE_TIMESTAMP AS TIMESTAMP)) AS "Update_Timestamp",
          APBPMT._ES_UPDATE_TIMESTAMP AS "Update_Timestamp",
          APBPMT.PAYMENTKEY as "Payment_Key",
          MAX(APBPMT._ES_UPDATE_TIMESTAMP) OVER () AS "Most_Recent_Timestamp"
          --CONVERT_TIMEZONE('UTC', 'America/Chicago', MAX(CAST(APBPMT._ES_UPDATE_TIMESTAMP AS TIMESTAMP)) OVER ()) AS "Most_Recent_Timestamp"
FROM
    "ANALYTICS"."INTACCT"."APBILLPAYMENT" APBPMT
    LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APPAY ON APBPMT.RECORDKEY = APPAY.RECORDNO
    LEFT JOIN "ANALYTICS"."INTACCT"."APDETAIL" APDET ON APBPMT.PAIDITEMKEY = APDET.RECORDNO
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VEND ON APPAY.VENDORID = VEND.VENDORID
    LEFT JOIN "ANALYTICS"."INTACCT"."GLACCOUNT" COA ON APDET.ACCOUNTNO = COA.ACCOUNTNO
    LEFT JOIN "ANALYTICS"."INTACCT"."APRECORD" APRHPAY ON APBPMT.PAYMENTKEY = APRHPAY.RECORDNO
    LEFT JOIN "ANALYTICS"."INTACCT"."USERINFO" INFO ON APRHPAY.CREATEDBY = INFO.RECORDNO
WHERE
    APRHPAY.STATE IN ('Submitted', 'Draft', 'Completed', 'Voided') --Added Submitted here because it coinsides with "Selected" status of a bill
--    AND APPAY.RECORDTYPE = 'appayment'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: amount {
    type: sum
    sql: ${TABLE}."Payment_Amount";;
    value_format: "$#,##0.00"
    drill_fields: [detail*]
  }

  measure: distinct_payment_keys {
    type: count_distinct
    sql: ${payment_key} ;;
    label: "Distinct Payment Keys"
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."Account_Name" ;;
  }

  dimension: total_vendor_due {
    type: number
    sql: ${TABLE}."Total_Vendor_Due" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."Entity" ;;
  }
  dimension: payment_description {
    type: string
    sql: ${TABLE}."Payment_Description" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."Vendor_ID" ;;
  }
  dimension: payment_status {
    type: string
    sql: ${TABLE}."Payment_Status" ;;
  }

  dimension: payment_method {
    type: string
    sql: ${TABLE}."Payment_Method" ;;
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

  dimension: terms {
    type: string
    sql: ${TABLE}."Terms" ;;
  }

  dimension: payment_date {
    type: date
    sql: ${TABLE}."Payment_Date" ;;
  }

  dimension: payment_amount {
    type: number
    sql: ${TABLE}."Payment_Amount" ;;
    value_format: "$#,##0.00"
  }

  dimension: YOOZ_URL {
    type: string
    hidden: yes
    sql: ${TABLE}."Attachment_Present" ;;
  }

  # Unsure if this is completely working, every preview cell in the final vizualization populates with no
  dimension: attachment {
    type: string
    sql: CASE WHEN ${YOOZ_URL} IS NOT NULL THEN 'Yes' ELSE 'No' END ;;
    label: "Attachment"
  }

  dimension: GL_Number {
    type: string
    sql: ${TABLE}."GL_Number";;
  }

  dimension: GL_Description {
    type: string
    sql: ${TABLE}."GL_Description";;
  }

  dimension: payment_submitter {
    type: string
    sql: ${TABLE}."Payment_Submitter";;
  }

  dimension: update_timestamp {
    type: string
    sql: TO_VARCHAR(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(${TABLE}."Update_Timestamp" AS TIMESTAMP)), 'YYYY-MM-DD HH24:MI');;
    label: "Update Timestamp (Central)"
  }

  dimension: payment_key {
    type: string
    sql: ${TABLE}."Payment_Key" ;;
  }

  dimension: most_recent_timestamp {
    type: string
    sql: TO_VARCHAR(CONVERT_TIMEZONE('UTC', 'America/Chicago', CAST(${TABLE}."Most_Recent_Timestamp" AS TIMESTAMP)), 'YYYY-MM-DD HH24:MI');;
    label: "Most Recent Timestamp"
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor_type,
      vendor_category,
      terms,
      payment_date,
      payment_amount,
      total_vendor_due,
      account_name,
      entity,
      payment_description,
      YOOZ_URL,
      GL_Number,
      GL_Description,
      payment_submitter,
      payment_key
    ]
  }
}
