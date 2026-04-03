view: intacct_sandbox__gl_entries {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__GL_ENTRIES" ;;

  dimension: amount_gl {
    type: number
    sql: ${TABLE}."AMOUNT_GL" ;;
  }
  dimension: amount_raw {
    type: number
    sql: ${TABLE}."AMOUNT_RAW" ;;
  }
  dimension: amount_raw_signed {
    type: number
    sql: ${TABLE}."AMOUNT_RAW_SIGNED" ;;
  }
  dimension: amount_signed {
    type: number
    sql: ${TABLE}."AMOUNT_SIGNED" ;;
  }
  dimension: amount_trx {
    type: number
    sql: ${TABLE}."AMOUNT_TRX" ;;
  }
  dimension: amount_trx_signed {
    type: number
    sql: ${TABLE}."AMOUNT_TRX_SIGNED" ;;
  }
  dimension_group: date_cleared {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CLEARED" ;;
  }
  dimension_group: date_entry {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_ENTRY" ;;
  }
  dimension_group: date_recon {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_RECON" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: fk_allocation_id {
    type: number
    sql: ${TABLE}."FK_ALLOCATION_ID" ;;
  }
  dimension: fk_class_dimension_id {
    type: string
    sql: ${TABLE}."FK_CLASS_DIMENSION_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: string
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_customer_dimension_id {
    type: string
    sql: ${TABLE}."FK_CUSTOMER_DIMENSION_ID" ;;
  }
  dimension: fk_department_id {
    type: string
    sql: ${TABLE}."FK_DEPARTMENT_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_gl_account_id {
    type: number
    sql: ${TABLE}."FK_GL_ACCOUNT_ID" ;;
  }
  dimension: fk_item_dimension_id {
    type: string
    sql: ${TABLE}."FK_ITEM_DIMENSION_ID" ;;
  }
  dimension: fk_location_id {
    type: string
    sql: ${TABLE}."FK_LOCATION_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: string
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: fk_vendor_dimension_id {
    type: string
    sql: ${TABLE}."FK_VENDOR_DIMENSION_ID" ;;
  }
  dimension: flag_adjustment {
    type: string
    sql: ${TABLE}."FLAG_ADJUSTMENT" ;;
  }
  dimension: flag_statistical {
    type: string
    sql: ${TABLE}."FLAG_STATISTICAL" ;;
  }
  dimension: gldim_asset {
    type: string
    sql: ${TABLE}."GLDIM_ASSET" ;;
  }
  dimension: gldim_expense_line {
    type: string
    sql: ${TABLE}."GLDIM_EXPENSE_LINE" ;;
  }
  dimension: gldim_transaction_identifier {
    type: string
    sql: ${TABLE}."GLDIM_TRANSACTION_IDENTIFIER" ;;
  }
  dimension: gldim_ud_loan {
    type: string
    sql: ${TABLE}."GLDIM_UD_LOAN" ;;
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
  dimension: id_document {
    type: string
    sql: ${TABLE}."ID_DOCUMENT" ;;
  }
  dimension: id_item {
    type: string
    sql: ${TABLE}."ID_ITEM" ;;
  }
  dimension: id_location {
    type: string
    sql: ${TABLE}."ID_LOCATION" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }
  dimension: number_batch {
    type: string
    sql: ${TABLE}."NUMBER_BATCH" ;;
  }
  dimension: number_line {
    type: number
    sql: ${TABLE}."NUMBER_LINE" ;;
  }
  dimension: number_serial {
    type: string
    sql: ${TABLE}."NUMBER_SERIAL" ;;
  }
  dimension: pk_gl_entry_id {
    type: number
    sql: ${TABLE}."PK_GL_ENTRY_ID" ;;
  }
  dimension: price_unit {
    type: number
    sql: ${TABLE}."PRICE_UNIT" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: state_entry {
    type: string
    sql: ${TABLE}."STATE_ENTRY" ;;
  }
  dimension: status_cleared {
    type: string
    sql: ${TABLE}."STATUS_CLEARED" ;;
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
  dimension: title_batch {
    type: string
    sql: ${TABLE}."TITLE_BATCH" ;;
  }
  dimension: type_transaction {
    type: number
    sql: ${TABLE}."TYPE_TRANSACTION" ;;
  }
  measure: count {
    type: count
  }
}
