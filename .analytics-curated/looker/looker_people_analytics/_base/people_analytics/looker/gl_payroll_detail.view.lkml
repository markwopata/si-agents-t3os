view: gl_payroll_detail {
  sql_table_name: "LOOKER"."GL_PAYROLL_DETAIL" ;;

  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }
  dimension: account_normal_balance {
    type: string
    sql: ${TABLE}."ACCOUNT_NORMAL_BALANCE" ;;
  }
  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }
  dimension: account_type {
    type: string
    sql: ${TABLE}."ACCOUNT_TYPE" ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: applied_sign {
    type: number
    sql: ${TABLE}."APPLIED_SIGN" ;;
  }
  dimension: balance_sheet_sign {
    type: number
    sql: ${TABLE}."BALANCE_SHEET_SIGN" ;;
  }
  dimension: base_currency_code {
    type: string
    sql: ${TABLE}."BASE_CURRENCY_CODE" ;;
  }
  dimension: category {
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: combined_state {
    type: string
    sql: ${TABLE}."COMBINED_STATE" ;;
  }
  dimension: created_by_name {
    type: string
    sql: ${TABLE}."CREATED_BY_NAME" ;;
  }
  dimension: created_by_username {
    type: string
    sql: ${TABLE}."CREATED_BY_USERNAME" ;;
  }
  dimension: currency_code {
    type: string
    sql: ${TABLE}."CURRENCY_CODE" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_reversed {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_REVERSED" ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: debit_credit {
    type: string
    sql: ${TABLE}."DEBIT_CREDIT" ;;
  }
  dimension: debit_credit_sign {
    type: number
    sql: ${TABLE}."DEBIT_CREDIT_SIGN" ;;
  }
  dimension: department_id {
    type: string
    sql: ${TABLE}."DEPARTMENT_ID" ;;
  }
  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }
  dimension: document {
    type: string
    sql: ${TABLE}."DOCUMENT" ;;
  }
  dimension: entity_id {
    type: string
    sql: ${TABLE}."ENTITY_ID" ;;
  }
  dimension: entity_name {
    type: string
    sql: ${TABLE}."ENTITY_NAME" ;;
  }
  dimension: entry_amount {
    type: number
    sql: ${TABLE}."ENTRY_AMOUNT" ;;
  }
  dimension: entry_date{
    type: date_raw
    sql: ${TABLE}."ENTRY_DATE" ;;
    hidden: yes
  }

  dimension: entry_description {
    type: string
    sql: ${TABLE}."ENTRY_DESCRIPTION" ;;
  }
  dimension: entry_state {
    type: string
    sql: ${TABLE}."ENTRY_STATE" ;;
  }
  dimension: exchange_rate {
    type: number
    sql: ${TABLE}."EXCHANGE_RATE" ;;
  }
  dimension_group: exchange_rate {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."EXCHANGE_RATE_DATE" ;;
  }
  dimension: expense_category {
    type: string
    sql: ${TABLE}."EXPENSE_CATEGORY" ;;
  }
  dimension: expense_type {
    type: string
    sql: ${TABLE}."EXPENSE_TYPE" ;;
  }
  dimension: extended_entity_name {
    type: string
    sql: ${TABLE}."EXTENDED_ENTITY_NAME" ;;
  }
  dimension: extended_journal_type {
    type: string
    sql: ${TABLE}."EXTENDED_JOURNAL_TYPE" ;;
  }
  dimension: fk_account_id {
    type: number
    sql: ${TABLE}."FK_ACCOUNT_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_expense_type_id {
    type: number
    sql: ${TABLE}."FK_EXPENSE_TYPE_ID" ;;
  }
  dimension: fk_gl_entry_id {
    type: number
    sql: ${TABLE}."FK_GL_ENTRY_ID" ;;
  }
  dimension: fk_gl_resolve_id {
    type: string
    sql: ${TABLE}."FK_GL_RESOLVE_ID" ;;
  }
  dimension: fk_journal_id {
    type: number
    sql: ${TABLE}."FK_JOURNAL_ID" ;;
  }
  dimension: fk_reversed_from_journal_id {
    type: number
    sql: ${TABLE}."FK_REVERSED_FROM_JOURNAL_ID" ;;
  }
  dimension: fk_subledger_header_id {
    type: number
    sql: ${TABLE}."FK_SUBLEDGER_HEADER_ID" ;;
  }
  dimension: fk_subledger_line_id {
    type: number
    sql: ${TABLE}."FK_SUBLEDGER_LINE_ID" ;;
  }
  dimension: fk_ud_loan_id {
    type: number
    sql: ${TABLE}."FK_UD_LOAN_ID" ;;
  }
  dimension: fk_updated_by_user_id {
    type: number
    sql: ${TABLE}."FK_UPDATED_BY_USER_ID" ;;
  }
  dimension: gl_dim_asset_id {
    type: number
    sql: ${TABLE}."GL_DIM_ASSET_ID" ;;
  }
  dimension: gl_dim_transaction_identifier {
    type: string
    sql: ${TABLE}."GL_DIM_TRANSACTION_IDENTIFIER" ;;
  }
  dimension: intacct_module {
    type: string
    sql: ${TABLE}."INTACCT_MODULE" ;;
  }
  dimension: is_statistical {
    type: yesno
    sql: ${TABLE}."IS_STATISTICAL" ;;
  }
  dimension: is_true_entry {
    type: yesno
    sql: ${TABLE}."IS_TRUE_ENTRY" ;;
  }
  dimension: journal_state {
    type: string
    sql: ${TABLE}."JOURNAL_STATE" ;;
  }
  dimension: journal_title {
    type: string
    sql: ${TABLE}."JOURNAL_TITLE" ;;
  }
  dimension: journal_transaction_number {
    type: number
    sql: ${TABLE}."JOURNAL_TRANSACTION_NUMBER" ;;
  }
  dimension: journal_type {
    type: string
    sql: ${TABLE}."JOURNAL_TYPE" ;;
  }
  dimension: line_number {
    type: number
    sql: ${TABLE}."LINE_NUMBER" ;;
  }
  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: net_amount {
    type: number
    sql: ${TABLE}."NET_AMOUNT" ;;
  }
  dimension: net_entry_amount {
    type: number
    sql: ${TABLE}."NET_ENTRY_AMOUNT" ;;
  }
  dimension: pk_gl_detail_id {
    type: string
    sql: ${TABLE}."PK_GL_DETAIL_ID" ;;
  }
  dimension: positive_revenue_sign {
    type: number
    sql: ${TABLE}."POSITIVE_REVENUE_SIGN" ;;
  }
  dimension: raw_amount {
    type: number
    sql: ${TABLE}."RAW_AMOUNT" ;;
  }
  dimension: raw_entry_amount {
    type: number
    sql: ${TABLE}."RAW_ENTRY_AMOUNT" ;;
  }
  dimension_group: raw_entry {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."RAW_ENTRY_DATE" ;;
  }
  dimension: source {
    type: string
    sql: ${TABLE}."SOURCE" ;;
  }
  dimension: updated_by_name {
    type: string
    sql: ${TABLE}."UPDATED_BY_NAME" ;;
  }
  dimension: updated_by_username {
    type: string
    sql: ${TABLE}."UPDATED_BY_USERNAME" ;;
  }
  dimension: url_journal {
    type: string
    sql: ${TABLE}."URL_JOURNAL" ;;
  }
  measure: count {
    type: count
    drill_fields: [detail*]
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      updated_by_name,
      created_by_name,
      market_name,
      extended_entity_name,
      updated_by_username,
      account_name,
      department_name,
      created_by_username,
      entity_name
    ]
  }

}
