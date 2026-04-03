view: intacct_sandbox__ap_resolve {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__AP_RESOLVE" ;;

  dimension: amount_invoice_base {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_BASE" ;;
  }
  dimension: amount_invoice_transaction {
    type: number
    sql: ${TABLE}."AMOUNT_INVOICE_TRANSACTION" ;;
  }
  dimension: amount_paid {
    type: number
    value_format_name: id
    sql: ${TABLE}."AMOUNT_PAID" ;;
  }
  dimension: amount_transaction {
    type: number
    sql: ${TABLE}."AMOUNT_TRANSACTION" ;;
  }
  dimension_group: date_payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_PAYMENT" ;;
  }
  dimension: fk_ap_bill_line_id {
    type: number
    sql: ${TABLE}."FK_AP_BILL_LINE_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_parent_payment_id {
    type: number
    sql: ${TABLE}."FK_PARENT_PAYMENT_ID" ;;
  }
  dimension: fk_payment_header_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_HEADER_ID" ;;
  }
  dimension: fk_payment_line_id {
    type: number
    sql: ${TABLE}."FK_PAYMENT_LINE_ID" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: pk_ap_resolve_id {
    type: number
    sql: ${TABLE}."PK_AP_RESOLVE_ID" ;;
  }
  dimension: state_payment {
    type: string
    sql: ${TABLE}."STATE_PAYMENT" ;;
  }
  dimension_group: timestamp_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_CREATED" ;;
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
  dimension_group: timestamp_modified {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."TIMESTAMP_MODIFIED" ;;
  }
  dimension: type_application {
    type: string
    sql: ${TABLE}."TYPE_APPLICATION" ;;
  }
  measure: count {
    type: count
  }
}
