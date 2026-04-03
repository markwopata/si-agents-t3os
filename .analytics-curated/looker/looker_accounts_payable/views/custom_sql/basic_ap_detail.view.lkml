view: basic_ap_detail {
  derived_table: {
    sql: SELECT
          APBH.VENDORID AS "Vendor_ID",
          VEND.NAME AS "Vendor_Name",
          VEND.VENDTYPE AS "Vendor_Type",
          VEND.VENDOR_CATEGORY AS "Vendor_Category",
          VEND.STATUS AS "Status",
          APBH.RECORDID AS "Bill_Number",
          APBH.WHENCREATED AS "Bill_Date",
          MONTHNAME(APBH.WHENCREATED) AS "Bill_Month",
          YEAR(APBH.WHENCREATED) AS "Bill_Year",
          APBH.WHENPOSTED AS "GL_Posting_Date",
          APBH.WHENDUE AS "Due_Date",
          APBH.WHENPAID As "Paid_Date",
          APBH.TERMNAME AS "Terms",
          APBH.DESCRIPTION AS "Bill_Memo",
          URL.RECORD_URL AS "URL",
          APBH.DOCNUMBER AS "PO_NUMBER",
          APBD.LINE_NO AS "Line_No",
          APBD.ACCOUNTNO AS "Account",
          GLA.TITLE AS "Account_Name",
          GLA.ACCOUNTTYPE                                                                                        AS ACCOUNT_TYPE,
          GLA.CATEGORY                                                                                           AS ACCOUNT_CATEGORY,
          GLA.CLOSINGTYPE                                                                                        AS ACCOUNT_CLOSE_TYPE,
          GLA.NORMALBALANCE                                                                                      AS ACCOUNT_NORMAL_BALANCE,
          APBD.DEPARTMENTID AS "Branch_ID",
          APBD.ASSET_ID AS "Asset_ID",
          APBD.AMOUNT AS "Amount",
          APBD.ENTRYDESCRIPTION AS "Line_Memo",
          CASE WHEN APBH.SYSTEMGENERATED ='T'
            THEN
              'Manual'
            ELSE
              CASE WHEN APBH.DESCRIPTION2 IS NOT NULL
              THEN
                  CASE WHEN APBH.YOOZ_DOCID IS NOT NULL
                  THEN 'Purchase Conversion by Yooz'
                  ELSE 'Purchase Conversion by Intacct'
                  END
              ELSE
                  CASE WHEN APBH.YOOZ_DOCID IS NOT NULL
                  THEN 'Yooz AP Bill'
                  ELSE 'Direct AP Bill'
                  END
              END
          END AS "Processing_Method",
          DATE_TRUNC('MONTH', APBH.WHENCREATED) AS "Bill_First_Day",
          ROUND(APBD.AMOUNT - LAG(APBD.AMOUNT, 12) OVER (ORDER BY APBH.WHENCREATED), 2) AS "YOY_Growth_Amount",
          ROUND((APBD.AMOUNT - LAG(APBD.AMOUNT, 12) OVER (ORDER BY APBH.WHENCREATED)) / NULLIF(LAG(APBD.AMOUNT, 12) OVER (ORDER BY APBH.WHENCREATED), 0), 2) AS "YOY_Growth_Percentage"
      FROM
          "ANALYTICS"."INTACCT"."APRECORD" APBH
          LEFT JOIN "ANALYTICS"."INTACCT"."APDETAIL" APBD ON APBH.RECORDNO = APBD.RECORDKEY
          LEFT JOIN "ANALYTICS"."INTACCT"."VENDOR" VEND ON APBH.VENDORID = VEND.VENDORID
          LEFT JOIN "ANALYTICS"."INTACCT"."GLACCOUNT" GLA ON APBD.ACCOUNTNO = GLA.ACCOUNTNO
          LEFT JOIN
              (SELECT
                  RECORDNO,
                  RECORD_URL
              FROM
                  "ANALYTICS"."PUBLIC"."RECORD_URL"
              WHERE
                  INTACCT_OBJECT = 'APBILL') URL ON APBH.RECORDNO = URL.RECORDNO
      WHERE
          APBH.RECORDTYPE = 'apbill'
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

  dimension: vendor_type {
    type: string
    sql: ${TABLE}."Vendor_Type" ;;
  }

  dimension: vendor_category {
    type: string
    sql: ${TABLE}."Vendor_Category" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."Status" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."Vendor_Name" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."Bill_Number" ;;
  }

  dimension: bill_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."Bill_Date" ;;
  }

  dimension_group: bill_date2 {
    convert_tz: no
    type: time
    view_label: "Bill_Date"
    timeframes: [
      month,
      month_name,
      month_num,
      year
    ]
    sql: ${TABLE}."Bill_Date" ;;
  }

  dimension: bill_month {
    type: string
    sql: ${TABLE}."Bill_Month" ;;
  }

  dimension: bill_year {
    type: string
    sql: ${TABLE}."Bill_Year" ;;
  }

  dimension: due_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."Due_Date" ;;
  }

  dimension: paid_date {
    convert_tz: no
    type: date
    sql: ${TABLE}."Paid_Date" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."Terms" ;;
  }

  dimension: bill_memo {
    type: string
    sql: ${TABLE}."Bill_Memo" ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: line_no {
    type: string
    sql: ${TABLE}."Line_No" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."Account" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."Account_Name" ;;
  }

  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }

  dimension: account_category {
    type: string
    sql: ${TABLE}."ACCOUNT_CATEGORY" ;;
  }

  dimension: account_close_type {
    type: string
    sql: ${TABLE}."ACCOUNT_CLOSE_TYPE" ;;
  }

  dimension: account_normal_balance {
    type: string
    sql: ${TABLE}."ACCOUNT_NORMAL_BALANCE" ;;
  }

  dimension: branch_id {
    type: string
    sql: ${TABLE}."Branch_ID" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."Asset_ID" ;;
  }

  measure: amount {
    type: sum
    sql: ${TABLE}."Amount" ;;
  }

  measure: amount_change {
    type: number
    sql: ${TABLE}."Amount" - offset(${TABLE}."Amount", 1, APBH.WHENCREATED, 'YEAR');;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."Line_Memo" ;;
  }

  dimension: processing_method {
    type: string
    sql: ${TABLE}."Processing_Method" ;;
  }

  measure: yoy_growth_amount {
    type: sum
    sql: ${TABLE}."YOY_Growth_Amount" ;;
  }

  measure: yoy_growth_percentage {
    type: sum
    sql: ${TABLE}."YOY_Growth_Percentage" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      vendor_type,
      vendor_category,
      status,
      bill_number,
      bill_date,
      bill_date2_month,
      bill_month,
      bill_year,
      due_date,
      paid_date,
      terms,
      bill_memo,
      url,
      po_number,
      line_no,
      account,
      account_name,
      account_type,
      account_category,
      account_close_type,
      account_normal_balance,
      branch_id,
      asset_id,
      amount,
      amount_change,
      line_memo,
      processing_method,
      yoy_growth_amount,
      yoy_growth_percentage
    ]
  }
}
