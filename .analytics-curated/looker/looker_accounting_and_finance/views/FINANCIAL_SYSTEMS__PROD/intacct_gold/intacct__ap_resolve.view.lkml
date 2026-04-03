view: intacct__ap_resolve {
  sql_table_name: "INTACCT_GOLD"."INTACCT__AP_RESOLVE" ;;

  dimension: pk_ap_resolve_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PK_AP_RESOLVE_ID" ;;
    value_format_name: id
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }

  dimension: id_tax {
    type: string
    sql: ${TABLE}."ID_TAX" ;;
  }

  dimension: type_vendor {
    type: string
    sql: ${TABLE}."TYPE_VENDOR" ;;
  }

  dimension: form_1099_type_vendor {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE_VENDOR" ;;
  }

  dimension: form_1099_box_vendor {
    type: string
    sql: ${TABLE}."FORM_1099_BOX_VENDOR" ;;
  }

  dimension: form_1099_type_bill {
    type: string
    sql: ${TABLE}."FORM_1099_TYPE_BILL" ;;
  }

  dimension: form_1099_box_bill {
    type: string
    sql: ${TABLE}."FORM_1099_BOX_BILL" ;;
  }

  dimension: category_vendor {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR" ;;
  }

  dimension: category_vendor_new {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR_NEW" ;;
  }

  dimension: category_vendor_sub {
    type: string
    sql: ${TABLE}."CATEGORY_VENDOR_SUB" ;;
  }

  dimension: payment_number {
    type: string
    sql: ${TABLE}."PAYMENT_NUMBER" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: num_po_document {
    type: string
    sql: ${TABLE}."NUM_PO_DOCUMENT" ;;
  }

  dimension: num_vi_document {
    type: string
    sql: ${TABLE}."NUM_VI_DOCUMENT" ;;
  }

  dimension: name_pr_batch {
    type: string
    sql: ${TABLE}."NAME_PR_BATCH" ;;
  }

  dimension: account_paid_from {
    type: string
    sql: ${TABLE}."ACCOUNT_PAID_FROM" ;;
  }

  dimension: type_application {
    type: string
    sql: ${TABLE}."TYPE_APPLICATION" ;;
  }

  dimension: type_record {
    type: string
    sql: ${TABLE}."TYPE_RECORD" ;;
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

  dimension_group: date_invoice {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_INVOICE" ;;
  }

  dimension_group: date_payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAYMENT" ;;
  }

  dimension: state_payment {
    type: string
    sql: ${TABLE}."STATE_PAYMENT" ;;
  }

  dimension: amount_transaction {
    type: number
    sql: ${TABLE}."AMOUNT_TRANSACTION" ;;
    value_format_name: usd
  }

  dimension: amount_paid {
    type: number
    sql: ${TABLE}."AMOUNT_PAID" ;;
    value_format_name: usd
  }

  dimension: amount_invoice_base {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_BASE" ;;
    value_format_name: usd
  }

  dimension: amount_invoice_transaction {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_TRANSACTION" ;;
    value_format_name: usd
  }

  dimension: name_created_by_user {
    type: string
    sql: ${TABLE}."NAME_CREATED_BY_USER" ;;
  }

  dimension: name_modified_by_user {
    type: string
    sql: ${TABLE}."NAME_MODIFIED_BY_USER" ;;
  }

  dimension: url_intacct {
    type: string
    sql: ${TABLE}."URL_INTACCT" ;;
    link: {
      label: "URL Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_pdf {
    type: string
    sql: ${TABLE}."URL_PDF" ;;
    link: {
      label: "URL Pdf"
      url: "{{ value }}"
    }
  }

  dimension: fk_ap_bill_line_id {
    type: number
    sql: ${TABLE}."FK_AP_BILL_LINE_ID" ;;
    value_format_name: id
  }

  dimension: fk_parent_payment_id {
    type: number
    sql: ${TABLE}."FK_PARENT_PAYMENT_ID" ;;
    value_format_name: id
  }

  dimension: fk_payment_header_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: fk_payment_line_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_LINE_ID" ;;
    value_format_name: id
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
      pk_ap_resolve_id,
      id_vendor,
      name_vendor,
      id_tax,
      type_vendor,
      form_1099_type_vendor,
      form_1099_box_vendor,
      form_1099_type_bill,
      form_1099_box_bill,
      category_vendor,
      category_vendor_new,
      category_vendor_sub,
      payment_number,
      invoice_number,
      num_po_document,
      num_vi_document,
      name_pr_batch,
      account_paid_from,
      type_application,
      type_record,
      id_item,
      name_item,
      number_account,
      name_account,
      number_account_ultimate,
      name_account_ultimate,
      id_location,
      name_location,
      id_department,
      name_department,
      date_invoice_date,
      date_payment_date,
      state_payment,
      amount_transaction,
      amount_paid,
      amount_invoice_base,
      amount_invoice_transaction,
      name_created_by_user,
      name_modified_by_user,
      url_intacct,
      url_pdf,
      fk_ap_bill_line_id,
      fk_parent_payment_id,
      fk_payment_header_id,
      fk_payment_line_id,
      fk_created_by_user_id,
      fk_modified_by_user_id,
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

  measure: total_amount_paid {
    type: sum
    sql: ${TABLE}."AMOUNT_PAID" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_invoice_base {
    type: sum
    sql: ${TABLE}."AMOUNT_INVOICE_BASE" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_invoice_transaction {
    type: sum
    sql: ${TABLE}."AMOUNT_INVOICE_TRANSACTION" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }
}
