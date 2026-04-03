view: intacct_gl_high_detail_filtered {
  derived_table: {
    sql: SELECT *
FROM ANALYTICS.FINANCIAL_SYSTEMS.GL_HIGH_DETAIL GHD
WHERE GHD.VENDOR_ID IN (
    'V12074', 'V12075', 'V25867', 'V12750', 'V27903', 'V12154', 'V20683', 'V21608', 'V24866', 'V26572',
    'V27158', 'V28818', 'V30471', 'V32348', 'V32697', 'V34091', 'V12588', 'V26033', 'V27665', 'V30469',
    'V31846', 'V33104', 'V12191', 'V12347', 'V11958', 'V12471', 'V23810', 'V27655', 'V11334', 'V12159',
    'V11419', 'V11421', 'V11422', 'V11746', 'V11883', 'V12135', 'V12711', 'V20499', 'V20584', 'V21009',
    'V23905', 'V23985', 'V24768', 'V24787', 'V25806', 'V26868', 'V27172', 'V27290', 'V27676', 'V27725',
    'V28590', 'V28654', 'V28974', 'V30802', 'V31909', 'V32976', 'V33333', 'V33335', 'V33437', 'V34947',
    'V11442', 'V12374', 'V20926', 'V11721', 'V21986', 'V34300', 'V11785', 'V12416', 'V21986', 'V28104',
    'V12241', 'V24016', 'V30527', 'V31136', 'V34800', 'V11942', 'V12006', 'V32966', 'V11401', 'V11652',
    'V24024', 'V32370', 'V12390', 'V12964', 'V21400', 'V23916', 'V25089', 'V26914', 'V26934', 'V28126',
    'V28776', 'V29812', 'V31563', 'V20193', 'V26125', 'V26687', 'V29023', 'V37680', 'V24606', 'V25864',
    'V24233', 'V24774', 'V21099', 'V24773', 'V24833', 'V20602', 'V12188', 'V28206', 'V12235', 'V21063',
    'V11474', 'V11867', 'V34418', 'V25069', 'V11821', 'V30595', 'V12603', 'V24244', 'V27405', 'V34759',
    'V12311', 'V12654', 'V37488', 'V28748', 'V12191', 'V32060', 'V11620', 'V23851', 'V12799', 'V11354',
    'V12859', 'V12829', 'V12892', 'V20902', 'V26183'
);;
  }

  measure: count {type: count drill_fields: [detail*]}
  dimension: glbatch_recordno {type: number sql: ${TABLE}."GLBATCH_RECORDNO" ;;}
  dimension: glentry_recordno {type: number sql: ${TABLE}."GLENTRY_RECORDNO" ;;}
  dimension: glresolve_recordno {type: number sql: ${TABLE}."GLRESOLVE_RECORDNO" ;;}
  dimension: journal {type: string sql: ${TABLE}."JOURNAL" ;;}
  dimension: module {type: string sql: ${TABLE}."MODULE" ;;}
  dimension: batch_number {type: number sql: ${TABLE}."BATCH_NUMBER" ;;
    html: <a href="{{ glb_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;}
  dimension: post_date {convert_tz: no type: date sql: ${TABLE}."POST_DATE" ;;}
  dimension: originator_id {type: number sql: ${TABLE}."ORIGINATOR_ID" ;;}
  dimension: originator_name {type: string sql: ${TABLE}."ORIGINATOR_NAME" ;;}
  dimension: submitter_id {type: number sql: ${TABLE}."SUBMITTER_ID" ;;}
  dimension: submitter_name {type: string sql: ${TABLE}."SUBMITTER_NAME" ;;}
  dimension: approver_id {type: number sql: ${TABLE}."APPROVER_ID" ;;}
  dimension: approver_name {type: string sql: ${TABLE}."APPROVER_NAME" ;;}
  dimension: header_memo {type: string sql: ${TABLE}."HEADER_MEMO" ;;}
  dimension: entity {type: string sql: ${TABLE}."ENTITY" ;;}
  dimension: sub_department_id {type: string sql: ${TABLE}."SUB_DEPARTMENT_ID" ;;}
  dimension: sub_department_name {type: string sql: ${TABLE}."SUB_DEPARTMENT_NAME" ;;}
  dimension: expense_line_id {type: number sql: ${TABLE}."EXPENSE_LINE_ID" ;;}
  dimension: expense_line_name {type: string sql: ${TABLE}."EXPENSE_LINE_NAME" ;;}
  dimension: gl_account {type: string sql: ${TABLE}."GL_ACCOUNT" ;;}
  dimension: gl_account_ultimate {type: string sql: ${TABLE}."GL_ACCOUNT_ULTIMATE" ;;}
  dimension: gl_name {type: string sql: ${TABLE}."GL_NAME" ;;}
  dimension: line_memo {type: string sql: ${TABLE}."LINE_MEMO" ;;}
  dimension: document {type: string sql: ${TABLE}."DOCUMENT" ;;}
  measure: amount_debit {type: sum sql: ${TABLE}."AMOUNT_DEBIT" ;;}
  measure: amount_credit {type: sum sql: ${TABLE}."AMOUNT_CREDIT" ;;}
  measure: amount_net {type: sum sql: ${TABLE}."AMOUNT_NET" ;;}
  dimension: amount_currency {type: number sql: ${TABLE}."AMOUNT_CURRENCY" ;;}
  measure: trx_debit {type: sum sql: ${TABLE}."TRX_DEBIT" ;;}
  measure: trx_credit {type: sum sql: ${TABLE}."TRX_CREDIT" ;;}
  measure: trx_net {type: sum sql: ${TABLE}."TRX_NET" ;;}
  dimension: trx_currency {type: string sql: ${TABLE}."TRX_CURRENCY" ;;}
  dimension: record_type {type: string sql: ${TABLE}."RECORD_TYPE" ;;}
  dimension: reference {type: string sql: ${TABLE}."REFERENCE" ;;
    html: <a href="{{ po_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;}
  dimension: po_state {type: string sql: ${TABLE}."PO_STATE" ;;}
  dimension: vendor_id {type: string sql: ${TABLE}."VENDOR_ID" ;;}
  dimension: vendor_name {type: string sql: ${TABLE}."VENDOR_NAME" ;;}
  dimension: bill_number {type: string sql: ${TABLE}."BILL_NUMBER" ;;
    html: <a href="{{ ap_intacct_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;}
  dimension: bill_date {convert_tz: no type: date sql: ${TABLE}."BILL_DATE" ;;}
  dimension: bill_paid_on {convert_tz: no type: date sql: ${TABLE}."BILL_PAID_ON" ;;}
  measure: bill_total {type: sum sql: ${TABLE}."BILL_TOTAL" ;;}
  dimension: customer_id {type: string sql: ${TABLE}."CUSTOMER_ID" ;;}
  dimension: customer_name {type: string sql: ${TABLE}."CUSTOMER_NAME" ;;}
  dimension: invoice_number {type: string sql: ${TABLE}."INVOICE_NUMBER" ;;}
  dimension: cm_description_1 {type: string sql: ${TABLE}."CM_DESCRIPTION_1" ;;}
  dimension: cm_description_2 {type: string sql: ${TABLE}."CM_DESCRIPTION_2" ;;}
  dimension: cm_deposit_id {type: string sql: ${TABLE}."CM_DEPOSIT_ID" ;;}
  dimension: cm_state {type: string sql: ${TABLE}."CM_STATE" ;;}
  dimension: cm_transaction_type {type: number sql: ${TABLE}."CM_TRANSACTION_TYPE" ;;}
  dimension: cm_pay_method {type: string sql: ${TABLE}."CM_PAY_METHOD" ;;}
  dimension: cm_bank_id {type: string sql: ${TABLE}."CM_BANK_ID" ;;}
  dimension: concur_pdf {type: string sql: ${TABLE}."BILL_NUMBER" ;;
    html: <a href="{{ ap_bill_image_url._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a> ;;}
  dimension: ap_intacct_url {type: string sql: ${TABLE}."AP_INTACCT_URL" ;;}
  dimension: ap_bill_image_url {type: string sql: ${TABLE}."AP_BILL_IMAGE_URL" ;;}
  dimension: po_url {type: string sql: ${TABLE}."PO_URL" ;;}
  dimension: glb_url {type: string sql: ${TABLE}."GLB_URL" ;;}
  dimension: when_created {type: date_time sql: ${TABLE}."WHEN_CREATED" ;;}

  set: detail {
    fields: [
      glbatch_recordno,
      glentry_recordno,
      glresolve_recordno,
      journal,
      module,
      batch_number,
      post_date,
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
      gl_account_ultimate,
      gl_name,
      line_memo,
      document,
      amount_debit,
      amount_credit,
      amount_net,
      amount_currency,
      trx_debit,
      trx_credit,
      trx_net,
      trx_currency,
      record_type,
      reference,
      po_state,
      vendor_id,
      vendor_name,
      bill_number,
      bill_date,
      bill_paid_on,
      bill_total,
      customer_id,
      customer_name,
      invoice_number,
      cm_description_1,
      cm_description_2,
      cm_deposit_id,
      cm_state,
      cm_transaction_type,
      cm_pay_method,
      cm_bank_id,
      ap_intacct_url,
      ap_bill_image_url,
      po_url,
      glb_url,
      when_created,
      concur_pdf
    ]
  }
}
