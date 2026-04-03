view: vic_sandbox__invoice_headers {
  sql_table_name: "VIC_GOLD"."VIC_SANDBOX__INVOICE_HEADERS" ;;

  dimension: amount_tax {
    type: number
    sql: ${TABLE}."AMOUNT_TAX" ;;
  }
  dimension: amount_total {
    type: number
    sql: ${TABLE}."AMOUNT_TOTAL" ;;
  }
  dimension: amount_without_tax {
    type: number
    sql: ${TABLE}."AMOUNT_WITHOUT_TAX" ;;
  }
  dimension: bol_numbers {
    type: string
    sql: ${TABLE}."BOL_NUMBERS" ;;
  }
  dimension: custom_fields {
    type: string
    sql: ${TABLE}."CUSTOM_FIELDS" ;;
  }
  dimension_group: date_due {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_DUE" ;;
  }
  dimension_group: date_gl {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_GL" ;;
  }
  dimension_group: date_issue {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ISSUE" ;;
  }
  dimension: fk_sage_invoice_header_id {
    type: string
    sql: ${TABLE}."FK_SAGE_INVOICE_HEADER_ID" ;;
  }
  dimension: fk_vendor_external_id {
    type: string
    sql: ${TABLE}."FK_VENDOR_EXTERNAL_ID" ;;
  }
  dimension: fk_vendor_internal_id {
    type: string
    sql: ${TABLE}."FK_VENDOR_INTERNAL_ID" ;;
  }
  dimension: fk_vic_invoice_header_id {
    type: string
    sql: ${TABLE}."FK_VIC_INVOICE_HEADER_ID" ;;
  }
  dimension: id_currency {
    type: string
    sql: ${TABLE}."ID_CURRENCY" ;;
  }
  dimension: language_invoice {
    type: string
    sql: ${TABLE}."LANGUAGE_INVOICE" ;;
  }
  dimension: line_items {
    type: string
    sql: ${TABLE}."LINE_ITEMS" ;;
  }
  dimension: name_environment {
    type: string
    sql: ${TABLE}."NAME_ENVIRONMENT" ;;
  }
  dimension: name_vendor {
    type: string
    sql: ${TABLE}."NAME_VENDOR" ;;
  }
  dimension: payment_term_count {
    type: number
    sql: ${TABLE}."PAYMENT_TERM_COUNT" ;;
  }
  dimension: payment_term_unit {
    type: string
    sql: ${TABLE}."PAYMENT_TERM_UNIT" ;;
  }
  dimension: pk_extract_hash_id {
    type: number
    sql: ${TABLE}."PK_EXTRACT_HASH_ID" ;;
  }
  dimension: ref_number {
    type: string
    sql: ${TABLE}."REF_NUMBER" ;;
  }
  dimension: status_bill {
    type: string
    sql: ${TABLE}."STATUS_BILL" ;;
  }
  dimension: status_payment {
    type: string
    sql: ${TABLE}."STATUS_PAYMENT" ;;
  }
  dimension_group: timestamp_extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_EXTRACTED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."TIMESTAMP_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: type_transaction {
    type: string
    sql: ${TABLE}."TYPE_TRANSACTION" ;;
  }
  dimension: vendor_country_code {
    type: string
    sql: ${TABLE}."VENDOR_COUNTRY_CODE" ;;
  }
  measure: count {
    type: count
  }
}
