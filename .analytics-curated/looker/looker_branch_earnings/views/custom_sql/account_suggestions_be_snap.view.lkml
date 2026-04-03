view: account_suggestions_be_snap {
  sql_table_name: analytics.branch_earnings.account_suggestions_be_snap ;;

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: account_category {
    type: string
    sql: ${TABLE}."ACCOUNT_CATEGORY" ;;
  }

  measure: count {
    type: count
    drill_fields: [account_number, account_name, account_category]
  }
}
