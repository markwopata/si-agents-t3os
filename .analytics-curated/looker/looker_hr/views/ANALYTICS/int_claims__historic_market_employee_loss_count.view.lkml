view: int_claims__historic_market_employee_loss_count {
  sql_table_name: "CLAIMS"."INT_CLAIMS__HISTORIC_MARKET_EMPLOYEE_LOSS_COUNT" ;;

  dimension: date_month {
    type: date
    sql: ${TABLE}."DATE_MONTH" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  measure: employee_count {
    type: sum
    sql: ${TABLE}."EMPLOYEE_COUNT" ;;
  }
  measure: ltm_employee_count {
    type: sum
    sql: ${TABLE}."LTM_EMPLOYEE_COUNT" ;;
  }
  measure: ltm_loss_count {
    type: sum
    sql: ${TABLE}."LTM_LOSS_COUNT" ;;
  }

  measure: monthly_loss_count {
    type: sum
    sql: ${TABLE}."MONTHLY_LOSS_COUNT" ;;
  }

  measure: count {
    type: count
    drill_fields: [market_name]
  }
}
