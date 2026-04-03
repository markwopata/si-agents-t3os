view: vault {
  sql_table_name: "ANALYTICS"."TREASURY"."VAULT"
    ;;


 ###############DIMENSIONS##########################

  dimension: bank_account_name {
    type: string
    sql: ${TABLE}."BANK_ACCOUNT_NAME" ;;
  }

  dimension: bank_account_number {
    type: string
    sql: ${TABLE}."BANK_ACCOUNT_NUMBER" ;;
  }

  dimension: bank_name {
    type: string
    sql: ${TABLE}."BANK_NAME" ;;
  }

  dimension: gl_account_name {
    label: "GL Account Name"
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NAME" ;;
  }

  dimension: gl_account_number {
    label: "GL Account Number"
    type: string
    sql: ${TABLE}."GL_ACCOUNT_NUMBER" ;;
  }

  dimension: restricted {
    type: string
    sql: ${TABLE}."RESTRICTED" ;;
  }

 ###############DATES##########################

  dimension: month_end_date {
    type: date
    sql: ${TABLE}."MONTH_END_DATE" ;;
  }

  dimension: timestamp {
    type: date_time
    sql: ${TABLE}."TIMESTAMP" ;;
  }


  ###############MEASURES##########################

  measure: sage_account_balance {
    type: sum
    value_format: "$#,###;($#,###);-"
    sql: ${TABLE}."SAGE_ACCOUNT_BALANCE" ;;
  }


  measure: trovata_account_balance {
    type: sum
    value_format: "$#,###;($#,###);-"
    sql: ${TABLE}."TROVATA_ACCOUNT_BALANCE" ;;
  }


}
