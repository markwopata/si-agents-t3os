view: intacct__gl_subledger_detail {
  sql_table_name: "ACCRUAL_GOLD"."INTACCT__GL_SUBLEDGER_DETAIL" ;;

  dimension: fk_gl_batch_id {
    type: number
    sql: ${TABLE}."FK_GL_BATCH_ID" ;;
    value_format_name: id
  }

  dimension: fk_gl_entry_id {
    type: number
    sql: ${TABLE}."FK_GL_ENTRY_ID" ;;
    value_format_name: id
  }

  dimension: fk_gl_resolve_id {
    type: string
    sql: ${TABLE}."FK_GL_RESOLVE_ID" ;;
  }

  dimension: fk_posting_header_id {
    type: string
    sql: ${TABLE}."FK_POSTING_HEADER_ID" ;;
  }

  dimension: fk_posting_line_id {
    type: string
    sql: ${TABLE}."FK_POSTING_LINE_ID" ;;
  }

  dimension: fk_origin_header_id {
    type: string
    sql: ${TABLE}."FK_ORIGIN_HEADER_ID" ;;
  }

  dimension: fk_origin_line_id {
    type: string
    sql: ${TABLE}."FK_ORIGIN_LINE_ID" ;;
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: module {
    type: string
    sql: ${TABLE}."MODULE" ;;
  }

  dimension: number_batch {
    type: number
    sql: ${TABLE}."NUMBER_BATCH" ;;
    value_format_name: id
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: title_batch {
    type: string
    sql: ${TABLE}."TITLE_BATCH" ;;
  }

  dimension_group: date_gl_batch_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_POSTED" ;;
  }

  dimension: name_gl_batch_creator {
    type: string
    sql: ${TABLE}."NAME_GL_BATCH_CREATOR" ;;
  }

  dimension: name_gl_batch_modifier {
    type: string
    sql: ${TABLE}."NAME_GL_BATCH_MODIFIER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: entry_context {
    type: string
    sql: ${TABLE}."ENTRY_CONTEXT" ;;
  }

  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }

  dimension: id_department {
    type: string
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }

  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }

  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }

  dimension: name_account {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT" ;;
  }

  dimension: type_transaction {
    type: number
    sql: ${TABLE}."TYPE_TRANSACTION" ;;
  }

  dimension: amount_gl {
    type: number
    sql: ${TABLE}."AMOUNT_GL" ;;
    value_format_name: usd
  }

  dimension: amount_signed {
    type: number
    sql: ${TABLE}."AMOUNT_SIGNED" ;;
    value_format_name: usd
  }

  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
  }

  dimension: amount_trx_signed {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_SIGNED" ;;
    value_format_name: usd
  }

  dimension: state_batch {
    type: string
    sql: ${TABLE}."STATE_BATCH" ;;
  }

  dimension_group: date_gl_batch_reversed_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_REVERSED_FROM" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: id_expense_line {
    type: string
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
  }

  dimension: name_expense_line {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE" ;;
  }

  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }

  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }

  dimension: number_account_ultimate {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT_ULTIMATE" ;;
  }

  dimension: name_account_ultimate {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT_ULTIMATE" ;;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."LINE_MEMO" ;;
  }

  dimension: type_gl_transaction {
    type: string
    sql: ${TABLE}."TYPE_GL_TRANSACTION" ;;
  }

  dimension: posting_document {
    type: string
    sql: ${TABLE}."POSTING_DOCUMENT" ;;
  }

  dimension: origin_document {
    type: string
    sql: ${TABLE}."ORIGIN_DOCUMENT" ;;
  }

  dimension: state_origin_document {
    type: string
    sql: ${TABLE}."STATE_ORIGIN_DOCUMENT" ;;
  }

  dimension: url_gl_batch {
    type: string
    sql: ${TABLE}."URL_GL_BATCH" ;;
    link: {
      label: "URL Gl Batch"
      url: "{{ value }}"
    }
  }

  dimension: url_vic_po {
    type: string
    sql: ${TABLE}."URL_VIC_PO" ;;
    link: {
      label: "URL Vic Po"
      url: "{{ value }}"
    }
  }

  dimension: url_vic_invoice {
    type: string
    sql: ${TABLE}."URL_VIC_INVOICE" ;;
    link: {
      label: "URL Vic Invoice"
      url: "{{ value }}"
    }
  }

  dimension: url_posting_document {
    type: string
    sql: ${TABLE}."URL_POSTING_DOCUMENT" ;;
    link: {
      label: "URL Posting Document"
      url: "{{ value }}"
    }
  }

  dimension: url_origin_document {
    type: string
    sql: ${TABLE}."URL_ORIGIN_DOCUMENT" ;;
    link: {
      label: "URL Origin Document"
      url: "{{ value }}"
    }
  }

  set: detail {
    fields: [
      fk_gl_batch_id,
      fk_gl_entry_id,
      fk_gl_resolve_id,
      fk_posting_header_id,
      fk_posting_line_id,
      fk_origin_header_id,
      fk_origin_line_id,
      journal,
      module,
      number_batch,
      line_number,
      title_batch,
      date_gl_batch_posted_date,
      name_gl_batch_creator,
      name_gl_batch_modifier,
      description,
      entry_context,
      id_location,
      id_department,
      name_department,
      number_account,
      name_account,
      type_transaction,
      amount_gl,
      amount_signed,
      amount_trx,
      amount_trx_signed,
      state_batch,
      date_gl_batch_reversed_from_date,
      id_vendor,
      name_vendor,
      id_expense_line,
      name_expense_line,
      id_item,
      name_item,
      number_account_ultimate,
      name_account_ultimate,
      line_memo,
      type_gl_transaction,
      posting_document,
      origin_document,
      state_origin_document,
      url_gl_batch,
      url_vic_po,
      url_vic_invoice,
      url_posting_document,
      url_origin_document,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_gl {
    type: sum
    sql: ${TABLE}."AMOUNT_GL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_signed {
    type: sum
    sql: ${TABLE}."AMOUNT_SIGNED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_signed {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_SIGNED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
