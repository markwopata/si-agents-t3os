view: corporate_card_accounts {
  sql_table_name: "CREDIT_CARD"."CORPORATE_CARD_ACCOUNTS" ;;

  dimension: card_type {
    type: string
    sql: ${TABLE}."CARD_TYPE" ;;
  }
  dimension: corporate_account_name {
    type: string
    sql: ${TABLE}."CORPORATE_ACCOUNT_NAME" ;;
  }
  dimension: corporate_account_number {
    type: string
    sql: ${TABLE}."CORPORATE_ACCOUNT_NUMBER" ;;
  }
  measure: count {
    type: count
    drill_fields: [corporate_account_name]
  }
}
