view: intacct_sandbox__gl_accounts {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__GL_ACCOUNTS" ;;

  dimension: balance_normal {
    type: string
    sql: ${TABLE}."BALANCE_NORMAL" ;;
  }
  dimension: category_account {
    type: string
    sql: ${TABLE}."CATEGORY_ACCOUNT" ;;
  }
  dimension: code_tax {
    type: string
    sql: ${TABLE}."CODE_TAX" ;;
  }
  dimension: fk_account_category_id {
    type: number
    sql: ${TABLE}."FK_ACCOUNT_CATEGORY_ID" ;;
  }
  dimension: fk_close_to_account_id {
    type: number
    sql: ${TABLE}."FK_CLOSE_TO_ACCOUNT_ID" ;;
  }
  dimension: fk_created_by_user_id {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_ID" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_mega_entity_id {
    type: number
    sql: ${TABLE}."FK_MEGA_ENTITY_ID" ;;
  }
  dimension: fk_modified_by_user_id {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_ID" ;;
  }
  dimension: is_budgeted {
    type: yesno
    sql: ${TABLE}."IS_BUDGETED" ;;
  }
  dimension: is_general_journal_restricted {
    type: yesno
    sql: ${TABLE}."IS_GENERAL_JOURNAL_RESTRICTED" ;;
  }
  dimension: is_gl_matching_enabled {
    type: yesno
    sql: ${TABLE}."IS_GL_MATCHING_ENABLED" ;;
  }
  dimension: is_require_class {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_CLASS" ;;
  }
  dimension: is_require_customer {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_CUSTOMER" ;;
  }
  dimension: is_require_department {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_DEPARTMENT" ;;
  }
  dimension: is_require_employee {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_EMPLOYEE" ;;
  }
  dimension: is_require_gldim_asset {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_GLDIM_ASSET" ;;
  }
  dimension: is_require_gldim_expense_line {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_GLDIM_EXPENSE_LINE" ;;
  }
  dimension: is_require_gldim_transaction_identifier {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_GLDIM_TRANSACTION_IDENTIFIER" ;;
  }
  dimension: is_require_gldim_ud_loan {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_GLDIM_UD_LOAN" ;;
  }
  dimension: is_require_item {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_ITEM" ;;
  }
  dimension: is_require_location {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_LOCATION" ;;
  }
  dimension: is_require_vendor {
    type: yesno
    sql: ${TABLE}."IS_REQUIRE_VENDOR" ;;
  }
  dimension: is_subledger_control_on {
    type: yesno
    sql: ${TABLE}."IS_SUBLEDGER_CONTROL_ON" ;;
  }
  dimension: is_subledger_restricted {
    type: yesno
    sql: ${TABLE}."IS_SUBLEDGER_RESTRICTED" ;;
  }
  dimension: is_taxable {
    type: yesno
    sql: ${TABLE}."IS_TAXABLE" ;;
  }
  dimension: name_account {
    type: string
    sql: ${TABLE}."NAME_ACCOUNT" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: name_mega_entity {
    type: string
    sql: ${TABLE}."NAME_MEGA_ENTITY" ;;
  }
  dimension: number_account {
    type: string
    sql: ${TABLE}."NUMBER_ACCOUNT" ;;
  }
  dimension: number_account_alternative {
    type: number
    sql: ${TABLE}."NUMBER_ACCOUNT_ALTERNATIVE" ;;
  }
  dimension: pk_gl_account_id {
    type: number
    sql: ${TABLE}."PK_GL_ACCOUNT_ID" ;;
  }
  dimension: status_account {
    type: string
    sql: ${TABLE}."STATUS_ACCOUNT" ;;
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
  dimension: type_account {
    type: string
    sql: ${TABLE}."TYPE_ACCOUNT" ;;
  }
  dimension: type_closing {
    type: string
    sql: ${TABLE}."TYPE_CLOSING" ;;
  }
  dimension: type_wip_setup_account {
    type: string
    sql: ${TABLE}."TYPE_WIP_SETUP_ACCOUNT" ;;
  }
  measure: count {
    type: count
  }
}
