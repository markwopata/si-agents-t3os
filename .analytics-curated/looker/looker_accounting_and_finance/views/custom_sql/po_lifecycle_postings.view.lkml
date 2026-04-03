view: po_lifecycle_postings {
  derived_table: {
    sql: SELECT * FROM ANALYTICS.FINANCIAL_SYSTEMS.PO_GL_DETAIL
    ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.VENDOR_ID ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}.PO_NUMBER ;;
    }

  dimension: document_number {
    type: string
    sql: ${TABLE}.DOCUMENT_NUMBER ;;
  }

  dimension: document_type {
    type: string
    sql: ${TABLE}.DOCUMENT_TYPE ;;
  }

  dimension: document_name {
    type: string
    sql: ${TABLE}.DOCUMENT_NAME ;;
  }

  dimension: fk_subledger_header_id {
    type: string
    sql: ${TABLE}.FK_SUBLEDGER_HEADER_ID ;;
  }

  dimension: fk_subledger_line_id {
    type: string
    sql: ${TABLE}.FK_SUBLEDGER_LINE_ID ;;
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}.LINE_NUMBER ;;
  }

  dimension: line_posting_account {
    type: string
    sql: ${TABLE}.LINE_POSTING_ACCOUNT ;;
  }

  dimension: line_offset_account {
    type: string
    sql: ${TABLE}.LINE_OFFSET_ACCOUNT ;;
  }

  dimension: item_id {
    type: string
    sql: ${TABLE}.ITEM_ID ;;
  }

  dimension: item_description {
    type: string
    sql: ${TABLE}.ITEM_DESCRIPTION ;;
  }

  dimension: unit_price {
    type: number
    sql: ${TABLE}.UNIT_PRICE ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.QUANTITY ;;
  }

  dimension: line_amount {
    type: number
    sql: ${TABLE}.LINE_AMOUNT ;;
  }

  dimension: quantity_converted {
    type: number
    sql: ${TABLE}.QUANTITY_CONVERTED ;;
  }

  dimension: quantity_remaining {
    type: number
    sql: ${TABLE}.QUANTITY_REMAINING ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}.REFERENCE ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}.INVOICE_NUMBER ;;
  }

  dimension_group: gl_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.GL_DATE ;;
  }

  dimension: receipt_number {
    type: string
    sql: ${TABLE}.RECEIPT_NUMBER ;;
  }

  dimension: po_state {
    type: string
    sql: ${TABLE}.PO_STATE ;;
  }

  dimension: sage_created_by_name {
    type: string
    sql: ${TABLE}.SAGE_PO_CREATED_BY_NAME ;;
  }

  dimension: fk_t3_created_by_id {
    type: number
    sql: ${TABLE}.FK_T3_CREATED_BY_ID ;;
  }

  dimension: t3_created_by_name {
    type: string
    sql: ${TABLE}.T3_CREATED_BY_NAME ;;
  }

  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}.FK_SOURCE_PO_LINE_ID ;;
  }

  dimension: url_sage {
    type: string
    sql: ${TABLE}.URL_SAGE ;;
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}.URL_T3 ;;
  }

  dimension: url_concur {
    type: string
    sql: ${TABLE}.URL_CONCUR ;;
  }

  dimension: link_to_sage {
    type: string
    sql: ${TABLE}.URL_SAGE ;;
    html: <a href="{{ url_sage._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a>;;}

  dimension: link_to_t3 {
    type: string
    sql: ${TABLE}.URL_T3 ;;
    html: <a href="{{ url_t3._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a>;;}

  dimension: link_to_concur {
    type: string
    sql: ${TABLE}.URL_CONCUR ;;
    html: <a href="{{ url_concur._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a>;;}

  dimension: po_total_qty_remaining {
    type: number
    sql: ${TABLE}.PO_TOTAL_QTY_REMAINING ;;
  }

  dimension: num_days_ago_created {
    type: number
    sql: ${TABLE}.DAYS_AGO ;;
  }

  dimension: fk_gl_entry_id {
    type: string
    sql: ${TABLE}.FK_GL_ENTRY_ID ;;
  }

  dimension_group: gl_entry_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.ENTRY_DATE ;;
  }

  dimension: gl_account_number {
    type: string
    sql: ${TABLE}.ACCOUNT_NUMBER ;;
  }

  dimension: gl_account_normal_balance {
    type: string
    sql: ${TABLE}.ACCOUNT_NORMAL_BALANCE ;;
  }

  dimension: department_id {
    type: string
    sql: ${TABLE}.DEPARTMENT_ID ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}.DEPARTMENT_NAME ;;
  }

  dimension: entity_id {
    type: string
    sql: ${TABLE}.ENTITY_ID ;;
  }

  dimension: gl_raw_amount {
    type: number
    sql: ${TABLE}.RAW_AMOUNT ;;
  }

  dimension: debit_credit {
    type: string
    sql: ${TABLE}.DEBIT_CREDIT ;;
  }

  dimension: gl_net_amount {
    type: number
    sql: ${TABLE}.NET_AMOUNT ;;
  }

  dimension: gl_net_entry_amount {
    type: number
    sql: ${TABLE}.NET_ENTRY_AMOUNT ;;
  }

  dimension_group: exchange_rate_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.EXCHANGE_RATE_DATE ;;
  }

  dimension: exchange_rate {
    type: number
    sql: ${TABLE}.EXCHANGE_RATE ;;
  }

  dimension: fk_expense_type_id {
    type: number
    sql: ${TABLE}.FK_EXPENSE_TYPE_ID ;;
  }

  dimension: expense_type {
    type: string
    sql: ${TABLE}.EXPENSE_TYPE ;;
  }

  dimension: expense_category {
    type: string
    sql: ${TABLE}.EXPENSE_CATEGORY ;;
  }

  dimension: intacct_module {
    type: string
    sql: ${TABLE}.INTACCT_MODULE ;;
  }

  dimension: journal_type {
    type: string
    sql: ${TABLE}.JOURNAL_TYPE ;;
  }

  dimension_group: date_reversed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_REVERSED ;;
  }

  dimension: fk_journal_id {
    type: number
    sql: ${TABLE}.FK_JOURNAL_ID ;;
  }

  dimension: journal_transaction_number {
    type: number
    sql: ${TABLE}.JOURNAL_TRANSACTION_NUMBER ;;
  }

  dimension: gl_line_number {
    type: number
    sql: ${TABLE}.GL_LINE_NUMBER ;;
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}.FK_CREATED_BY_USER_ID ;;
  }

  dimension: created_by_username {
    type: string
    sql: ${TABLE}.CREATED_BY_USERNAME ;;
  }

  dimension: fk_updated_by_user_id {
    type: number
    sql: ${TABLE}.FK_UPDATED_BY_USER_ID ;;
  }

  dimension: updated_by_username {
    type: string
    sql: ${TABLE}.UPDATED_BY_USERNAME ;;
  }

  dimension: entry_state {
    type: string
    sql: ${TABLE}.ENTRY_STATE ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_CREATED ;;
  }

  dimension_group: date_updated {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    sql: ${TABLE}.DATE_UPDATED ;;
  }

  dimension: line_vs_gl_posted {
    type: number
    sql: ${TABLE}.LINE_VS_GLPOSTED ;;
  }

  dimension: net_po_2014 {
    type: number
    sql: ${TABLE}.NET_PO_2014 ;;
  }

}
