view: company_region {
  sql_table_name: "ANALYTICS"."TREASURY"."COMPANY_REGION" ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: invoice_amount {
    type: number
    sql: ${TABLE}."INVOICE_AMOUNT" ;;
  }

  dimension: region {
    type: number
    sql: ${TABLE}."REGION" ;;
  }

}
