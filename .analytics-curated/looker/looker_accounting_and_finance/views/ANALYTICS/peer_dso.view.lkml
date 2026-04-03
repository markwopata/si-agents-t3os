view: peer_dso {
  sql_table_name: "ANALYTICS"."TREASURY"."PEER_DSO" ;;

####### DIMENSIONS #######

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY" ;;
  }

  dimension: quarter {
    type: string
    sql: ${TABLE}."QUARTER" ;;
  }

####### MEASURES #######

  measure: total_ar {
    label: "Total A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_AR" ;;
  }

  measure: rental_ar {
    label: "Rental A/R"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."RENTAL_AR" ;;
  }

  measure: total_revenue {
    label: "Total Revenue"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }

  measure: rental_revenue {
    label: "Rental Revenue"
    type: sum
    value_format_name: usd_0
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }

  measure: total_dso {
    label: "Total DSO"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}."TOTAL_DSO" ;;
  }

  measure: rental_dso {
    label: "Rental DSO"
    type: sum
    value_format_name: decimal_0
    sql: ${TABLE}."RENTAL_DSO" ;;
  }


}
