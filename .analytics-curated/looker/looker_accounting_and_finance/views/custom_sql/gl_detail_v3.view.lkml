
view: gl_detail_v3 {
  derived_table: {
    sql: SELECT GLB.JOURNAL                                                                                      AS JOURNAL,
                 GD.URL_JOURNAL,
                 GLB.MODULE                                                                                       AS MODULE,
                 GLB.BATCHNO                                                                                      AS BATCH_NUMBER,
                 GLB.STATE                                                                                        AS BATCH_STATE,
                 //       PD.fk_po_line_id                                                                                     AS fk_po_line_id,
                 //       pd.fk_po_header_id                                                                        AS fk_po_header_id,
                 CASE WHEN GLB.JOURNAL != 'APA' THEN APH.VENDORID ELSE PD.VENDOR_ID END                           AS VENDOR_ID,
                 CASE WHEN GLB.JOURNAL != 'APA' THEN VEND.NAME ELSE PD.VENDOR_NAME END                            AS VENDOR_NAME,
                 PD.RECEIPT_NUMBER                                                                                AS RECEIPT_NO,
                 PD.URL_SAGE                                                                                      AS PO_URL,
                 PD.URL_CONCUR                                                                                    AS CONCUR_URL,
                 PD.PO_STATE                                                                                      AS PO_STATE,
                 PD.DOCUMENT_NAME                                                                                 AS DOCUMENT_NAME,
                 CASE
                     WHEN GLB.JOURNAL != 'APA' THEN APH.RECORDID
                     ELSE AD.INVOICE_NUMBER END                                                                   AS INVOICE_NUMBER,
                 AD.URL_INVOICE,
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
                 PD.LINE_NUMBER                                                                                   AS PO_LINE_NUMBER,
                 GLE.DEPARTMENT                                                                                   AS SUB_DEPARTMENT_ID,
                 DEPT.TITLE                                                                                       AS SUB_DEPARTMENT_NAME,
                 GLE.GLDIMEXPENSE_LINE                                                                            AS EXPENSE_LINE_ID,
                 EXPLN.NAME                                                                                       AS EXPENSE_LINE_NAME,
                 PD.LINE_DESCRIPTION                                                                              AS LINE_DESCRIPTION,
                 GLE.ACCOUNTNO                                                                                    AS GL_ACCOUNT,
                 GLA.TITLE                                                                                        AS GL_NAME,
                 GLA.ACCOUNTTYPE                                                                                  AS GL_ACCOUNT_TYPE,
                 GLA.NORMALBALANCE                                                                                AS GL_ACCOUNT_NORMAL_BALANCE,
                 GLE.DESCRIPTION                                                                                  AS LINE_MEMO,
                 (CASE WHEN gd.FK_GL_RESOLVE_ID IS NOT NULL THEN gd.raw_AMOUNT ELSE GLE.AMOUNT END) *
                 GLE.TR_TYPE                                                                                      AS AMOUNT_NET,
                 GLE.CURRENCY                                                                                     AS AMOUNT_CURRENCY,
                 (CASE WHEN gd.FK_GL_RESOLVE_ID IS NOT NULL THEN gd.raw_AMOUNT ELSE GLE.TRX_AMOUNT END) *
                 GLE.TR_TYPE                                                                                      AS TRX_NET,
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
                 APH.RECORDID                                                                                     AS BILL_NUMBER,
                 ARH.CUSTOMERID                                                                                   AS CUSTOMER_ID,
                 CUST.NAME                                                                                        AS CUSTOMER_NAME,
                 CMH.DESCRIPTION                                                                                  AS CM_DESCRIPTION_1,
                 CMH.DESCRIPTION2                                                                                 AS CM_DESCRIPTION_2,
                 CMH.DEPOSITID                                                                                    AS CM_DEPOSIT_ID,
                 CMH.STATE                                                                                        AS CM_STATE,
                 CMH.TRANSACTIONTYPE                                                                              AS CM_TRANSACTION_TYPE,
                 CMH.PAYMETHOD                                                                                    AS CM_PAY_METHOD,
                 CMH.BANKACCOUNTID                                                                                AS CM_BANK_ID
          FROM ANALYTICS.INTACCT.GLBATCH GLB
                   LEFT JOIN ANALYTICS.INTACCT.GLENTRY GLE
                             ON GLB.RECORDNO = GLE.BATCHNO
                   LEFT JOIN analytics.intacct_models.gl_detail GD
                             ON GLE.RECORDNO = GD.FK_GL_ENTRY_ID
                   LEFT JOIN analytics.intacct_models.po_detail PD
                             ON PD.FK_PO_LINE_ID = GD.FK_SUBLEDGER_LINE_ID
                                 and gd.INTACCT_MODULE = '9.PO'
                   LEFT JOIN analytics.INTACCT_MODELS.po_detail pd_v
                             on pd_v.FK_SOURCE_PO_LINE_ID = PD.FK_PO_LINE_ID
                   left join analytics.INTACCT_MODELS.AP_DETAIL AD
                             on ad.LINE_NUMBER - 1 = pd_v.LINE_NUMBER
                                 and ad.source_document_name = pd_v.document_name
                   LEFT JOIN ANALYTICS.INTACCT.USERINFO UI1
                             ON GLB.USERKEY = UI1.RECORDNO
                   LEFT JOIN ANALYTICS.INTACCT.USERINFO UI2
                             ON GLB.CREATEDBY = UI2.RECORDNO
                   LEFT JOIN ANALYTICS.INTACCT.USERINFO UI3
                             ON GLB.MODIFIEDBY = UI3.RECORDNO
                   LEFT JOIN ANALYTICS.INTACCT.APRECORD APH
                             ON gd.FK_SUBLEDGER_HEADER_ID = APH.RECORDNO
                                 and gd.INTACCT_MODULE = '3.AP'
                   LEFT JOIN ANALYTICS.INTACCT.ARRECORD ARH
                             ON gd.FK_SUBLEDGER_HEADER_ID = ARH.RECORDNO
                                 and gd.INTACCT_MODULE = '4.AR'
                   LEFT JOIN ANALYTICS.INTACCT.CMRECORD CMH
                             ON gd.FK_SUBLEDGER_HEADER_ID = CMH.RECORDNO
                                 and gd.INTACCT_MODULE = '11.CM'
                   LEFT JOIN ANALYTICS.INTACCT.GLACCOUNT GLA
                             ON GLE.ACCOUNTNO = GLA.ACCOUNTNO
                   LEFT JOIN ANALYTICS.INTACCT.DEPARTMENT DEPT
                             ON GLE.DEPARTMENTKEY = DEPT.RECORDNO
                   LEFT JOIN ANALYTICS.INTACCT.EXPENSE_LINE EXPLN
                             ON GLE.GLDIMEXPENSE_LINE = EXPLN.ID
                   LEFT JOIN ANALYTICS.INTACCT.VENDOR VEND
                             ON APH.VENDORID = VEND.VENDORID
                   LEFT JOIN ANALYTICS.INTACCT.CUSTOMER CUST
                             ON ARH.CUSTOMERID = CUST.CUSTOMERID ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
    html: <a href="{{ url_journal._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;
  }

  dimension: url_journal {
    type: string
    sql: ${TABLE}."URL_JOURNAL" ;;
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

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: receipt_no {
    type: string
    sql: ${TABLE}."RECEIPT_NO" ;;
    html: <a href="{{ po_url._value }}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: po_url {
    type: string
    label: "PO URL"
    sql: ${TABLE}."PO_URL" ;;
    html: <a href="{{value}}" target="_blank" style="color: blue;">Link</a> ;;
  }

  dimension: concur_url {
    type: string
    sql: ${TABLE}."CONCUR_URL" ;;
  }

  dimension: po_state {
    type: string
    sql: ${TABLE}."PO_STATE" ;;
  }

  dimension: document_name {
    type: string
    sql: ${TABLE}."DOCUMENT_NAME" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
    html: <a href="{{ url_invoice._value }}" target="_blank" style="color: blue;">{{rendered_value}}</a> ;;
  }

  dimension: url_invoice {
    type: string
    label: "URL Invoice"
    sql: ${TABLE}."URL_INVOICE" ;;
  }

  dimension: is_statistical {
    type: string
    sql: ${TABLE}."IS_STATISTICAL" ;;
  }

  dimension: post_date {
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

  dimension: po_line_number {
    type: number
    label: "PO Line Number"
    sql: ${TABLE}."PO_LINE_NUMBER" ;;
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

  dimension: line_description {
    type: string
    sql: ${TABLE}."LINE_DESCRIPTION" ;;
  }

  dimension: gl_account {
    type: string
    label: "GL Account"
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: gl_name {
    type: string
    label: "GL Name"
    sql: ${TABLE}."GL_NAME" ;;
  }

  dimension: gl_account_type {
    type: string
    label: "GL Account Type"
    sql: ${TABLE}."GL_ACCOUNT_TYPE" ;;
  }

  dimension: gl_account_normal_balance {
    type: string
    label: "GL Account Normal Balance"
    sql: ${TABLE}."GL_ACCOUNT_NORMAL_BALANCE" ;;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."LINE_MEMO" ;;
  }

  measure: amount_net {
    type: sum
    label: "Amount_Net"
    sql: ${TABLE}."AMOUNT_NET" ;;
    value_format_name: usd
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

  dimension: cm_description_1 {
    type: string
    label: "CM Description 1"
    sql: ${TABLE}."CM_DESCRIPTION_1" ;;
  }

  dimension: cm_description_2 {
    type: string
    label: "CM Description 2"
    sql: ${TABLE}."CM_DESCRIPTION_2" ;;
  }

  dimension: cm_deposit_id {
    type: string
    label: "CM Deposit ID"
    sql: ${TABLE}."CM_DEPOSIT_ID" ;;
  }

  dimension: cm_state {
    type: string
    label: "CM State"
    sql: ${TABLE}."CM_STATE" ;;
  }

  dimension: cm_transaction_type {
    type: string
    label: "CM Transaction Type"
    sql: ${TABLE}."CM_TRANSACTION_TYPE" ;;
  }

  dimension: cm_pay_method {
    type: string
    label: "CM Pay Method"
    sql: ${TABLE}."CM_PAY_METHOD" ;;
  }

  dimension: cm_bank_id {
    type: string
    label: "CM Bank ID"
    sql: ${TABLE}."CM_BANK_ID" ;;
  }

  set: detail {
    fields: [
        journal,
        module,
        batch_number,
        batch_state,
        vendor_id,
        vendor_name,
        receipt_no,
        po_url,
        concur_url,
        po_state,
        document_name,
        invoice_number,
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
        po_line_number,
        sub_department_id,
        sub_department_name,
        expense_line_id,
        expense_line_name,
        line_description,
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
        bill_number,
        customer_id,
        customer_name,
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
