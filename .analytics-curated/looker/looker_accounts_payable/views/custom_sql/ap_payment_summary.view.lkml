view: ap_payment_summary {
  derived_table: {
    sql: SELECT
          APPAY.VENDORID AS "Vendor_ID",
          appay.financialaccount as "Account_Name",
          VEND.NAME AS "Vendor_Name",
          VEND.VENDTYPE AS "Vendor_Type",
          VEND.VENDOR_CATEGORY AS "Vendor_Category",
          appay.paymenttype as "Payment_Method",
          appay.state as "Payment_Status",
          VEND.TERMNAME AS "Terms",
          APPAY.PAYMENTDATE AS "Payment_Date",
          APPAY.PAYMENTAMOUNT AS "Payment_Amount",
          APPAY.YOOZ_URL AS "Attachment_Present"
          APPAY.YOOZ_URL AS "Attachment_Present",
          VEND.TOTALDUE AS "Total_Vendor_Due",
          APPAY.MEGAENTITYID AS "Entity",
          APPAY.DESCRIPTION AS "Payment_Description"
FROM
    "ANALYTICS"."INTACCT"."APRECORD" APPAY
    LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VEND ON APPAY.VENDORID = VEND.VENDORID
WHERE
    APPAY.STATE IN('Complete','Voided')
    AND APPAY.RECORDTYPE = 'appayment'
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: amount {
    type: sum
    sql: ${TABLE}."Payment_Amount";;
    drill_fields: [detail*]
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
  }

  dimension: YOOZ_URL {
    type: string
    hidden: yes
    sql: ${TABLE}."Attachment_Present" ;;
  }

  dimension: attachment {
    type: string
    sql: CASE WHEN ${YOOZ_URL} IS NOT NULL THEN 'yes' ELSE 'no' END ;;
    label: "Attachment"
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
      YOOZ_URL
    ]
  }
}
