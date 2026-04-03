view: apa__fs_accrual_job_ingest {
  sql_table_name: "ACCRUAL_GOLD"."APA__FS_ACCRUAL_JOB_INGEST" ;;

  dimension: fk_source_po_receipt_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_RECEIPT_LINE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_po_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_RECEIPT_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
    group_label: "Foreign Keys"
  }

  dimension_group: date_posting {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_POSTING" ;;
    group_label: "Dates"
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}."ID_VENDOR" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}."GL_ACCOUNT" ;;
  }

  dimension: qty_receipt {
    type: number
    sql: ${TABLE}."QTY_RECEIPT" ;;
    group_label: "Quantities"
  }

  dimension: ppu_receipt {
    type: number
    sql: ${TABLE}."PPU_RECEIPT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_debit {
    type: number
    sql: ${TABLE}."AMOUNT_DEBIT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: amount_credit {
    type: number
    sql: ${TABLE}."AMOUNT_CREDIT" ;;
    value_format_name: usd
    group_label: "Amounts"
  }

  dimension: id_effective_branch {
    type: number
    sql: ${TABLE}."ID_EFFECTIVE_BRANCH" ;;
    value_format_name: id
  }

  dimension: id_expense_line {
    type: number
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
    value_format_name: id
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: url_source_po {
    type: string
    sql: ${TABLE}."URL_SOURCE_PO" ;;
    link: {
      label: "URL Source Po"
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

  dimension: entry_context {
    type: string
    sql: ${TABLE}."ENTRY_CONTEXT" ;;
  }

  dimension: accrual_type {
    type: string
    sql: ${TABLE}."ACCRUAL_TYPE" ;;
  }

  set: detail {
    fields: [
      fk_source_po_receipt_line_id,
      fk_source_po_receipt_header_id,
      fk_source_po_header_id,
      fk_source_po_line_id,
      date_posting_date,
      id_vendor,
      po_number,
      gl_account,
      qty_receipt,
      ppu_receipt,
      amount_received,
      amount_debit,
      amount_credit,
      id_effective_branch,
      id_expense_line,
      memo,
      url_source_po,
      url_vic_po,
      entry_context,
      accrual_type,
    ]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: total_amount_received {
    type: sum
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_debit {
    type: sum
    sql: ${TABLE}."AMOUNT_DEBIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: total_amount_credit {
    type: sum
    sql: ${TABLE}."AMOUNT_CREDIT" ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: avg_qty_receipt {
    type: average
    sql: ${TABLE}."QTY_RECEIPT" ;;
    value_format_name: decimal_2
    drill_fields: [detail*]
  }
}
