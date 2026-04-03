view: intacct_sandbox__gl_journals {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__GL_JOURNALS" ;;

  dimension_group: date_last {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_LAST" ;;
  }
  dimension_group: date_start {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_START" ;;
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
  dimension: id_book {
    type: string
    sql: ${TABLE}."ID_BOOK" ;;
  }
  dimension: is_adjustment_allowed {
    type: yesno
    sql: ${TABLE}."IS_ADJUSTMENT_ALLOWED" ;;
  }
  dimension: is_billable {
    type: yesno
    sql: ${TABLE}."IS_BILLABLE" ;;
  }
  dimension: is_direct_posting_disabled {
    type: yesno
    sql: ${TABLE}."IS_DIRECT_POSTING_DISABLED" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_journal {
    type: string
    sql: ${TABLE}."NAME_JOURNAL" ;;
  }
  dimension: pk_gl_journal_id {
    type: number
    sql: ${TABLE}."PK_GL_JOURNAL_ID" ;;
  }
  dimension: status_journal {
    type: string
    sql: ${TABLE}."STATUS_JOURNAL" ;;
  }
  dimension: symbol_journal {
    type: string
    sql: ${TABLE}."SYMBOL_JOURNAL" ;;
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
  dimension: type_book {
    type: string
    sql: ${TABLE}."TYPE_BOOK" ;;
  }
  measure: count {
    type: count
  }
}
