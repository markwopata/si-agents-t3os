view: ap_review_forecast {
  derived_table: {
    sql:
    select account, account_name,'2025-04-01' as forecast_month,sum(ifnull(_2025_04_01,0)) + sum(ifnull(_2025_05_01,0)) + sum(ifnull(_2025_06_01,0)) as forecast_amount
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
    sql: ${account_number} || '-' || ${forecast_month} ;;
  }

  ##### MEASURES #####

  measure: forecast_amount {
    label: "ES Model Quarterly Plan"
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}.FORECAST_AMOUNT;;
  }

  }
