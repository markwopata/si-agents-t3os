view: total_billed_by_vendor {
  derived_table: {
    sql: SELECT
          APR.VENDORID AS "Vendor_ID",
          VEN.NAME AS "Vendor_Name",
          APR.RECORDID AS "Bill_Number",
          CAST(APR.WHENCREATED AS DATE) AS "Bill_Date",
          CAST(APR.WHENPOSTED AS DATE) AS "GL_Posting_Date",
          ROUND(SUM(APD.AMOUNT), 0) AS "Amount",
          APD.ACCOUNTNO AS "GL_Account",
          COA.TITLE AS "Account_Name",
          APD.DEPARTMENTID AS "Location"
      FROM
          "ANALYTICS"."PUBLIC"."APRECORD" APR
          LEFT JOIN "ANALYTICS"."PUBLIC"."VENDOR" VEN ON APR.VENDORID = VEN.VENDORID
          LEFT JOIN "ANALYTICS"."PUBLIC"."APDETAIL" APD ON APR.RECORDNO = APD.RECORDKEY
          LEFT JOIN "ANALYTICS"."PUBLIC"."GLACCOUNT" COA ON APD.ACCOUNTNO = COA.ACCOUNTNO
      WHERE
          APR.RECORDTYPE in ('apbill','apadjustment') AND
          APR.VENDORID NOT IN ('V24841','V20249','V12842', 'V24821', 'V20895')
      GROUP BY
          APR.VENDORID,
          VEN.NAME,
          APR.RECORDID,
          CAST(APR.WHENCREATED AS DATE),
          CAST(APR.WHENPOSTED AS DATE),
          APD.ACCOUNTNO,
          COA.TITLE,
          APD.DEPARTMENTID
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."Vendor_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."Vendor_Name" ;;
  }

  dimension: vendor {
    type: string
    sql: CONCAT(LEFT(${TABLE}."Vendor_Name",50), ' (', ${TABLE}."Vendor_ID", ')') ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."Bill_Number" ;;
  }

  dimension: bill_date {
    type: date
    sql: ${TABLE}."Bill_Date" ;;
  }

  dimension: gl_posting_date {
    type: date
    sql: ${TABLE}."GL_Posting_Date" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."Amount" ;;
  }

  measure: billed_amount {
    type: sum
    sql: ${TABLE}."Amount" ;;
  }

  dimension: gl_account {
    type: number
    sql: ${TABLE}."GL_Account" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."Account_Name" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."Location" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor,
      bill_number,
      bill_date,
      gl_posting_date,
      amount,
      gl_account,
      account_name,
      location
    ]
  }
}
