view: ap_bill_detail_report {
  derived_table: {
    sql: SELECT
          APBH.VENDORID AS "Vendor_ID",
          VEND.NAME AS "Vendor_Name",
          APBH.RECORDID AS "Bill_Number",
          APBH.WHENCREATED AS "Bill_Date",
          APBH.WHENPOSTED AS "GL_Posting_Date",
          APBH.WHENDUE AS "Due_Date",
          APBH.TERMNAME AS "Terms",
          APBH.DESCRIPTION AS "Bill_Memo",
          APBD.LINE_NO AS "Line_No",
          APBD.ACCOUNTNO AS "Account",
          GLA.TITLE AS "Account_Name",
          APBD.DEPARTMENTID AS "Branch_ID",
          APBD.AMOUNT AS "Amount",
          APBD.ENTRYDESCRIPTION AS "Line_Memo"
      FROM
          "ANALYTICS"."PUBLIC"."APRECORD" APBH
          LEFT JOIN "ANALYTICS"."PUBLIC"."APDETAIL" APBD ON APBH.RECORDNO = APBD.RECORDKEY
          LEFT JOIN "ANALYTICS"."PUBLIC"."VENDOR" VEND ON APBH.VENDORID = VEND.VENDORID
          LEFT JOIN "ANALYTICS"."PUBLIC"."GLACCOUNT" GLA ON APBD.ACCOUNTNO = GLA.ACCOUNTNO
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

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."Vendor_Name" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."Bill_Number" ;;
  }

  dimension: bill_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."Bill_Date" ;;
  }

  dimension: gl_posting_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."GL_Posting_Date" ;;
  }

  dimension: due_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."Due_Date" ;;
  }

  dimension: terms {
    type: string
    sql: ${TABLE}."Terms" ;;
  }

  dimension: bill_memo {
    type: string
    sql: ${TABLE}."Bill_Memo" ;;
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

  dimension: branch_id {
    type: string
    sql: ${TABLE}."Branch_ID" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."Amount" ;;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."Line_Memo" ;;
  }

  set: detail {
    fields: [
      vendor_id,
      vendor_name,
      bill_number,
      bill_date,
      gl_posting_date,
      due_date,
      terms,
      bill_memo,
      line_no,
      account,
      account_name,
      branch_id,
      amount,
      line_memo
    ]
  }
}
