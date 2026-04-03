view: ap_review_dashboard_actuals {
  sql_table_name: "ANALYTICS"."TREASURY"."AP_REVIEW_DASHBOARD_ACTUALS" ;;

##### DIMENSIONS #####

  dimension: account_name {
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }

  dimension: account_number {
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }

  dimension: account_v2 {
    type: string
    sql: ${TABLE}."ACCOUNT_V2" ;;
  }

  dimension: entry_month {
    type: date
    sql: ${TABLE}."ENTRY_MONTH" ;;
  }

  dimension: key {
    type: string
    primary_key: yes
    sql: ${account_number} || '-' || ${entry_month} ;;
  }

  dimension: ytd_days {
    type: number
    sql: datediff(day,'2024-12-31',current_date) ;;
  }

  dimension: qtd_days {
    type: number
    sql: datediff(day,'2025-03-31',current_date) ;;
  }

##### MEAUSURES #####

  measure: actuals {
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."ACTUALS" ;;
  }

  measure: mtd_spend {
    label: "MTD Spend"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."ACTUALS" ;;
    filters: [entry_month: "this month"]
  }

  measure: prior_month_spend {
    label: "Prior Month Spend"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."ACTUALS" ;;
    filters: [entry_month: "last month"]
  }

  measure: qtd_spend {
    label: "QTD Spend"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."ACTUALS" ;;
    filters: [entry_month: "this quarter"]
  }

  measure: ytd_spend {
    label: "2025 YTD Spend"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."ACTUALS" ;;
    filters: [entry_month: "this year"]
  }

  measure: prior_year_spend {
    label: "2024 Spend"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."ACTUALS" ;;
    filters: [entry_month: "last year"]
  }

  measure: qtr_run_rate {
    label: "Q2'25 Run Rate"
    value_format_name: usd_0
    type: number
    sql: (${qtd_spend}/datediff(day,'2025-03-31',current_date))*90 ;;
  }

  measure: annual_run_rate {
    label: "2025 Run Rate"
    value_format_name: usd_0
    type: number
    sql: (${ytd_spend}/datediff(day,'2024-12-31',current_date))*365 ;;
  }

  measure: pct_to_plan_usage  {
    label: "% to Plan Usage"
    value_format_name: percent_1
    type: number
    sql: case when ${ap_review_forecast.forecast_amount} = 0 then null else ${qtd_spend} / ${ap_review_forecast.forecast_amount} end  ;;
  }


  measure: pct_to_plan_pacing  {
    label: "% to Plan Pacing"
    value_format_name: percent_1
    type: number
    sql:  case when ${ap_review_forecast.forecast_amount} = 0 then null else ${qtr_run_rate} / ${ap_review_forecast.forecast_amount} end ;;
}

}
