view: intacct_sandbox__expense_lines {
  sql_table_name: "GOLD"."INTACCT_SANDBOX__EXPENSE_LINES" ;;

  dimension: category_expense {
    type: string
    sql: ${TABLE}."CATEGORY_EXPENSE" ;;
  }
  dimension: fk_created_by_user_key {
    type: number
    sql: ${TABLE}."FK_CREATED_BY_USER_KEY" ;;
  }
  dimension: fk_extract_hash_id {
    type: number
    sql: ${TABLE}."FK_EXTRACT_HASH_ID" ;;
  }
  dimension: fk_modified_by_user_key {
    type: number
    sql: ${TABLE}."FK_MODIFIED_BY_USER_KEY" ;;
  }
  dimension: is_expense_line_discontinued {
    type: yesno
    sql: ${TABLE}."IS_EXPENSE_LINE_DISCONTINUED" ;;
  }
  dimension: name_expense_line {
    type: string
    sql: ${TABLE}."NAME_EXPENSE_LINE" ;;
  }
  dimension: name_file {
    type: string
    sql: ${TABLE}."NAME_FILE" ;;
  }
  dimension: pk_expense_line_id {
    type: number
    sql: ${TABLE}."PK_EXPENSE_LINE_ID" ;;
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
  measure: count {
    type: count
  }
}
