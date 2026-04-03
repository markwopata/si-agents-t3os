view: ar_metrics_detail {
  sql_table_name: "ANALYTICS"."TREASURY"."AR_METRICS_DETAIL" ;;

  ############### DIMENSIONS ###############
  dimension: branch_id {
    type: string
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: branch_name {
    type: string
    sql: ${TABLE}."BRANCH_NAME" ;;
  }

  dimension: collector {
    type: string
    sql: ${TABLE}."COLLECTOR" ;;
  }

  dimension: customer_id {
    type: string
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: email_address {
    label: "Collector Email"
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
  }

  dimension: legal_flag {
    type: string
    sql: iff(${TABLE}."LEGAL_FLAG" = 1,'Yes','No') ;;
  }

  dimension: age {
    type: number
    sql: ${TABLE}."AGE" ;;
  }

############### LINKS ###############

  dimension: invoice_no {
    type: string
    html: {% if value == null %}&nbsp;
    {% else %}
    <font color="blue "><u><a href = "https://admin.equipmentshare.com/#/home/transactions/invoices/search?query={{ value }}" target="_blank">{{ value }}</a></u></font>
    {% endif %};;
    sql: ${TABLE}."INVOICE_NO" ;;
  }



  ############### DATES ###############
  dimension: due_date {
    type: date
    sql: ${TABLE}."DUE_DATE" ;;
  }

  dimension: eom_billing_approved_date {
    label: "EOM Billing Approved Date"
    type: date
    sql: ${TABLE}."EOM_BILLING_APPROVED_DATE" ;;
  }

  dimension: eom_paid_date {
    label: "EOM Paid Date"
    type: date
    sql: ${TABLE}."EOM_PAID_DATE" ;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}."MONTH_" ;;
  }

  dimension: returned_from_legal_month {
    type: date
    sql: ${TABLE}."RETURNED_FROM_LEGAL_MONTH" ;;
  }

  dimension: sent_to_legal_month {
    type: date
    sql: ${TABLE}."SENT_TO_LEGAL_MONTH" ;;
  }

  ############### AGING ###############
  dimension: pd_0_less {
    type: number
    sql: ${TABLE}."PD_0_LESS" ;;
  }

  dimension: past_due {
    type: number
    sql: ${TABLE}."PAST_DUE" ;;
  }

  dimension: pd_121_plus {
    type: number
    sql: ${TABLE}."PD_121+" ;;
  }

  dimension: pd_1_30 {
    type: number
    sql: ${TABLE}."PD_1_30" ;;
  }

  dimension: pd_31_60 {
    type: number
    sql: ${TABLE}."PD_31_60" ;;
  }

  dimension: pd_61_90 {
    type: number
    sql: ${TABLE}."PD_61_90" ;;
  }

  dimension: pd_91_120 {
    type: number
    sql: ${TABLE}."PD_91_120" ;;
  }


  ############### MEASURES ###############
  measure: current_ar {
    label: "Current A/R"
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."CURRENT_AR" ;;
  }

  measure: mtd_revenue {
    label: "MTD Revenue"
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."MTD_REVENUE" ;;
  }

  measure: past_due_ar {
    label: "Past Due A/R"
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."PAST_DUE_AR" ;;
  }

  measure: past_due_ar_legal {
    label: "Past Due A/R Legal"
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."PAST_DUE_AR_LEGAL" ;;
  }

  measure: past_due_ar_non_legal {
    label: "Past Due A/R Non Legal"
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."PAST_DUE_AR_NON_LEGAL" ;;
  }

  measure: total_ar {
    label: "Total A/R"
    type: sum
    value_format: "$#,##0.#0;($#,##0.#0);-"
    sql: ${TABLE}."TOTAL_AR" ;;
  }


  measure: pd_0_less_m {
    label: "0 or Less"
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&0+or+Less=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_0_LESS" ;;
  }

  measure: past_due_m {
    label: "Total Past Due"
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&All+Past+Due=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PAST_DUE" ;;
  }

  measure: pd_121_plus_m {
    label: "Past Due 121+"
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+121%2B=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_121+" ;;
  }

  measure: pd_1_30_m {
    label: "Past Due 1 - 30"
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+1-30=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_1_30" ;;
  }

  measure: pd_31_60_m {
    label: "Past Due 31 - 60"
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+31-60=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_31_60" ;;
  }

  measure: pd_61_90_m {
    label: "Past Due 61 - 90"
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+61-90=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_61_90" ;;
  }

  measure: pd_91_120_m {
    label: "Past Due 91 - 120"
    type: sum
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+91-120=1&Total+A%2FR=%3E0" target="_blank">{{ value }}</a></font>;;
    sql: ${TABLE}."PD_91_120" ;;
  }

  measure: pd_0_less_amt {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&0+or+Less=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a>;;
    sql: ${TABLE}."PD_0_LESS_AMOUNT" ;;
  }

  measure: past_due_amt {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&All+Past+Due=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PAST_DUE_AMOUNT" ;;
  }

  measure: pd_121_plus_amt {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+121%2B=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_121+_AMOUNT" ;;
  }

  measure: pd_1_30_amt {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+1-30=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_1_30_AMOUNT" ;;
  }

  measure: pd_31_60_amt {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+31-60=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_31_60_AMOUNT" ;;
  }

  measure: pd_61_90_amt {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+61-90=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_61_90_AMOUNT" ;;
  }

  measure: pd_91_120_amt {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+91-120=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value }}</a></font>;;
    sql: ${TABLE}."PD_91_120_AMOUNT" ;;
  }

  measure: pd_0_less_amt_branch {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&0+or+Less=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a>;;
    sql: ${TABLE}."PD_0_LESS_AMOUNT" ;;
  }

  measure: past_due_amt_branch {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&All+Past+Due=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PAST_DUE_AMOUNT" ;;
  }

  measure: pd_121_plus_amt_branch {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+121%2B=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_121+_AMOUNT" ;;
  }

  measure: pd_1_30_amt_branch {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+1-30=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_1_30_AMOUNT" ;;
  }

  measure: pd_31_60_amt_branch {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+31-60=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_31_60_AMOUNT" ;;
  }

  measure: pd_61_90_amt_branch {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+61-90=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_61_90_AMOUNT" ;;
  }

  measure: pd_91_120_amt_branch {
    type: sum
    value_format_name: usd
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Branch%20ID={{ branch_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+91-120=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value }}</a></font>;;
    sql: ${TABLE}."PD_91_120_AMOUNT" ;;
  }

  measure: pd_0_less_amt_customer {
    type: sum
    value_format_name: usd_0
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Customer%20ID={{ customer_id._value | url_encode }}&Month={{ month._value | url_encode }}&0+or+Less=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a>;;
    sql: ${TABLE}."PD_0_LESS_AMOUNT" ;;
  }

  measure: past_due_amt_customer {
    type: sum
    value_format_name: usd_0
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Customer%20ID={{ customer_id._value | url_encode }}&Month={{ month._value | url_encode }}&All+Past+Due=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PAST_DUE_AMOUNT" ;;
  }

  measure: pd_121_plus_amt_customer {
    type: sum
    value_format_name: usd_0
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Customer%20ID={{ customer_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+121%2B=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_121+_AMOUNT" ;;
  }

  measure: pd_1_30_amt_customer {
    type: sum
    value_format_name: usd_0
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Customer%20ID={{ customer_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+1-30=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_1_30_AMOUNT" ;;
  }

  measure: pd_31_60_amt_customer {
    type: sum
    value_format_name: usd_0
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Customer%20ID={{ customer_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+31-60=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_31_60_AMOUNT" ;;
  }

  measure: pd_61_90_amt_customer {
    type: sum
    value_format_name: usd_0
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Customer%20ID={{ customer_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+61-90=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value | number_to_currency: "USD" }}</a></font>;;
    sql: ${TABLE}."PD_61_90_AMOUNT" ;;
  }

  measure: pd_91_120_amt_customer {
    type: sum
    value_format_name: usd_0
    html: <a href = "https://equipmentshare.looker.com/dashboards/988?Customer%20ID={{ customer_id._value | url_encode }}&Month={{ month._value | url_encode }}&Past+Due+91-120=1&Total+A%2FR=%3E0" target="_blank">{{ rendered_value }}</a></font>;;
    sql: ${TABLE}."PD_91_120_AMOUNT" ;;
  }



}
