view: gl_detail {
  derived_table: {
    sql: SELECT
          GLB.RECORDNO AS "Recordno",
          GLB.JOURNAL AS "Journal_Type",
          CAST(GLB.BATCH_DATE AS DATE) AS "Posting_Date",
          GLB.STATE AS "State",
          GLB.BATCHNO AS "Transaction_Number",
          GLB.BATCH_TITLE AS "Description",
          GLB.CREATEDBY AS "Created_By_ID",
          GLB.MODIFIEDBY AS "ModOrApp_By_ID",
          GLB.WHENCREATED AS "Date_Created",
          GLB.WHENMODIFIED AS "Date_Modified",
          GLE.ACCOUNTNO AS "Account",
          CASE WHEN GLE.TR_TYPE = 1 THEN GLE.AMOUNT ELSE 0 END AS "Debit_Amount",
          CASE WHEN GLE.TR_TYPE <>1 THEN GLE.AMOUNT ELSE 0 END AS "Credit_Amount",
          CASE WHEN GLE.TR_TYPE = 1 THEN GLE.AMOUNT ELSE GLE.AMOUNT * -1 END AS "Net_Amount",
          GLE.DESCRIPTION AS "Memo",
          GLE.DEPARTMENT AS "Location",
          GLE.LOCATION AS "Entity",
          GLE.CUSTOMERID AS "Customer_ID",
          GLE.VENDORID AS "Vendor_ID",
          GLE.EMPLOYEEID AS "Employee_ID",
          GLE.ITEMID AS "Item_ID",
          GLE.LINE_NO AS "Line_No",
          CASE WHEN GLE.STATISTICAL = 'F' THEN 'Financial' ELSE 'Statistical' END AS "Entry_Type",
          RU.RECORD_URL as "URL"
      FROM "ANALYTICS"."INTACCT"."GLBATCH" GLB
      JOIN "ANALYTICS"."INTACCT"."GLENTRY" GLE
        ON GLB.RECORDNO = GLE.BATCHNO
      LEFT JOIN "ANALYTICS"."PUBLIC"."RECORD_URL" RU
        ON GLB.RECORDNO = RU.RECORDNO
      WHERE
        RU.INTACCT_OBJECT = 'GLBATCH'
      ORDER BY GLB.BATCH_DATE
      --WHERE
          --GLB.STATE = 'Posted' AND
          --CAST(GLB.BATCH_DATE AS DATE) >= '2020-01-01' AND
          --CAST(GLB.BATCH_DATE AS DATE) <= '2020-12-31' AND
          --GLE.STATISTICAL = 'F' AND
          --GLE.ACCOUNTNO = 6000 AND
          --GLB.BATCHNO = 4193

       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: recordno {
    type: string
    sql: ${TABLE}."Recordno" ;;
  }

  dimension: journal_type {
    type: string
    sql: ${TABLE}."Journal_Type" ;;
  }

  dimension: posting_date {
    type: date
    sql: ${TABLE}."Posting_Date" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."State" ;;
  }

  dimension: transaction_number {
    type: number
    value_format: "0"
    sql: ${TABLE}."Transaction_Number" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."Description" ;;
  }

  dimension: created_by_id {
    type: number
    sql: ${TABLE}."Created_By_ID" ;;
  }

  dimension: mod_or_app_by_id {
    type: number
    sql: ${TABLE}."ModOrApp_By_ID" ;;
  }

  dimension: date_created {
    type: string
    sql: ${TABLE}."Date_Created" ;;
  }

  dimension: date_modified {
    type: string
    sql: ${TABLE}."Date_Modified" ;;
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

  dimension: net_amount {
    type: number
    sql: ${TABLE}."Net_Amount" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."Memo" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."Location" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."Entity" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."Customer_ID" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."Vendor_ID" ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}."Employee_ID" ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}."Item_ID" ;;
  }

  dimension: line_no {
    type: number
    sql: ${TABLE}."Line_No" ;;
  }

  dimension: entry_type {
    type: string
    sql: ${TABLE}."Entry_Type" ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
    html: <a href = "{{ gl_detail.url._value }}" target="_blank">
         <img src="https://www.sageintacct.com/favicon.ico" width="16" height="16"> Intacct</a>
         &nbsp; ;;
  }

  set: detail {
    fields: [
      recordno,
      journal_type,
      posting_date,
      state,
      transaction_number,
      description,
      created_by_id,
      mod_or_app_by_id,
      date_created,
      date_modified,
      account,
      debit_amount,
      credit_amount,
      net_amount,
      memo,
      location,
      entity,
      customer_id,
      vendor_id,
      employee_id,
      item_id,
      line_no,
      entry_type,
      url
    ]
  }
}
