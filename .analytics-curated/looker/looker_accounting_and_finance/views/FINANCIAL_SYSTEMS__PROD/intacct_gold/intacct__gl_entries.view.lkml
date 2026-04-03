view: intacct__gl_entries {
  sql_table_name: "INTACCT_GOLD"."INTACCT__GL_ENTRIES" ;;

  dimension: pk_gl_entry_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_GL_ENTRY_ID" ;;
    value_format_name: id
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

  dimension: number_batch_reversed {
    type: number
    sql: ${TABLE}."NUMBER_BATCH_REVERSED" ;;
    value_format_name: id
  }

  dimension: title_batch_reversed {
    type: string
    sql: ${TABLE}."TITLE_BATCH_REVERSED" ;;
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
    value_format_name: id
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

  dimension: amount_gl {
    type: number
    sql: ${TABLE}."AMOUNT_GL" ;;
    value_format_name: usd
  }

  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
  }

  dimension: type_transaction {
    type: number
    sql: ${TABLE}."TYPE_TRANSACTION" ;;
  }

  dimension: amount_signed {
    type: number
    sql: ${TABLE}."AMOUNT_SIGNED" ;;
    value_format_name: usd
  }

  dimension: amount_trx_signed {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_SIGNED" ;;
    value_format_name: usd
  }

  dimension: ppu_receipt {
    type: number
    sql: ${TABLE}."PPU_RECEIPT" ;;
  }

  dimension: qty_receipt {
    type: number
    sql: ${TABLE}."QTY_RECEIPT" ;;
  }

  dimension: memo_loan {
    type: string
    sql: ${TABLE}."MEMO_LOAN" ;;
  }

  dimension: number_ud_esadmin_invoice {
    type: string
    sql: ${TABLE}."NUMBER_UD_ESADMIN_INVOICE" ;;
  }

  dimension: number_ud_estrack_work_order {
    type: string
    sql: ${TABLE}."NUMBER_UD_ESTRACK_WORK_ORDER" ;;
  }

  dimension: id_time_period {
    type: number
    sql: ${TABLE}."ID_TIME_PERIOD" ;;
  }

  dimension: entry_context {
    type: string
    sql: ${TABLE}."ENTRY_CONTEXT" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: bill_number {
    type: string
    sql: ${TABLE}."BILL_NUMBER" ;;
  }

  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }

  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }

  dimension: id_department {
    type: string
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }

  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }

  dimension: id_document {
    type: string
    sql: ${TABLE}."ID_DOCUMENT" ;;
  }

  dimension: id_class {
    type: string
    sql: ${TABLE}."ID_CLASS" ;;
  }

  dimension: id_customer {
    type: string
    sql: ${TABLE}."ID_CUSTOMER" ;;
  }

  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }

  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }

  dimension: id_employee {
    type: string
    sql: ${TABLE}."ID_EMPLOYEE" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: id_asset {
    type: string
    sql: ${TABLE}."ID_ASSET" ;;
  }

  dimension: gldim_asset {
    type: string
    sql: ${TABLE}."GLDIM_ASSET" ;;
  }

  dimension: id_expense_line {
    type: string
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
  }

  dimension: name_expense_line {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE" ;;
  }

  dimension: gldim_transaction_identifier {
    type: string
    sql: ${TABLE}."GLDIM_TRANSACTION_IDENTIFIER" ;;
  }

  dimension: gldim_ud_loan {
    type: string
    sql: ${TABLE}."GLDIM_UD_LOAN" ;;
  }

  dimension: number_serial {
    type: string
    sql: ${TABLE}."NUMBER_SERIAL" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: state_entry {
    type: string
    sql: ${TABLE}."STATE_ENTRY" ;;
  }

  dimension: status_cleared {
    type: string
    sql: ${TABLE}."STATUS_CLEARED" ;;
  }

  dimension: state_batch {
    type: string
    sql: ${TABLE}."STATE_BATCH" ;;
  }

  dimension_group: date_gl_batch_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_POSTED" ;;
  }

  dimension_group: date_gl_batch_reversed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_REVERSED" ;;
  }

  dimension_group: date_gl_batch_reversed_from {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL_BATCH_REVERSED_FROM" ;;
  }

  dimension_group: date_entry {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ENTRY" ;;
  }

  dimension_group: date_cleared {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CLEARED" ;;
  }

  dimension_group: date_reconciled {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECONCILED" ;;
  }

  dimension: flag_adjustment {
    type: string
    sql: ${TABLE}."FLAG_ADJUSTMENT" ;;
  }

  dimension: flag_statistical {
    type: string
    sql: ${TABLE}."FLAG_STATISTICAL" ;;
  }

  dimension: name_gl_batch_creator {
    type: string
    sql: ${TABLE}."NAME_GL_BATCH_CREATOR" ;;
  }

  dimension: name_gl_batch_modifier {
    type: string
    sql: ${TABLE}."NAME_GL_BATCH_MODIFIER" ;;
  }

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: name_modified_by_user {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY_USER" ;;
  }

  dimension: fk_apa_true_up_invoice_line_id {
    type: string
    sql: ${TABLE}."FK_APA_TRUE_UP_INVOICE_LINE_ID" ;;
  }

  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_created_by_user_id_alt {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID_ALT" ;;
  }

  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
    value_format_name: id
  }

  dimension: fk_gl_batch_id {
    type: number
    sql: ${TABLE}."FK_GL_BATCH_ID" ;;
    value_format_name: id
  }

  dimension: fk_gl_batch_reversed_id {
    type: number
    sql: ${TABLE}."FK_GL_BATCH_REVERSED_ID" ;;
    value_format_name: id
  }

  dimension: fk_location_id {
    type: number
    sql: ${TABLE}."FK_LOCATION_ID" ;;
    value_format_name: id
  }

  dimension: fk_department_id {
    type: number
    sql: ${TABLE}."FK_DEPARTMENT_ID" ;;
    value_format_name: id
  }

  dimension: fk_gl_account_id {
    type: number
    sql: ${TABLE}."FK_GL_ACCOUNT_ID" ;;
    value_format_name: id
  }

  dimension: fk_allocation_id {
    type: number
    sql: ${TABLE}."FK_ALLOCATION_ID" ;;
    value_format_name: id
  }

  dimension: fk_class_dimension_id {
    type: number
    sql: ${TABLE}."FK_CLASS_DIMENSION_ID" ;;
    value_format_name: id
  }

  dimension: fk_customer_dimension_id {
    type: number
    sql: ${TABLE}."FK_CUSTOMER_DIMENSION_ID" ;;
    value_format_name: id
  }

  dimension: fk_item_dimension_id {
    type: number
    sql: ${TABLE}."FK_ITEM_DIMENSION_ID" ;;
    value_format_name: id
  }

  dimension: fk_vendor_dimension_id {
    type: number
    sql: ${TABLE}."FK_VENDOR_DIMENSION_ID" ;;
    value_format_name: id
  }

  dimension: fk_employee_dimension_id {
    type: number
    sql: ${TABLE}."FK_EMPLOYEE_DIMENSION_ID" ;;
    value_format_name: id
  }

  dimension: fk_source_receipt_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_RECEIPT_LINE_ID" ;;
  }

  dimension: fk_source_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_RECEIPT_HEADER_ID" ;;
  }

  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
  }

  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
  }

  dimension: url_source_po {
    type: string
    sql: ${TABLE}."URL_SOURCE_PO" ;;
    link: {
      label: "URL Source Po"
      url: "{{ value }}"
    }
  }

  dimension: url_reference {
    type: string
    sql: ${TABLE}."URL_REFERENCE" ;;
    link: {
      label: "URL Reference"
      url: "{{ value }}"
    }
  }

  dimension: url_intacct {
    type: string
    sql: ${TABLE}."URL_INTACCT" ;;
    link: {
      label: "URL Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_intacct_reversed {
    type: string
    sql: ${TABLE}."URL_INTACCT_REVERSED" ;;
    link: {
      label: "URL Intacct Reversed"
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
      pk_gl_entry_id,
      journal,
      module,
      number_batch,
      title_batch,
      reference_batch,
      number_batch_reversed,
      title_batch_reversed,
      line_number,
      number_account,
      name_account,
      number_account_ultimate,
      name_account_ultimate,
      amount_gl,
      amount_trx,
      type_transaction,
      amount_signed,
      amount_trx_signed,
      ppu_receipt,
      qty_receipt,
      memo_loan,
      number_ud_esadmin_invoice,
      number_ud_estrack_work_order,
      id_time_period,
      entry_context,
      po_number,
      bill_number,
      id_location,
      name_location,
      id_department,
      name_department,
      id_document,
      id_class,
      id_customer,
      id_item,
      name_item,
      id_employee,
      id_vendor,
      name_vendor,
      id_asset,
      gldim_asset,
      id_expense_line,
      name_expense_line,
      gldim_transaction_identifier,
      gldim_ud_loan,
      number_serial,
      description,
      state_entry,
      status_cleared,
      state_batch,
      date_gl_batch_posted_date,
      date_gl_batch_reversed_date,
      date_gl_batch_reversed_from_date,
      date_entry_date,
      date_cleared_date,
      date_reconciled_date,
      flag_adjustment,
      flag_statistical,
      name_gl_batch_creator,
      name_gl_batch_modifier,
      name_created_by_user,
      name_modified_by_user,
      fk_apa_true_up_invoice_line_id,
      fk_created_by_user_id,
      fk_created_by_user_id_alt,
      fk_modified_by_user_id,
      fk_gl_batch_id,
      fk_gl_batch_reversed_id,
      fk_location_id,
      fk_department_id,
      fk_gl_account_id,
      fk_allocation_id,
      fk_class_dimension_id,
      fk_customer_dimension_id,
      fk_item_dimension_id,
      fk_vendor_dimension_id,
      fk_employee_dimension_id,
      fk_source_receipt_line_id,
      fk_source_receipt_header_id,
      fk_source_po_line_id,
      fk_source_po_header_id,
      url_source_po,
      url_reference,
      url_intacct,
      url_intacct_reversed,
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

  measure: total_amount_gl {
    type: sum
    sql: ${TABLE}."AMOUNT_GL" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_signed {
    type: sum
    sql: ${TABLE}."AMOUNT_SIGNED" ;;
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
