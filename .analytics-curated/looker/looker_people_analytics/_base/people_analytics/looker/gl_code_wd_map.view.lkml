view: gl_code_wd_map {
  sql_table_name: "LOOKER"."GL_COST_CENTER_MAP" ;;

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
    hidden:  yes
  }
  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }
  dimension: account_posting_rule_condition {
    type: string
    sql: ${TABLE}."ACCOUNT_POSTING_RULE_CONDITION" ;;
  }
  dimension: class_of_instance {
    type: string
    sql: ${TABLE}."CLASS_OF_INSTANCE" ;;
  }
  dimension: ledger_account_by_identifier {
    type: number
    value_format_name: id
    sql: ${TABLE}."LEDGER_ACCOUNT_BY_IDENTIFIER" ;;
  }
  measure: count {
    type: count
    drill_fields: [account_name]
  }
}
