view: intacct__ap_lines {
  sql_table_name: "INTACCT_GOLD"."INTACCT__AP_LINES" ;;

  dimension: pk_ap_line_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_AP_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_ap_header_id {
    type: number
    sql: ${TABLE}."FK_AP_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: id_record {
    type: string
    sql: ${TABLE}."ID_RECORD" ;;
  }

  dimension: num_po_document {
    type: string
    sql: ${TABLE}."NUM_PO_DOCUMENT" ;;
  }

  dimension: num_vi_document {
    type: string
    sql: ${TABLE}."NUM_VI_DOCUMENT" ;;
  }

  dimension_group: date_entry {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ENTRY" ;;
  }

  dimension: type_record {
    type: string
    sql: ${TABLE}."TYPE_RECORD" ;;
  }

  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
    value_format_name: id
  }

  dimension: description_entry {
    type: string
    sql: ${TABLE}."DESCRIPTION_ENTRY" ;;
  }

  dimension: flag_line_item {
    type: string
    sql: ${TABLE}."FLAG_LINE_ITEM" ;;
  }

  dimension: amount_line {
    type: number
    sql: ${TABLE}."AMOUNT_LINE" ;;
    value_format_name: usd
  }

  dimension: amount_retained {
    type: number
    sql: ${TABLE}."AMOUNT_RETAINED" ;;
    value_format_name: usd
  }

  dimension: amount_subtotal {
    type: string
    sql: ${TABLE}."AMOUNT_SUBTOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_total_paid {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_PAID" ;;
    value_format_name: usd
  }

  dimension: amount_total_selected {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL_SELECTED" ;;
    value_format_name: usd
  }

  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
  }

  dimension: amount_trx_released {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_RELEASED" ;;
    value_format_name: usd
  }

  dimension: amount_trx_retained {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_RETAINED" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total_paid {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_PAID" ;;
    value_format_name: usd
  }

  dimension: amount_trx_total_selected {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_SELECTED" ;;
    value_format_name: usd
  }

  dimension: percentage_retainage {
    type: number
    sql: ${TABLE}."PERCENTAGE_RETAINAGE" ;;
  }

  dimension: number_serial {
    type: string
    sql: ${TABLE}."NUMBER_SERIAL" ;;
  }

  dimension: number_order {
    type: string
    sql: ${TABLE}."NUMBER_ORDER" ;;
  }

  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }

  dimension: name_item {
    type: string
    sql: ${TABLE}."NAME_ITEM" ;;
  }

  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }

  dimension: title_account {
    type: string
    sql: ${TABLE}."TITLE_ACCOUNT" ;;
  }

  dimension: number_offset_gl_account {
    type: string
    sql: ${TABLE}."NUMBER_OFFSET_GL_ACCOUNT" ;;
  }

  dimension: title_offset_gl_account {
    type: string
    sql: ${TABLE}."TITLE_OFFSET_GL_ACCOUNT" ;;
  }

  dimension: number_pr_entry_offset_account {
    type: string
    sql: ${TABLE}."NUMBER_PR_ENTRY_OFFSET_ACCOUNT" ;;
  }

  dimension: number_account_ultimate {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT_ULTIMATE" ;;
  }

  dimension: name_account_ultimate {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT_ULTIMATE" ;;
  }

  dimension: number_ud_esadmin_invoice {
    type: string
    sql: ${TABLE}."NUMBER_UD_ESADMIN_INVOICE" ;;
  }

  dimension: number_ud_estrack_work_order {
    type: string
    sql: ${TABLE}."NUMBER_UD_ESTRACK_WORK_ORDER" ;;
  }

  dimension: version_vendor_account_no_key {
    type: number
    sql: ${TABLE}."VERSION_VENDOR_ACCOUNT_NO_KEY" ;;
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

  dimension: category_expense {
    type: string
    sql: ${TABLE}."CATEGORY_EXPENSE" ;;
  }

  dimension: gldim_transaction_identifier {
    type: string
    sql: ${TABLE}."GLDIM_TRANSACTION_IDENTIFIER" ;;
  }

  dimension: gldim_ud_loan {
    type: string
    sql: ${TABLE}."GLDIM_UD_LOAN" ;;
  }

  dimension: offset_gl {
    type: number
    sql: ${TABLE}."OFFSET_GL" ;;
  }

  dimension: box_form_1099 {
    type: string
    sql: ${TABLE}."BOX_FORM_1099" ;;
  }

  dimension: type_form_1099 {
    type: string
    sql: ${TABLE}."TYPE_FORM_1099" ;;
  }

  dimension: state_record {
    type: string
    sql: ${TABLE}."STATE_RECORD" ;;
  }

  dimension: id_class {
    type: string
    sql: ${TABLE}."ID_CLASS" ;;
  }

  dimension: id_customer {
    type: string
    sql: ${TABLE}."ID_CUSTOMER" ;;
  }

  dimension: id_department {
    type: string
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }

  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }

  dimension: id_employee {
    type: string
    sql: ${TABLE}."ID_EMPLOYEE" ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }

  dimension: name_location {
    type: string
    sql: ${TABLE}."NAME_LOCATION" ;;
  }

  dimension: id_asset {
    type: string
    sql: ${TABLE}."ID_ASSET" ;;
  }

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: name_modified_by_user {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY_USER" ;;
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

  dimension: fk_gl_account_id {
    type: number
    sql: ${TABLE}."FK_GL_ACCOUNT_ID" ;;
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

  dimension: fk_department_id {
    type: number
    sql: ${TABLE}."FK_DEPARTMENT_ID" ;;
    value_format_name: id
  }

  dimension: fk_employee_dimension_id {
    type: number
    sql: ${TABLE}."FK_EMPLOYEE_DIMENSION_ID" ;;
    value_format_name: id
  }

  dimension: fk_item_dimension_id {
    type: number
    sql: ${TABLE}."FK_ITEM_DIMENSION_ID" ;;
    value_format_name: id
  }

  dimension: fk_location_id {
    type: number
    sql: ${TABLE}."FK_LOCATION_ID" ;;
    value_format_name: id
  }

  dimension: fk_vendor_dimension_id {
    type: number
    sql: ${TABLE}."FK_VENDOR_DIMENSION_ID" ;;
    value_format_name: id
  }

  dimension: fk_vi_header_id {
    type: number
    sql: ${TABLE}."FK_VI_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_receipt_header_id {
    type: number
    sql: ${TABLE}."FK_RECEIPT_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_vi_line_id {
    type: number
    sql: ${TABLE}."FK_VI_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_receipt_line_id {
    type: number
    sql: ${TABLE}."FK_RECEIPT_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_po_line_id {
    type: number
    sql: ${TABLE}."FK_PO_LINE_ID" ;;
    value_format_name: id
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
      pk_ap_line_id,
      fk_ap_header_id,
      id_record,
      num_po_document,
      num_vi_document,
      date_entry_date,
      type_record,
      line_number,
      description_entry,
      flag_line_item,
      amount_line,
      amount_retained,
      amount_subtotal,
      amount_total_paid,
      amount_total_selected,
      amount_trx,
      amount_trx_released,
      amount_trx_retained,
      amount_trx_total_paid,
      amount_trx_total_selected,
      percentage_retainage,
      number_serial,
      number_order,
      id_item,
      name_item,
      number_account,
      title_account,
      number_offset_gl_account,
      title_offset_gl_account,
      number_pr_entry_offset_account,
      number_account_ultimate,
      name_account_ultimate,
      number_ud_esadmin_invoice,
      number_ud_estrack_work_order,
      version_vendor_account_no_key,
      gldim_asset,
      id_expense_line,
      name_expense_line,
      category_expense,
      gldim_transaction_identifier,
      gldim_ud_loan,
      offset_gl,
      box_form_1099,
      type_form_1099,
      state_record,
      id_class,
      id_customer,
      id_department,
      name_department,
      id_employee,
      id_vendor,
      id_location,
      name_location,
      id_asset,
      name_created_by_user,
      name_modified_by_user,
      fk_created_by_user_id,
      fk_modified_by_user_id,
      fk_gl_account_id,
      fk_class_dimension_id,
      fk_customer_dimension_id,
      fk_department_id,
      fk_employee_dimension_id,
      fk_item_dimension_id,
      fk_location_id,
      fk_vendor_dimension_id,
      fk_vi_header_id,
      fk_receipt_header_id,
      fk_vi_line_id,
      fk_receipt_line_id,
      fk_po_line_id,
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

  measure: total_amount_line {
    type: sum
    sql: ${TABLE}."AMOUNT_LINE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_retained {
    type: sum
    sql: ${TABLE}."AMOUNT_RETAINED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_total_paid {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL_PAID" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_total_selected {
    type: sum
    sql: ${TABLE}."AMOUNT_TOTAL_SELECTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_released {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_RELEASED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_retained {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_RETAINED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total_paid {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_PAID" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_trx_total_selected {
    type: sum
    sql: ${TABLE}."AMOUNT_TRX_TOTAL_SELECTED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
