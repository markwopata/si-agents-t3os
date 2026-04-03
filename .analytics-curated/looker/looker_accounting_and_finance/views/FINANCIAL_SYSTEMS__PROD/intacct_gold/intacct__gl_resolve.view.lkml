view: intacct__gl_resolve {
  sql_table_name: "INTACCT_GOLD"."INTACCT__GL_RESOLVE" ;;

  dimension: pk_gl_resolve_id {
    type: string
    primary_key: yes
    sql: ${TABLE}."PK_GL_RESOLVE_ID" ;;
  }

  dimension: journal {
    type: string
    sql: ${TABLE}."JOURNAL" ;;
  }

  dimension: module {
    type: string
    sql: ${TABLE}."MODULE" ;;
  }

  dimension_group: date_batch {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_BATCH" ;;
  }

  dimension_group: date_reversed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_REVERSED" ;;
  }

  dimension_group: date_reversed_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_REVERSED_FROM" ;;
  }

  dimension: amount_resolve {
    type: number
    sql: ${TABLE}."AMOUNT_RESOLVE" ;;
    value_format_name: usd
  }

  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
  }

  dimension: amount_resolve_signed {
    type: number
    sql: ${TABLE}."AMOUNT_RESOLVE_SIGNED" ;;
    value_format_name: usd
  }

  dimension: amount_trx_signed {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_SIGNED" ;;
    value_format_name: usd
  }

  dimension: gle_amount_gl {
    type: number
    sql: ${TABLE}."GLE_AMOUNT_GL" ;;
  }

  dimension: gle_amount_signed {
    type: number
    sql: ${TABLE}."GLE_AMOUNT_SIGNED" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: type_document {
    type: string
    sql: ${TABLE}."TYPE_DOCUMENT" ;;
  }

  dimension: state_record {
    type: string
    sql: ${TABLE}."STATE_RECORD" ;;
  }

  dimension: name_posting_document {
    type: string
    sql: ${TABLE}."NAME_POSTING_DOCUMENT" ;;
  }

  dimension: num_posting_document {
    type: string
    sql: ${TABLE}."NUM_POSTING_DOCUMENT" ;;
  }

  dimension: name_doc_created_from {
    type: string
    sql: ${TABLE}."NAME_DOC_CREATED_FROM" ;;
  }

  dimension: num_source_document {
    type: string
    sql: ${TABLE}."NUM_SOURCE_DOCUMENT" ;;
  }

  dimension: num_ultimate_source_document {
    type: string
    sql: ${TABLE}."NUM_ULTIMATE_SOURCE_DOCUMENT" ;;
  }

  dimension: state_source_document {
    type: string
    sql: ${TABLE}."STATE_SOURCE_DOCUMENT" ;;
  }

  dimension: name_t3_po_created_by {
    type: string
    sql: ${TABLE}."NAME_T3_PO_CREATED_BY" ;;
  }

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: line_number_posting_document {
    type: number
    sql: ${TABLE}."LINE_NUMBER_POSTING_DOCUMENT" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }

  dimension: type_item {
    type: string
    sql: ${TABLE}."TYPE_ITEM" ;;
  }

  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
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

  dimension: line_number_gl_entry {
    type: number
    sql: ${TABLE}."LINE_NUMBER_GL_ENTRY" ;;
  }

  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }

  dimension: name_account {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT" ;;
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

  dimension: id_expense_line {
    type: string
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
  }

  dimension: name_expense_line {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE" ;;
  }

  dimension: name_created_by {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY" ;;
  }

  dimension: name_modified_by {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY" ;;
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_gl_entry_id {
    type: number
    sql: ${TABLE}."FK_GL_ENTRY_ID" ;;
    value_format_name: id
  }

  dimension: fk_pr_record_id {
    type: number
    sql: ${TABLE}."FK_PR_RECORD_ID" ;;
    value_format_name: id
  }

  dimension: fk_pr_entry_id {
    type: number
    sql: ${TABLE}."FK_PR_ENTRY_ID" ;;
    value_format_name: id
  }

  dimension: fk_doc_header_id {
    type: number
    sql: ${TABLE}."FK_DOC_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_doc_entry_id {
    type: number
    sql: ${TABLE}."FK_DOC_ENTRY_ID" ;;
    value_format_name: id
  }

  dimension: fk_posting_doc_id {
    type: number
    sql: ${TABLE}."FK_POSTING_DOC_ID" ;;
    value_format_name: id
  }

  dimension: fk_posting_doc_line_id {
    type: number
    sql: ${TABLE}."FK_POSTING_DOC_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_source_doc_id {
    type: number
    sql: ${TABLE}."FK_SOURCE_DOC_ID" ;;
    value_format_name: id
  }

  dimension: fk_source_doc_line_id {
    type: number
    sql: ${TABLE}."FK_SOURCE_DOC_LINE_ID" ;;
    value_format_name: id
  }

  dimension: url_gl_batch {
    type: string
    sql: ${TABLE}."URL_GL_BATCH" ;;
    link: {
      label: "URL Gl Batch"
      url: "{{ value }}"
    }
  }

  dimension: url_posting_doc {
    type: string
    sql: ${TABLE}."URL_POSTING_DOC" ;;
    link: {
      label: "URL Posting Doc"
      url: "{{ value }}"
    }
  }

  dimension: url_source_doc {
    type: string
    sql: ${TABLE}."URL_SOURCE_DOC" ;;
    link: {
      label: "URL Source Doc"
      url: "{{ value }}"
    }
  }

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }

  dimension_group: timestamp_dds_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_DDS_LOADED" ;;
  }

  dimension_group: timestamp_loaded {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_LOADED" ;;
  }

  set: detail {
    fields: [
      pk_gl_resolve_id,
      journal,
      module,
      date_batch_date,
      date_reversed_date,
      date_reversed_from_date,
      amount_resolve,
      amount_trx,
      amount_resolve_signed,
      amount_trx_signed,
      gle_amount_gl,
      gle_amount_signed,
      id_vendor,
      name_vendor,
      type_document,
      state_record,
      name_posting_document,
      num_posting_document,
      name_doc_created_from,
      num_source_document,
      num_ultimate_source_document,
      state_source_document,
      name_t3_po_created_by,
      name_created_by_user,
      line_number_posting_document,
      memo,
      id_item,
      type_item,
      name_item,
      number_batch,
      title_batch,
      line_number_gl_entry,
      number_account,
      name_account,
      id_location,
      id_department,
      name_department,
      id_expense_line,
      name_expense_line,
      name_created_by,
      name_modified_by,
      fk_created_by_user_id,
      fk_modified_by_user_id,
      fk_gl_entry_id,
      fk_pr_record_id,
      fk_pr_entry_id,
      fk_doc_header_id,
      fk_doc_entry_id,
      fk_posting_doc_id,
      fk_posting_doc_line_id,
      fk_source_doc_id,
      fk_source_doc_line_id,
      url_gl_batch,
      url_posting_doc,
      url_source_doc,
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

  measure: total_amount_resolve {
    type: sum
    sql: ${TABLE}."AMOUNT_RESOLVE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_resolve_signed {
    type: sum
    sql: ${TABLE}."AMOUNT_RESOLVE_SIGNED" ;;
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
