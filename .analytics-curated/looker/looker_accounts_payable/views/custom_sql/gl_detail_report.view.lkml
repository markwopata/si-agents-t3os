view: gl_detail_report {
  derived_table: {
    sql: SELECT
          GLB.RECORDNO,
          GLB.JOURNAL AS "Journal",
          GLB.BATCH_DATE AS "Posting_Date",
          GLB.STATE,
          GLB.BATCHNO AS "Transaction_Number",
          GLB.BATCH_TITLE AS "Description",
          GLE.ACCOUNTNO AS "Account",
          CASE WHEN GLE.TR_TYPE = 1 THEN GLE.AMOUNT ELSE 0 END AS "Debit_Amount",
          CASE WHEN GLE.TR_TYPE <>1 THEN GLE.AMOUNT ELSE 0 END AS "Credit_Amount",
          GLE.DESCRIPTION AS "Memo",
          GLE.DEPARTMENT AS "Location",
          GLE.LOCATION AS "Company",
          GLE.LINE_NO AS "Line_No"
      FROM "ANALYTICS"."SAGE_INTACCT"."GL_BATCH" GLB
          JOIN "ANALYTICS"."PUBLIC"."GLENTRY" GLE ON GLB.RECORDNO = GLE.BATCHNO
      WHERE
          GLB.STATE = 'Posted' AND
          try_to_number(GLE.ACCOUNTNO) IS NOT NULL
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: recordno {
    type: string
    sql: ${TABLE}."RECORDNO" ;;
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."Journal" ;;
  }

  dimension: posting_date {
    type: string
    sql: ${TABLE}."Posting_Date" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: transaction_number {
    type: number
    sql: ${TABLE}."Transaction_Number" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."Description" ;;
  }

  dimension: account {
    type: string
    sql: ${TABLE}."Account" ;;
  }

  dimension: debit_amount {
    type: number
    sql: ${TABLE}."Debit_Amount" ;;
  }

  dimension: credit_amount {
    type: number
    sql: ${TABLE}."Credit_Amount" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."Memo" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."Location" ;;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."Company" ;;
  }

  dimension: line_no {
    type: string
    sql: ${TABLE}."Line_No" ;;
  }

  set: detail {
    fields: [
      recordno,
      journal,
      posting_date,
      state,
      transaction_number,
      description,
      account,
      debit_amount,
      credit_amount,
      memo,
      location,
      company,
      line_no
    ]
  }
}
