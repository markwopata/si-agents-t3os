view: lender_to_company_id {
  sql_table_name: "ANALYTICS"."DEBT"."LENDER_TO_COMPANY_ID"
    ;;

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
    value_format_name: id

  }

  dimension: financial_lender_id {
    type: number
    sql: ${TABLE}."FINANCIAL_LENDER_ID" ;;
    value_format_name: id
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
