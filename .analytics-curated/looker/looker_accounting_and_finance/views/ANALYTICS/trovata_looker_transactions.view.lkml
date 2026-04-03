view: trovata_looker_transactions {
  sql_table_name: "ANALYTICS"."TREASURY"."TROVATA_LOOKER_TRANSACTIONS"
    ;;

  ############################################## DIMENSIONS ###########################################################

  dimension: date {
    type: date
    sql: ${TABLE}."DATE"  ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: bank {
    type: string
    sql: ${TABLE}."BANK" ;;
  }

  dimension: bank_acct_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: bank_acct_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: year_quarter {
    type: string
    sql: ${TABLE}."YEAR_QUARTER" ;;
  }

  dimension: cf1 {
    label: "CF1"
    type: string
    sql: ${TABLE}."CF1" ;;
  }

  dimension: cf2 {
    label: "CF2"
    type: string
    sql: ${TABLE}."CF2" ;;
  }

  dimension: cf3 {
    label: "CF3"
    type: string
    sql: ${TABLE}."CF3" ;;
  }



  dimension: socf {
    label: "SOCF"
    type: string
    sql: ${TABLE}."SOCF" ;;
                  }

  dimension: section {
    type: string
    sql: ${TABLE}."SECTION" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }


  ############################################## MEASURES ###########################################################


  measure: amount_mm {
    label: "amount"
    type: sum
    value_format: "$#,##0.0;($#,##0.0);-"
    drill_fields: [trx_details*]
    sql: ${TABLE}."AMOUNT"/1000000 ;;
  }

  measure: amount {
    label: "amount"
    type: sum
    value_format: "$#,##0.0;($#,##0.0);-"
    drill_fields: [trx_details*]
    sql: ${TABLE}."AMOUNT" ;;
  }

  set: trx_details {
    fields: [date,bank,bank_acct_number,bank_acct_name,cf1,cf2,cf3,socf,section,description,amount
    ]
  }

}
