
view: ap_accrual_invoice_to_receipt {
  derived_table: {
    sql: with ap_true_up_entries as (select split_part(gd1.ENTRY_DESCRIPTION, ' - ', 1) recordno,
                                             gd1.JOURNAL_TRANSACTION_NUMBER              var_journal_number,
                                             round(sum(gd1.amount), 2)                   var_posted_amount,
                                             gd1.entry_date                              var_posted_date,
                                             gd1.URL_JOURNAL
                                      from analytics.intacct_models.gl_detail gd1
                                      where gd1.JOURNAL_TYPE = 'APA'
                                        and gd1.ACCOUNT_NUMBER = '2014'
                                        AND gd1.CREATED_BY_USERNAME = 'APA_TRUE_UP'
                                      group by gd1.JOURNAL_TRANSACTION_NUMBER, gd1.entry_date, gd1.URL_JOURNAL,
                                               split_part(gd1.ENTRY_DESCRIPTION, ' - ', 1))
          select case
                     when pd_v.FK_PO_LINE_ID is not null then 'Vendor Invoice'
                     when pd_v.FK_PO_LINE_ID is null then 'AP Bill Keyed In' end source,
                 gd.entry_date,
                 gd.amount                                                       gl_amount,
                 gd.journal_title,
                 gd.JOURNAL_TRANSACTION_NUMBER                                   journal_number,
                 gd.URL_JOURNAL,
                 pd.receipt_number,
                 pd.gl_date                                                      receipt_date,
                 pd.quantity                                                     receipt_quantity,
                 pd.UNIT_PRICE                                                   receipt_price,
                 round(pd.EXTENDED_AMOUNT, 2)                                    receipt_amount,
                 pd.DEPARTMENT_ID                                                receipt_department_id,
                 pd.ENTITY_ID                                                    receipt_entity_id,
                 pd.EXPENSE_TYPE                                                 receipt_expense_type,
                 case
                     when pd_v.FK_PO_LINE_ID is not null then 'Initial Accrual Entry'
                     else 'Invoice' end                                          accrual_source,
                 pd.URL_SAGE                                                     url_receipt,
                 ad.VENDOR_ID,
                 ad.VENDOR_NAME,
                 ad.URL_INVOICE,
                 pd_v.document_type                                              relieved_by,
                 pd_v.VENDOR_INVOICE_NUMBER,
                 ad.INVOICE_NUMBER,
                 gd.entry_date                                                   date_relieved,
                 pd_v.quantity                                                   invoice_quantity,
                 pd_v.unit_price                                                 invoice_price,
                 coalesce(pd_v.EXTENDED_AMOUNT, ad.amount)                       invoice_amount,
                 right(pd_v.item_id, 4)                                          expense_account_number,
                 pd_v.DEPARTMENT_ID,
                 pd_v.ENTITY_ID,
                 pd_v.EXPENSE_TYPE,
                 round(pd_v.quantity * (pd_v.unit_price - pd.unit_price), 2)     variance_amount,
                 atue.var_journal_number,
                 atue.var_posted_amount,
                 atue.var_posted_date,
                 case
                     when atue.var_posted_amount is not null
                         then var_posted_amount = variance_amount end            var_amount_match,
                 atue.url_journal                                                url_var_journal,
                 atue.recordno                                                   var_recordno
          from analytics.INTACCT_MODELS.gl_detail gd
                   join analytics.INTACCT_MODELS.AP_DETAIL AD
                        on gd.FK_SUBLEDGER_LINE_ID = ad.FK_AP_LINE_ID
                            and gd.INTACCT_MODULE = '3.AP'
                   left join analytics.INTACCT_MODELS.po_detail pd_v -- Vendor Invoice
                             on ad.LINE_NUMBER - 1 = pd_v.LINE_NUMBER
                                 and ad.source_document_name = pd_v.document_name
                   left join (select distinct FK_SUBLEDGER_LINE_ID
                              from analytics.INTACCT_MODELS.gl_detail) gd_receipt_check -- Check if sage accrued the receipt for this invoice line
                             on pd_v.FK_SOURCE_PO_LINE_ID = gd_receipt_check.FK_SUBLEDGER_LINE_ID
                   left join analytics.INTACCT_MODELS.po_detail pd -- Receipt, if exists
                             on pd_v.FK_SOURCE_PO_LINE_ID = pd.FK_PO_LINE_ID
                   left join ap_true_up_entries atue -- Get AP variance entries posted by Sworks
                             on pd_v.FK_PO_LINE_ID::text = atue.recordno
          where gd.account_number = '2014' ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }

  dimension: entry_date {
    type: date
    sql: ${TABLE}."ENTRY_DATE" ;;
    convert_tz: no
  }

  measure: gl_amount {
    type: sum
    label: "GL Amount"
    sql: ${TABLE}."GL_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: journal_title {
    type: string
    sql: ${TABLE}."JOURNAL_TITLE" ;;
  }

  dimension: url_journal {
    type: string
    sql: ${TABLE}."URL_JOURNAL" ;;
  }

  dimension: journal_number {
    type: string
    sql: ${TABLE}.journal_number ;;
    html:  <a href="{{ url_journal._value }}" target="_blank" style="color: blue;">{{ rendered_value }}</a>;;
  }

  dimension: url_receipt {
    type: string
    sql: ${TABLE}."URL_RECEIPT" ;;
  }

  dimension: receipt_number {
    type: string
    sql: ${TABLE}."RECEIPT_NUMBER" ;;
    html:  <a href="{{ url_receipt._value }}" target="_blank" style="color: blue;">{{ rendered_value }}</a>;;
  }

  dimension: receipt_date {
    type: date
    sql: ${TABLE}."RECEIPT_DATE" ;;
    convert_tz: no
  }

  dimension: receipt_quantity {
    type: number
    sql: ${TABLE}."RECEIPT_QUANTITY" ;;
    value_format_name: decimal_2
  }

  dimension: receipt_price {
    type: number
    sql: ${TABLE}."RECEIPT_PRICE" ;;
    value_format_name: usd
  }

  measure: receipt_amount {
    type: sum
    sql: ${TABLE}."RECEIPT_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: receipt_department_id {
    type: string
    sql: ${TABLE}."RECEIPT_DEPARTMENT_ID" ;;
  }

  dimension: receipt_entity_id {
    type: string
    sql: ${TABLE}."RECEIPT_ENTITY_ID" ;;
  }

  dimension: receipt_expense_type {
    type: string
    sql: ${TABLE}."RECEIPT_EXPENSE_TYPE" ;;
  }

  dimension: accrual_source {
    type: string
    sql: ${TABLE}."ACCRUAL_SOURCE" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

  dimension: relieved_by {
    type: string
    sql: ${TABLE}."RELIEVED_BY" ;;
  }

  dimension: vendor_invoice_number {
    type: string
    sql: ${TABLE}."VENDOR_INVOICE_NUMBER" ;;
  }


  dimension: url_invoice {
    type: string
    sql: ${TABLE}."URL_INVOICE" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
    html: <a href="{{ url_invoice._value }}" target="_blank" style="color: blue;">{{ rendered_value }}</a>;;
  }

  dimension: date_relieved {
    type: date
    sql: ${TABLE}."DATE_RELIEVED" ;;
    convert_tz: no
  }

  dimension: invoice_quantity {
    type: number
    sql: ${TABLE}."INVOICE_QUANTITY" ;;
    value_format_name: decimal_2
  }

  dimension: matched_quantity {
    type: number
    sql: ${TABLE}."INVOICE_QUANTITY" ;;
    value_format_name: decimal_2
  }

  measure: matched_amount {
    type: sum
    sql: ${TABLE}."INVOICE_QUANTITY" * ${TABLE}."RECEIPT_PRICE" ;;
    value_format_name: usd
  }

  dimension: invoice_price {
    type: number
    sql: ${TABLE}."INVOICE_PRICE" ;;
    value_format_name: usd
  }

  measure: invoice_amount {
    type: sum
    sql: ${TABLE}."INVOICE_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: expense_account_number {
    type: string
    sql: ${TABLE}."EXPENSE_ACCOUNT_NUMBER" ;;
  }

  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}."ENTITY_ID" ;;
  }

  dimension: expense_type {
    type: string
    sql: ${TABLE}."EXPENSE_TYPE" ;;
  }

  measure: variance_amount {
    type: sum
    sql: ${TABLE}."VARIANCE_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: url_var_journal {
    type: string
    sql: ${TABLE}."URL_VAR_JOURNAL" ;;
  }

  dimension: var_journal_number {
    type: string
    sql: ${TABLE}."VAR_JOURNAL_NUMBER" ;;
    html: <a href="{{ url_var_journal._value }}" target="_blank" style="color: blue;">{{ rendered_value }}</a>;;
    suggest_explore: ap_accrual_journal_numbers
    suggest_dimension: journal_number
  }

  measure: var_posted_amount {
    type: sum
    sql: ${TABLE}."VAR_POSTED_AMOUNT" ;;
    value_format_name: usd
  }

  dimension: var_posted_date {
    type: date
    sql: ${TABLE}."VAR_POSTED_DATE" ;;
    convert_tz: no
  }

  dimension: var_amount_match {
    type: yesno
    sql: ${TABLE}."VAR_AMOUNT_MATCH" ;;
  }

  dimension: var_recordno {
    type: string
    label: "Var Journal Unique ID"
    sql: ${TABLE}."VAR_RECORDNO" ;;
  }

  measure: var_percent {
    type: number
    label: "Variance %"
    value_format_name: percent_1
    sql: iff(${invoice_amount} = 0, 0, ${var_posted_amount} / ${invoice_amount}) ;;
  }

  set: detail {
    fields: [
      source,
      entry_date,
      gl_amount,
      journal_title,
      journal_number,
      url_journal,
      receipt_number,
      receipt_date,
      receipt_quantity,
      receipt_price,
      receipt_amount,
      receipt_department_id,
      receipt_entity_id,
      receipt_expense_type,
      accrual_source,
      url_receipt,
      vendor_id,
      vendor_name,
      url_invoice,
      relieved_by,
      vendor_invoice_number,
      invoice_number,
      date_relieved,
      invoice_quantity,
      invoice_price,
      invoice_amount,
      department_id,
      entity_id,
      expense_type,
      variance_amount,
      var_journal_number,
      var_posted_amount,
      var_posted_date,
      var_amount_match,
      url_var_journal
    ]
  }
}
