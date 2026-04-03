view: ap_review_forecast {
  derived_table: {
    sql:
    select account, account_name,'2026-01-01' as forecast_month,sum(ifnull(_2026_01_01,0)) + sum(ifnull(_2026_02_01,0)) + sum(ifnull(_2026_03_01,0)) as forecast_amount
    from analytics.treasury.ap_review_forecast
    group by all
    ;;
  }

  ##### DIMENSIONS #####

  dimension: account_number {
    type: string
    sql: ${TABLE}.ACCOUNT ;;
  }

  dimension: account_name {
    type: string
    sql: ${TABLE}.ACCOUNT_NAME ;;
  }

  dimension: forecast_month {
    type: date
    sql: ${TABLE}.FORECAST_MONTH;;
  }

  dimension: key {
    type: string
    primary_key: yes
    sql: ${account_number};;
  }

  dimension: account_type {
    type: string
    sql: iff(${TABLE}.FORECAST_AMOUNT is null,'Non-Forecast','Forecast') ;;
  }

  ##### MEASURES #####

  measure: forecast_amount {
    label: "ES Model Quarterly Plan"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}.FORECAST_AMOUNT;;
  }

  measure: forecast_actuals {
    type: number
    sql: case
         when ${forecast_amount} = 0 then null
        when ${forecast_amount} is null then null
        else ${ap_payments_no_filter.qtd} end  ;;
  }

  measure: forecast_pacing {
    type: number
    sql: case
         when ${forecast_amount} = 0 then null
        when ${forecast_amount} is null then null
        else ${ap_payments_no_filter.run_rate_qtr} end  ;;
  }

  measure: pct_to_plan_usage {
    label: "% to Plan Usage"
    value_format_name: percent_1
    type: number
    sql:  ${forecast_actuals} / ${forecast_amount}  ;;
  }

  measure: pct_to_plan_pacing {
    label: "% to Plan Pacing"
    value_format_name: percent_1
    type: number
    sql:  ${forecast_pacing} / ${forecast_amount}  ;;
  }

}
