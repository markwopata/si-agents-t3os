view: gl_linked_po_lines {
  derived_table: {
    sql: SELECT *
    FROM ANALYTICS.FINANCIAL_SYSTEMS.PO_GL_DETAIL
    ;;
  }

  dimension: vendor_id {
    type:  string
    sql:  ${TABLE}."VENDOR_ID" ;;
  }

  dimension: po_number {
    type:  string
    sql:  ${TABLE}."PO_NUMBER" ;;
  }

  dimension: document_number {
    type:  string
    sql:  ${TABLE}."DOCUMENT_NUMBER" ;;
  }

  dimension: document_type {
    type:  string
    sql:  ${TABLE}."DOCUMENT_TYPE" ;;
  }

  dimension: document_name {
    type:  string
    sql:  ${TABLE}."DOCUMENT_NAME" ;;
  }

  dimension: doc_line_number {
    type:  string
    sql:  ${TABLE}."line_number" ;;
  }

  dimension: doc_line_posting_acct {
    type:  string
    sql:  ${TABLE}."LINE_POSTING_ACCOUNT" ;;
  }

  dimension: doc_line_offset_acct {
    type:  string
    sql:  ${TABLE}."LINE_OFFSET_ACCOUNT" ;;
  }

  dimension: item_id {
    type:  string
    sql:  ${TABLE}."ITEM_ID" ;;
  }

  dimension: item_description {
    type:  string
    sql:  ${TABLE}."ITEM_DESCRIPTION" ;;
  }

  dimension: unit_price {
    type:  number
    sql:  ${TABLE}."UNIT_PRICE" ;;
  }

  dimension: quantity {
    type:  number
    sql:  ${TABLE}."QUANTITY" ;;
  }

  dimension: line_amount {
    type:  number
    sql:  ${TABLE}."LINE_AMOUNT" ;;
  }

  dimension: quantity_converted {
    type:  number
    sql:  ${TABLE}."QUANTITY_CONVERTED" ;;
  }

  dimension: quantity_remaining {
    type:  number
    sql:  ${TABLE}."QUANTITY_REMAINING" ;;
  }

  dimension: reference {
    type:  string
    sql:  ${TABLE}."REFERENCE" ;;
  }

  dimension: invoice_number {
    type:  string
    sql:  ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: po_posting_date {
    type:  date
    sql:  ${TABLE}."GL_DATE" ;;
  }

  dimension: receipt_number {
    type:  string
    sql:  ${TABLE}."RECEIPT_NUMBER" ;;
  }

  dimension: po_state {
    type:  string
    sql:  ${TABLE}."PO_STATE" ;;
  }

  dimension: sage_created_by_name {
    type:  string
    sql:  ${TABLE}."SAGE_PO_CREATED_BY_NAME" ;;
  }

  dimension: t3_created_by_user_id {
    type:  string
    sql:  ${TABLE}."FK_T3_PO_CREATED_BY_USER_ID" ;;
  }

  dimension: t3_created_by_name {
    type:  string
    sql:  ${TABLE}."T3_PO_CREATED_BY_NAME" ;;
  }

  dimension: url_sage {
    type:  string
    sql:  ${TABLE}."URL_SAGE" ;;
  }

  dimension: url_t3 {
    type:  string
    sql:  ${TABLE}."URL_T3" ;;
  }

  dimension: url_concur {
    type:  string
    sql:  ${TABLE}."URL_CONCUR" ;;
  }

  dimension: po_qty_remaining {
    type:  number
    sql:  ${TABLE}."PO_TOTAL_QTY_REMAINING" ;;
  }

  dimension: days_ago {
    type:  number
    sql:  ${TABLE}."DAYS_AGO" ;;
  }

  dimension: link_to_intacct_record {
    type: string
    sql: ${TABLE}."DOCUMENT_NAME" ;;
    html: <a href="{{ url_sage._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a>;;}

  dimension: link_to_t3 {
    type: string
    sql: ${TABLE}."DOCUMENT_NAME" ;;
    html: <a href="{{ url_t3._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a>;;}

  dimension: link_to_concur_inv {
    type: string
    sql: ${TABLE}."DOCUMENT_NAME" ;;
    html: <a href="{{ url_concur._rendered_value }}" target="_blank" style="color: blue;">{{value}}</a>;;}



  dimension: gl_entry_date {
    type:  date
    sql:  ${TABLE}."ENTRY_DATE" ;;
  }

  dimension: gl_account_number {
    type:  string
    sql:  ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: gl_department_id {
    type:  string
    sql:  ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: gl_department_name {
    type:  string
    sql:  ${TABLE}."DEPARTMENT_NAME" ;;
  }

  dimension: gl_entity_id {
    type:  string
    sql:  ${TABLE}."DEPARTMENT_NAME" ;;
  }

  dimension: debit_credit {
    type:  string
    sql:  ${TABLE}."DEBIT_CREDIT" ;;
  }

  dimension: net_line_amount {
    type:  number
    sql:  ${TABLE}."NET_AMOUNT" ;;
  }

  dimension: net_entry_amount {
    type:  number
    sql:  ${TABLE}."NET_ENTRY_AMOUNT" ;;

  }

  dimension: expense_type_id {
    type:  string
    sql:  ${TABLE}."EXPENSE_TYPE" ;;
  }

  dimension: expense_type_category {
    type:  string
    sql:  ${TABLE}."EXPENSE_CATEGORY" ;;
  }

  dimension: journal {
    type:  string
    sql:  ${TABLE}."JOURNAL_TYPE" ;;
  }

  dimension: created_by_user_id {
    type:  string
    sql:  ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }

  dimension: created_by_username {
    type:  string
    sql:  ${TABLE}."CREATED_BY_USERNAME" ;;
  }

  dimension: updated_by_user_id {
    type:  string
    sql:  ${TABLE}."FK_UPDATED_BY_USER_ID" ;;
  }

  dimension: updated_by_username {
    type:  string
    sql:  ${TABLE}."UPDATED_BY_USERNAME" ;;
  }

  dimension: gl_entry_state {
    type:  string
    sql:  ${TABLE}."ENTRY_STATE" ;;
  }

  dimension: gl_date_created {
    type:  date
    sql:  ${TABLE}."DATE_CREATED" ;;
  }

  dimension: gl_date_updated {
    type:  date
    sql:  ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: po_line_vs_gl_posted_amount {
    type:  number
    sql:  ${TABLE}."LINE_VS_GLPOSTED" ;;

  }

  dimension: po_net_2014 {
    type:  number
    sql:  ${TABLE}."NET_PO_2014" ;;

  }

}
