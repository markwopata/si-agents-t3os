view: payment_cruncher_detail {
  sql_table_name: "P2P_GOLD"."PAYMENT_CRUNCHER_DETAIL" ;;

  dimension: fk_ap_header_id {
    type: number
    sql: ${TABLE}."FK_AP_HEADER_ID" ;;
    value_format_name: id
  }

  dimension: pk_ap_line_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PK_AP_LINE_ID" ;;
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

  dimension: status_vendor {
    type: string
    sql: ${TABLE}."STATUS_VENDOR" ;;
  }

  dimension: is_do_not_cut_check {
    type: yesno
    sql: ${TABLE}."IS_DO_NOT_CUT_CHECK" ;;
  }

  dimension: is_vendor_on_hold {
    type: yesno
    sql: ${TABLE}."IS_VENDOR_ON_HOLD" ;;
  }

  dimension: is_related_party {
    type: yesno
    sql: ${TABLE}."IS_RELATED_PARTY" ;;
  }

  dimension: code_country {
    type: string
    sql: ${TABLE}."CODE_COUNTRY" ;;
  }

  dimension: preferred_payment_method {
    type: string
    sql: ${TABLE}."PREFERRED_PAYMENT_METHOD" ;;
  }

  dimension: epay_deduction {
    type: string
    sql: ${TABLE}."EPAY_DEDUCTION" ;;
  }

  dimension: id_mega_entity {
    type: string
    sql: ${TABLE}."ID_MEGA_ENTITY" ;;
  }

  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NUMBER" ;;
  }

  dimension: type_record_calculated {
    type: string
    sql: ${TABLE}."TYPE_RECORD_CALCULATED" ;;
  }

  dimension: document_converted_from {
    type: string
    sql: ${TABLE}."DOCUMENT_CONVERTED_FROM" ;;
  }

  dimension: raw_payment_term {
    type: string
    sql: ${TABLE}."RAW_PAYMENT_TERM" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_posted {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_POSTED" ;;
  }

  dimension_group: date_due_raw {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DUE_RAW" ;;
  }

  dimension_group: date_discount {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DISCOUNT" ;;
  }

  dimension_group: adjusted_due_date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."ADJUSTED_DUE_DATE" ;;
  }

  dimension: is_due {
    type: yesno
    sql: ${TABLE}."IS_DUE" ;;
  }

  dimension: amount_vendor_due {
    type: number
    sql: ${TABLE}."AMOUNT_VENDOR_DUE" ;;
    value_format_name: usd
  }

  dimension: amount_invoice_total {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_TOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_invoice_paid {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_PAID" ;;
    value_format_name: usd
  }

  dimension: amount_invoice_selected {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_SELECTED" ;;
    value_format_name: usd
  }

  dimension: amount_invoice_balance {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_BALANCE" ;;
    value_format_name: usd
  }

  dimension: amount_line_total {
    type: number
    sql: ${TABLE}."AMOUNT_LINE_TOTAL" ;;
    value_format_name: usd
  }

  dimension: amount_line_paid {
    type: number
    sql: ${TABLE}."AMOUNT_LINE_PAID" ;;
    value_format_name: usd
  }

  dimension: amount_line_selected {
    type: number
    sql: ${TABLE}."AMOUNT_LINE_SELECTED" ;;
    value_format_name: usd
  }

  dimension: amount_line_balance {
    type: number
    sql: ${TABLE}."AMOUNT_LINE_BALANCE" ;;
    value_format_name: usd
  }

  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }

  dimension: title_account {
    type: string
    sql: ${TABLE}."TITLE_ACCOUNT" ;;
  }

  dimension: id_department {
    type: string
    sql: ${TABLE}."ID_DEPARTMENT" ;;
  }

  dimension: name_department {
    type: string
    sql: ${TABLE}."NAME_DEPARTMENT" ;;
  }

  dimension: state_record {
    type: string
    sql: ${TABLE}."STATE_RECORD" ;;
  }

  dimension: is_on_hold {
    type: yesno
    sql: ${TABLE}."IS_ON_HOLD" ;;
  }

  dimension: status_department {
    type: string
    sql: ${TABLE}."STATUS_DEPARTMENT" ;;
  }

  dimension: url_intacct {
    type: string
    sql: ${TABLE}."URL_INTACCT" ;;
    link: {
      label: "URL Intacct"
      url: "{{ value }}"
    }
  }

  dimension: url_vic {
    type: string
    sql: ${TABLE}."URL_VIC" ;;
    link: {
      label: "URL Vic"
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

  measure: count {
    type: count
  }
}
