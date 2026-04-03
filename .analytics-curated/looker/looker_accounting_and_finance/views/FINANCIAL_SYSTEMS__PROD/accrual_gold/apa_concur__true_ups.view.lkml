view: apa_concur__true_ups {
  sql_table_name: "ACCRUAL_GOLD"."APA_CONCUR__TRUE_UPS" ;;

  dimension: fk_source_po_receipt_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_RECEIPT_LINE_ID" ;;
  }

  dimension: fk_source_po_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_RECEIPT_HEADER_ID" ;;
  }

  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
  }

  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
  }

  dimension_group: date_posting_input {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_POSTING_INPUT" ;;
  }

  dimension_group: date_posting_actual {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_POSTING_ACTUAL" ;;
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
  }

  dimension: ppu_receipt {
    type: number
    sql: ${TABLE}."PPU_RECEIPT" ;;
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}."AMOUNT_RECEIVED" ;;
    value_format_name: usd
  }

  dimension: amount_debit {
    type: number
    sql: ${TABLE}."AMOUNT_DEBIT" ;;
    value_format_name: usd
  }

  dimension: amount_credit {
    type: number
    sql: ${TABLE}."AMOUNT_CREDIT" ;;
    value_format_name: usd
  }

  dimension: id_effective_branch {
    type: number
    sql: ${TABLE}."ID_EFFECTIVE_BRANCH" ;;
  }

  dimension: id_expense_line {
    type: number
    sql: ${TABLE}."ID_EXPENSE_LINE" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: url_source_po {
    type: string
    sql: ${TABLE}."URL_SOURCE_PO" ;;
    link: {
      label: "URL Source PO"
      url: "{{ value }}"
    }
  }

  dimension: url_vic_po {
    type: string
    sql: ${TABLE}."URL_VIC_PO" ;;
    link: {
      label: "URL Vic PO"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_invoice {
    type: string
    sql: ${TABLE}."URL_SAGE_INVOICE" ;;
    link: {
      label: "URL Sage Invoice"
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

  dimension: url_sage_apbill {
    type: string
    sql: ${TABLE}."URL_SAGE_APBILL" ;;
    link: {
      label: "URL Sage Apbill"
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

  dimension_group: timestamp_generated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_GENERATED" ;;
  }

  measure: count {
    type: count
  }
}
