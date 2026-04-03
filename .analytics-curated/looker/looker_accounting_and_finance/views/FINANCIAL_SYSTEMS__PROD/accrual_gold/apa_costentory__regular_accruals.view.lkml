view: apa_costentory__regular_accruals {
  sql_table_name: "ACCRUAL_GOLD"."APA_COSTENTORY__REGULAR_ACCRUALS" ;;

  dimension: fk_source_po_receipt_line_id {
    type: number
    sql: ${TABLE}.fk_source_po_receipt_line_id ;;
    value_format_name: id
  }

  dimension: fk_source_po_receipt_header_id {
    type: number
    sql: ${TABLE}.fk_source_po_receipt_header_id ;;
    value_format_name: id
  }

  dimension: fk_source_po_header_id {
    type: number
    sql: ${TABLE}.fk_source_po_header_id ;;
    value_format_name: id
  }

  dimension: fk_source_po_line_id {
    type: number
    sql: ${TABLE}.fk_source_po_line_id ;;
    value_format_name: id
  }

  dimension_group: date_posting_input {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date_posting_input ;;
  }

  dimension_group: date_posting_actual {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}.date_posting_actual ;;
  }

  dimension: id_vendor {
    type: string
    sql: ${TABLE}.id_vendor ;;
  }

  dimension: po_number {
    type: number
    sql: ${TABLE}.po_number ;;
    value_format_name: id
  }

  dimension: gl_account {
    type: string
    sql: ${TABLE}.gl_account ;;
  }

  dimension: qty_receipt {
    type: number
    sql: ${TABLE}.qty_receipt ;;
  }

  dimension: ppu_receipt {
    type: string
    sql: ${TABLE}.ppu_receipt ;;
  }

  dimension: amount_received {
    type: number
    sql: ${TABLE}.amount_received ;;
    value_format_name: usd
  }

  dimension: amount_debit {
    type: number
    sql: ${TABLE}.amount_debit ;;
    value_format_name: usd
  }

  dimension: amount_credit {
    type: number
    sql: ${TABLE}.amount_credit ;;
    value_format_name: usd
  }

  dimension: id_effective_branch {
    type: string
    sql: ${TABLE}.id_effective_branch ;;
  }

  dimension: id_expense_line {
    type: string
    sql: ${TABLE}.id_expense_line ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}.memo ;;
  }

  dimension: url_source_po {
    type: string
    sql: ${TABLE}.url_source_po ;;
    link: {
      label: "URL Source Po"
      url: "{{ value }}"
    }
  }

  dimension: url_vic_po {
    type: string
    sql: ${TABLE}.url_vic_po ;;
    link: {
      label: "URL Vic Po"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_invoice {
    type: string
    sql: ${TABLE}.url_sage_invoice ;;
    link: {
      label: "URL Sage Invoice"
      url: "{{ value }}"
    }
  }

  dimension: url_vic_invoice {
    type: string
    sql: ${TABLE}.url_vic_invoice ;;
    link: {
      label: "URL Vic Invoice"
      url: "{{ value }}"
    }
  }

  dimension: url_sage_apbill {
    type: string
    sql: ${TABLE}.url_sage_apbill ;;
    link: {
      label: "URL Sage Apbill"
      url: "{{ value }}"
    }
  }

  dimension: entry_context {
    type: string
    sql: ${TABLE}.entry_context ;;
  }

  dimension: accrual_type {
    type: string
    sql: ${TABLE}.accrual_type ;;
  }

  dimension_group: timestamp_generated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}.timestamp_generated ;;
  }
}
