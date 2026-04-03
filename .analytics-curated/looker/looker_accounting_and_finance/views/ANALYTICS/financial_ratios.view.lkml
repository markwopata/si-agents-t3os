view: financial_ratios {
  sql_table_name: "ANALYTICS"."TREASURY"."FINANCIAL_RATIOS"
    ;;

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

  measure: accounts_payable {
    type:sum
    value_format:"$#,MM;($#,MM)"
    sql: ${TABLE}."ACCOUNTS_PAYABLE" ;;
  }

  measure: ap_turnover {
    type: sum
    value_format: "#.00;(#.00)"
    sql: ${TABLE}."AP_TURNOVER" ;;
  }

  measure: ar_turnover {
    type: sum
    value_format: "#.00;(#.00)"
    sql: ${TABLE}."AR_TURNOVER" ;;
  }



  measure: quick_ratio {
    type: sum
    value_format: "#.00;(#.00)"
    sql: ${TABLE}."QUICK_RATIO" ;;
  }

}
