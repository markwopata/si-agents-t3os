view: intacct_gl_activity_dds_new {
  derived_table: {
    sql: SELECT
          GLB.JOURNAL                                                                                      AS JOURNAL,
          GLB.MODULE                                                                                       AS MODULE,
          GLB.BATCHNO                                                                                      AS BATCH_NUMBER,
          GLB.STATE                                                                                        AS BATCH_STATE,
          GLE.STATISTICAL                                                                                  AS IS_STATISTICAL,
          GLB.BATCH_DATE                                                                                   AS POST_DATE,
          YEAR(GLB.BATCH_DATE)                                                                             AS POST_YEAR,
          MONTH(GLB.BATCH_DATE)                                                                            AS POST_MONTH,
          GLB.USERKEY                                                                                      AS ORIGINATOR_ID,
          UI1.DESCRIPTION                                                                                  AS ORIGINATOR_NAME,
          GLB.CREATEDBY                                                                                    AS SUBMITTER_ID,
          UI2.DESCRIPTION                                                                                  AS SUBMITTER_NAME,
          GLB.MODIFIEDBY                                                                                   AS APPROVER_ID,
          UI3.DESCRIPTION                                                                                  AS APPROVER_NAME,
          GLB.BATCH_TITLE                                                                                  AS HEADER_MEMO,
          GLE.LOCATION                                                                                     AS ENTITY,
          GLE.DEPARTMENT                                                                                   AS SUB_DEPARTMENT_ID,
          DEPT.TITLE                                                                                       AS SUB_DEPARTMENT_NAME,
          GLE.GLDIMEXPENSE_LINE                                                                            AS EXPENSE_LINE_ID,
          EXPLN.NAME                                                                                       AS EXPENSE_LINE_NAME,
          GLE.ACCOUNTNO                                                                                    AS GL_ACCOUNT,
          GLA.TITLE                                                                                        AS GL_NAME,
          GLA.ACCOUNTTYPE                                                                                  AS GL_ACCOUNT_TYPE,
          GLA.NORMALBALANCE                                                                                AS GL_ACCOUNT_NORMAL_BALANCE,
          GLE.DESCRIPTION                                                                                  AS LINE_MEMO,
          (CASE WHEN GLR.RECORDNO IS NOT NULL THEN GLR.AMOUNT ELSE GLE.AMOUNT END) * GLE.TR_TYPE           AS AMOUNT_NET,
          GLE.CURRENCY                                                                                     AS AMOUNT_CURRENCY,
          (CASE WHEN GLR.RECORDNO IS NOT NULL THEN GLR.TRX_AMOUNT ELSE GLE.TRX_AMOUNT END) * GLE.TR_TYPE   AS TRX_NET,
          GLE.BASECURR                                                                                     AS TRX_CURRENCY,
          CASE
              WHEN GLB.MODULE = '3.AP' THEN APH.RECORDTYPE
              ELSE (CASE
                        WHEN GLB.MODULE = '4.AR' THEN ARH.RECORDTYPE
                        ELSE (CASE WHEN GLB.MODULE = '11.CM' THEN CMH.RECORDTYPE ELSE (NULL) END) END) END AS RECORD_TYPE,
          CASE
              WHEN GLB.MODULE = '3.AP' THEN APH.DOCNUMBER
              ELSE (CASE
                        WHEN GLB.MODULE = '4.AR' THEN ARH.DOCNUMBER
                        ELSE (CASE WHEN GLB.MODULE = '11.CM' THEN CMH.DOCNUMBER ELSE (NULL) END) END) END  AS REFERENCE,
          APH.VENDORID                                                                                     AS VENDOR_ID,
          VEND.NAME                                                                                        AS VENDOR_NAME,
          APH.RECORDID                                                                                     AS BILL_NUMBER,
          ARH.CUSTOMERID                                                                                   AS CUSTOMER_ID,
          CUST.NAME                                                                                        AS CUSTOMER_NAME,
          ARH.RECORDID                                                                                     AS INVOICE_NUMBER,
          CMH.DESCRIPTION                                                                                  AS CM_DESCRIPTION_1,
          CMH.DESCRIPTION2                                                                                 AS CM_DESCRIPTION_2,
          CMH.DEPOSITID                                                                                    AS CM_DEPOSIT_ID,
          CMH.STATE                                                                                        AS CM_STATE,
          CMH.TRANSACTIONTYPE                                                                              AS CM_TRANSACTION_TYPE,
          CMH.PAYMETHOD                                                                                    AS CM_PAY_METHOD,
          CMH.BANKACCOUNTID                                                                                AS CM_BANK_ID
      FROM
          ANALYTICS.INTACCT.GLBATCH GLB
              LEFT JOIN ANALYTICS.INTACCT.GLENTRY GLE ON GLB.RECORDNO = GLE.BATCHNO
              LEFT JOIN ANALYTICS.INTACCT.GLRESOLVE GLR ON GLE.RECORDNO = GLR.GLENTRYKEY
              LEFT JOIN ANALYTICS.INTACCT.USERINFO UI1 ON GLB.USERKEY = UI1.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.USERINFO UI2 ON GLB.CREATEDBY = UI2.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.USERINFO UI3 ON GLB.MODIFIEDBY = UI3.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.APRECORD APH ON GLR.PRRECORDKEY = APH.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARH ON GLR.PRRECORDKEY = ARH.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.CMRECORD CMH ON GLR.PRRECORDKEY = CMH.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA ON GLE.ACCOUNTNO = GLA.ACCOUNTNO
              LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT ON GLE.DEPARTMENTKEY = DEPT.RECORDNO
              LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE EXPLN ON GLE.GLDIMEXPENSE_LINE = EXPLN.ID
              LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND ON APH.VENDORID = VEND.VENDORID
              LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST ON ARH.CUSTOMERID = CUST.CUSTOMERID
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: module {
    type: string
    sql: ${TABLE}."MODULE" ;;
  }

  dimension: batch_number {
    type: number
    sql: ${TABLE}."BATCH_NUMBER" ;;
  }

  dimension: batch_state {
    type: string
    sql: ${TABLE}."BATCH_STATE" ;;
  }

  dimension: is_statistical {
    type: string
    sql: ${TABLE}."IS_STATISTICAL" ;;
  }

  dimension: post_date {
    convert_tz:  no
    type: date
    sql: ${TABLE}."POST_DATE" ;;
  }

  dimension: post_year {
    type: number
    sql: ${TABLE}."POST_YEAR" ;;
  }

  dimension: post_month {
    type: number
    sql: ${TABLE}."POST_MONTH" ;;
  }

  dimension: originator_id {
    type: number
    sql: ${TABLE}."ORIGINATOR_ID" ;;
  }

  dimension: originator_name {
    type: string
    sql: ${TABLE}."ORIGINATOR_NAME" ;;
  }

  dimension: submitter_id {
    type: number
    sql: ${TABLE}."SUBMITTER_ID" ;;
  }

  dimension: submitter_name {
    type: string
    sql: ${TABLE}."SUBMITTER_NAME" ;;
  }

  dimension: approver_id {
    type: number
    sql: ${TABLE}."APPROVER_ID" ;;
  }

  dimension: approver_name {
    type: string
    sql: ${TABLE}."APPROVER_NAME" ;;
  }

  dimension: header_memo {
    type: string
    sql: ${TABLE}."HEADER_MEMO" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: sub_department_id {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;
  }

  dimension: sub_department_name {
    type: string
    sql: ${TABLE}."SUB_DEPARTMENT_NAME" ;;
  }

  dimension: expense_line_id {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_ID" ;;
  }

  dimension: expense_line_name {
    type: string
    sql: ${TABLE}."EXPENSE_LINE_NAME" ;;
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: gl_name {
    type: string
    sql: ${TABLE}."GL_NAME" ;;
  }

  dimension: gl_account_type {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_TYPE" ;;
  }

  dimension: gl_account_normal_balance {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NORMAL_BALANCE" ;;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."LINE_MEMO" ;;
  }

  dimension: amount_net {
    type: number
    sql: ${TABLE}."AMOUNT_NET" ;;
  }

  dimension: amount_currency {
    type: string
    sql: ${TABLE}."AMOUNT_CURRENCY" ;;
  }

  dimension: trx_net {
    type: number
    sql: ${TABLE}."TRX_NET" ;;
  }

  dimension: trx_currency {
    type: string
    sql: ${TABLE}."TRX_CURRENCY" ;;
  }

  dimension: record_type {
    type: string
    sql: ${TABLE}."RECORD_TYPE" ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: cm_description_1 {
    type: string
    sql: ${TABLE}."CM_DESCRIPTION_1" ;;
  }

  dimension: cm_description_2 {
    type: string
    sql: ${TABLE}."CM_DESCRIPTION_2" ;;
  }

  dimension: cm_deposit_id {
    type: string
    sql: ${TABLE}."CM_DEPOSIT_ID" ;;
  }

  dimension: cm_state {
    type: string
    sql: ${TABLE}."CM_STATE" ;;
  }

  dimension: cm_transaction_type {
    type: string
    sql: ${TABLE}."CM_TRANSACTION_TYPE" ;;
  }

  dimension: cm_pay_method {
    type: string
    sql: ${TABLE}."CM_PAY_METHOD" ;;
  }

  dimension: cm_bank_id {
    type: string
    sql: ${TABLE}."CM_BANK_ID" ;;
  }

  set: detail {
    fields: [
      journal,
      module,
      batch_number,
      batch_state,
      is_statistical,
      post_date,
      post_year,
      post_month,
      originator_id,
      originator_name,
      submitter_id,
      submitter_name,
      approver_id,
      approver_name,
      header_memo,
      entity,
      sub_department_id,
      sub_department_name,
      expense_line_id,
      expense_line_name,
      gl_account,
      gl_name,
      gl_account_type,
      gl_account_normal_balance,
      line_memo,
      amount_net,
      amount_currency,
      trx_net,
      trx_currency,
      record_type,
      reference,
      vendor_id,
      vendor_name,
      bill_number,
      customer_id,
      customer_name,
      invoice_number,
      cm_description_1,
      cm_description_2,
      cm_deposit_id,
      cm_state,
      cm_transaction_type,
      cm_pay_method,
      cm_bank_id
    ]
  }
}
