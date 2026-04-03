view: intacct__gl_subledger_detail_v2 {
  sql_table_name: "ACCRUAL_GOLD"."INTACCT__GL_SUBLEDGER_DETAIL_V2" ;;

  dimension: pk_gl_subledger_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_GL_SUBLEDGER_ID" ;;
  }

  dimension: fk_gl_batch_id {
    type: number
    sql: ${TABLE}."FK_GL_BATCH_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_gl_entry_id {
    type: number
    sql: ${TABLE}."FK_GL_ENTRY_ID" ;;
    value_format_name: id
    group_label: "Foreign Keys"
  }

  dimension: fk_gl_resolve_id {
    type: string
    sql: ${TABLE}."FK_GL_RESOLVE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_posting_header_id {
    type: string
    sql: ${TABLE}."FK_POSTING_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_posting_line_id {
    type: string
    sql: ${TABLE}."FK_POSTING_LINE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_origin_header_id {
    type: string
    sql: ${TABLE}."FK_ORIGIN_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_origin_line_id {
    type: string
    sql: ${TABLE}."FK_ORIGIN_LINE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: posting_document {
    type: string
    sql: ${TABLE}."POSTING_DOCUMENT" ;;
  }

  dimension: type_gl_transaction {
    type: string
    sql: ${TABLE}."TYPE_GL_TRANSACTION" ;;
  }

  dimension: origin_document {
    type: string
    sql: ${TABLE}."ORIGIN_DOCUMENT" ;;
  }

  dimension: state_origin_document {
    type: string
    sql: ${TABLE}."STATE_ORIGIN_DOCUMENT" ;;
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

  dimension: title_batch {
    type: string
    sql: ${TABLE}."TITLE_BATCH" ;;
  }

  dimension: reference_batch {
    type: string
    sql: ${TABLE}."REFERENCE_BATCH" ;;
  }

  dimension_group: date_gl_batch_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_POSTED" ;;
    group_label: "Dates"
  }

  dimension_group: date_gl_batch_reversed_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_REVERSED_FROM" ;;
    group_label: "Dates"
  }

  dimension: state_batch {
    type: string
    sql: ${TABLE}."STATE_BATCH" ;;
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: line_memo {
    type: string
    sql: ${TABLE}."LINE_MEMO" ;;
  }

  dimension: entry_context {
    type: string
    sql: ${TABLE}."ENTRY_CONTEXT" ;;
  }

  dimension: type_transaction {
    type: number
    sql: ${TABLE}."TYPE_TRANSACTION" ;;
  }

  dimension: amount_gl_entry {
    type: number
    sql: ${TABLE}."AMOUNT_GL_ENTRY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_signed_gl_entry {
    type: number
    sql: ${TABLE}."AMOUNT_SIGNED_GL_ENTRY" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_transaction {
    type: number
    sql: ${TABLE}."AMOUNT_TRANSACTION" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_signed_transaction {
    type: number
    sql: ${TABLE}."AMOUNT_SIGNED_TRANSACTION" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }

  dimension: name_account {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT" ;;
  }

  dimension: number_account_ultimate {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT_ULTIMATE" ;;
  }

  dimension: name_account_ultimate {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT_ULTIMATE" ;;
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

  dimension: name_gl_batch_creator {
    type: string
    sql: ${TABLE}."NAME_GL_BATCH_CREATOR" ;;
  }

  dimension: name_gl_batch_modifier {
    type: string
    sql: ${TABLE}."NAME_GL_BATCH_MODIFIER" ;;
  }

  dimension: url_gl_batch {
    type: string
    sql: ${TABLE}."URL_GL_BATCH" ;;
    link: {
      label: "URL Gl Batch"
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

  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
    link: {
      label: "URL T3"
      url: "{{ value }}"
    }
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_dds_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DDS_LOADED" ;;
    group_label: "Timestamps"
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
    group_label: "Timestamps"
  }

  set: detail {
    fields: [
      posting_document,
      type_gl_transaction,
      origin_document,
      state_origin_document,
      journal,
      module,
      number_batch,
      title_batch,
      reference_batch,
      date_gl_batch_posted_date,
      date_gl_batch_reversed_from_date,
      state_batch,
      line_number,
      description,
      line_memo,
      entry_context,
      type_transaction,
      amount_gl_entry,
      amount_signed_gl_entry,
      amount_transaction,
      amount_signed_transaction,
      number_account,
      name_account,
      number_account_ultimate,
      name_account_ultimate,
      id_location,
      id_department,
      name_department,
      id_vendor,
      name_vendor,
      id_expense_line,
      name_expense_line,
      id_item,
      name_item,
      name_gl_batch_creator,
      name_gl_batch_modifier,
      url_gl_batch,
      url_posting_document,
      url_origin_document,
      url_vic_po,
      url_vic_invoice,
      url_t3,
      timestamp_created_date,
      timestamp_modified_date,
      timestamp_dds_loaded_date,
      timestamp_loaded_date,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_transaction {
    type: sum
    sql: ${TABLE}."AMOUNT_TRANSACTION" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_signed_transaction {
    type: sum
    sql: ${TABLE}."AMOUNT_SIGNED_TRANSACTION" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
