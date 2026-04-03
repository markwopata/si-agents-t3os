view: gl_approver_audit {
  derived_table: {
    sql: SELECT GLB.JOURNAL     AS JOURNAL,
       GLB.BATCHNO     AS TRANSACTION_NUMBER,
       GLB.BATCH_DATE  AS POSTING_DATE,
       GLB.BATCH_TITLE AS BATCH_TITLE,
       GLB.STATE       AS STATE,
       GLB.REFERENCENO AS REFERENCE,
       GLB.MODULE      AS MODULE,
       GLE.DEBIT,
       GLE.CREDIT,
       GLE.NET_AMOUNT,
       UI1.LOGINID     AS ORIGINATOR_ID,
       UI1.DESCRIPTION AS ORIGINATOR_NAME,
       UI2.LOGINID     AS SUBMITTER_ID,
       UI2.DESCRIPTION AS SUBMITTER_NAME,
       UI3.LOGINID     AS APPROVER_ID,
       UI3.DESCRIPTION AS APPROVER_NAME,
       url.RECORD_URL
FROM ANALYTICS.INTACCT.GLBATCH GLB
         LEFT JOIN (SELECT BATCHNO,
                           ROUND(SUM(CASE WHEN TR_TYPE = 1 THEN TRX_AMOUNT ELSE 0 END), 2)         AS DEBIT,
                           ROUND(SUM(CASE WHEN TR_TYPE = -1 THEN (TRX_AMOUNT * -1) ELSE 0 END), 2) AS CREDIT,
                           ROUND(SUM(TRX_AMOUNT * TR_TYPE), 2)                                     AS NET_AMOUNT
                    FROM ANALYTICS.INTACCT.GLENTRY
                    GROUP BY BATCHNO) GLE ON GLB.RECORDNO = GLE.BATCHNO
         LEFT JOIN ANALYTICS.INTACCT.USERINFO UI1 ON GLB.USERKEY = UI1.RECORDNO
         LEFT JOIN ANALYTICS.INTACCT.USERINFO UI2 ON GLB.CREATEDBY = UI2.RECORDNO
         LEFT JOIN ANALYTICS.INTACCT.USERINFO UI3 ON GLB.MODIFIEDBY = UI3.RECORDNO
         LEFT JOIN ANALYTICS.INTACCT.RECORD_URL url ON glb.RECORDNO = url.RECORDNO AND INTACCT_OBJECT = 'GLBATCH'
WHERE GLB.STATE = 'Posted'
  AND GLB.MODULE = '2.GL'
  AND CAST(GLB.BATCH_DATE AS DATE) > '2022-12-31'
  AND SUBMITTER_NAME = APPROVER_NAME ;;
  }

  dimension: journal {
    type: string
    label: "Journal"
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: transaction_number {
    type: string
    label: "Transaction Number"
    sql: ${TABLE}."TRANSACTION_NUMBER" ;;
    html: <a href="{{ record_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: record_url {
    type: string
    label: "Record URL"
    sql: ${TABLE}."RECORD_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: posting_date {
    type: date
    label: "Posting Date"
    sql: ${TABLE}."POSTING_DATE" ;;
  }

  dimension_group: posting_date_group {
    type: time
    label: "Posting Date Group"
    sql: ${TABLE}."POSTING_DATE" ;;
  }

  dimension: batch_title {
    type: string
    label: "Batch Title"
    sql: ${TABLE}."BATCH_TITLE" ;;
  }

  dimension: state {
    type: string
    label: "State"
    sql: ${TABLE}."STATE" ;;
  }

  dimension: reference {
    type: string
    label: "Reference"
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: module {
    type: string
    label: "Module"
    sql: ${TABLE}."MODULE" ;;
  }

  dimension: debit {
    type: number
    label: "Debit"
    sql: ${TABLE}."DEBIT" ;;
  }

  dimension: credit {
    type: number
    label: "Credit"
    sql: ${TABLE}."CREDIT" ;;
  }

  dimension: net_amount {
    type: number
    label: "Net Amount"
    sql: ${TABLE}."NET_AMOUNT" ;;
  }

  dimension: originator_id {
    type: string
    label: "Originator ID"
    sql: ${TABLE}."ORIGINATOR_ID" ;;
  }

  dimension: originator_name {
    type: string
    label: "Originator Name"
    sql: ${TABLE}."ORIGINATOR_NAME" ;;
  }

  dimension: submitter_id {
    type: string
    label: "Submitter ID"
    sql: ${TABLE}."SUBMITTER_ID" ;;
  }

  dimension: submitter_name {
    type: string
    label: "Submitter Name"
    sql: ${TABLE}."SUBMITTER_NAME" ;;
  }

  dimension: approver_id {
    type: string
    label: "Approver ID"
    sql: ${TABLE}."APPROVER_ID" ;;
  }

  dimension: approver_name {
    type: string
    label: "Approver Name"
    sql: ${TABLE}."APPROVER_NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      journal,
      transaction_number,
      posting_date,
      batch_title,
      state,
      reference,
      module,
      debit,
      credit,
      net_amount,
      originator_id,
      originator_name,
      submitter_id,
      submitter_name,
      approver_id,
      approver_name
    ]
  }
}
