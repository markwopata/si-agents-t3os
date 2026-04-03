view: ar_aging_branch_customer {
  sql_table_name: "ANALYTICS"."TREASURY"."AR_AGING_BRANCH_CUSTOMER" ;;

######### DIMENSIONS ###############


  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

######### DATES ###############
  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: month_ {
    type: date
    sql: ${TABLE}."MONTH_" ;;
  }

######### MEASURES ###############

  measure: past_due_outstanding {
    label: "Past Due A/R"
    type: sum
    sql: ${TABLE}."PAST_DUE_OUTSTANDING" ;;
  }

  measure: total_outstanding {
    label: "Total A/R"
    type: sum
    sql: ${TABLE}."TOTAL_OUTSTANDING" ;;
  }

  measure: current_outstanding {
    label: "Current A/R"
    type: sum
    sql: ${TABLE}."CURRENT_OUTSTANDING" ;;
  }

  measure: pd_0_less {
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&0+or+Less=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_0_LESS" ;;
  }

  measure: past_due {
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&All+Past+Due=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PAST_DUE" ;;
  }

  measure: pd_121_plus {
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+121%2B=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_121+" ;;
  }

  measure: pd_1_30 {
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+1-30=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_1_30" ;;
  }

  measure: pd_31_60 {
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+31-60=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_31_60" ;;
  }

  measure: pd_61_90 {
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+61-90=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_61_90" ;;
  }

  measure: pd_91_120 {
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+91-120=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_91_120" ;;
  }

  measure: pd_0_less_amt {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    #html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&0+or+Less=1&Total+A%2FR=%3E0" target="_blank">{{ value | number_to_currency: "USD" }}</a>;;
    sql: ${TABLE}."PD_0_LESS_AMOUNT" ;;
  }

  measure: past_due_amt {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    #html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&All+Past+Due=1&Total+A%2FR=%3E0" target="_blank">{{ value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PAST_DUE_AMOUNT" ;;
  }

  measure: pd_121_plus_amt {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    #html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+121%2B=1&Total+A%2FR=%3E0" target="_blank">{{ value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_121+_AMOUNT" ;;
  }

  measure: pd_1_30_amt {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    #html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+1-30=1&Total+A%2FR=%3E0" target="_blank">{{ value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_1_30_AMOUNT" ;;
  }

  measure: pd_31_60_amt {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    #html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+31-60=1&Total+A%2FR=%3E0" target="_blank">{{ value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_31_60_AMOUNT" ;;
  }

  measure: pd_61_90_amt {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    #html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+61-90=1&Total+A%2FR=%3E0" target="_blank">{{ value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_61_90_AMOUNT" ;;
  }

  measure: pd_91_120_amt {
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    #html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month_._value | url_encode }}&Past+Due+91-120=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_91_120_AMOUNT" ;;
  }

}
