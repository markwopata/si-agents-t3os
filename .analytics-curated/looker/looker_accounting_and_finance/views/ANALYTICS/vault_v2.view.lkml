view: vault_v2 {
  sql_table_name: "ANALYTICS"."TREASURY"."VAULT_V2" ;;

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

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

 ###############DATES##########################

  dimension: month_end_date {
    label: "Month End Date"
    type: date
    sql: ${TABLE}."MONTH_END_DATE" ;;
    }

  dimension: month_end_date_p1 {
    label: "Month End Date Plus One"
    type: date
    sql: ${TABLE}."MONTH_END_DATE_P1" ;;
  }

  ###############MEASURES##########################

  measure: sage_balance {
    type: sum
    drill_fields: [vault_details_2*]
    value_format: "$#,###.00;($#,###.00);-"
    sql: ${TABLE}."SAGE_BALANCE" ;;
  }

  measure: trovata_balance {
    type: sum
    drill_fields: [vault_details_2*]
    value_format: "$#,###.00;($#,###.00);-"
    sql: ${TABLE}."TROVATA_BALANCE" ;;
  }

  measure: variance {
    type: sum
    value_format: "$#,###.00;($#,###.00);-"
    sql: ${TABLE}."VARIANCE" ;;
  }

############ DRILL FIELDS #################
  set: vault_details_2 {
    fields: [bank_name,bank_account_name,bank_account_number,gl_account_name,gl_account_number,
      restricted,trovata_balance,sage_balance]
  }

}
