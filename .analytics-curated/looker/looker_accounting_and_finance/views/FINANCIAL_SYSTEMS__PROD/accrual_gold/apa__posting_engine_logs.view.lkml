view: apa__posting_engine_logs {
  sql_table_name: "ACCRUAL_GOLD"."APA__POSTING_ENGINE_LOGS" ;;

  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
  }

  dimension: status_code {
    type: string
    sql: ${TABLE}."STATUS_CODE" ;;
  }

  dimension: header_description {
    type: string
    sql: ${TABLE}."HEADER_DESCRIPTION" ;;
  }

  dimension: gl_journal_id {
    type: string
    sql: ${TABLE}."GL_JOURNAL_ID" ;;
  }

  dimension: fk_gl_batch_id {
    type: string
    sql: ${TABLE}."FK_GL_BATCH_ID" ;;
  }

  dimension: line_description {
    type: string
    sql: ${TABLE}."LINE_DESCRIPTION" ;;
  }

  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }

  dimension: location_id {
    type: string
    sql: ${TABLE}."LOCATION_ID" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: gl_account_id {
    type: string
    sql: ${TABLE}."GL_ACCOUNT_ID" ;;
  }

  dimension: fk_source_po_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_HEADER_ID" ;;
  }

  dimension: fk_source_po_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_PO_LINE_ID" ;;
  }

  dimension: fk_source_receipt_header_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_RECEIPT_HEADER_ID" ;;
  }

  dimension: fk_source_receipt_line_id {
    type: string
    sql: ${TABLE}."FK_SOURCE_RECEIPT_LINE_ID" ;;
  }

  dimension: po_number {
    type: string
    sql: ${TABLE}."PO_NUMBER" ;;
  }

  dimension: ppu_receipt {
    type: number
    sql: ${TABLE}."PPU_RECEIPT" ;;
  }

  dimension: qty_receipt {
    type: number
    sql: ${TABLE}."QTY_RECEIPT" ;;
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

  dimension: txn_amount {
    type: number
    sql: ${TABLE}."TXN_AMOUNT" ;;
  }

  dimension: txn_type {
    type: string
    sql: ${TABLE}."TXN_TYPE" ;;
  }

  measure: count {
    type: count
  }
}
