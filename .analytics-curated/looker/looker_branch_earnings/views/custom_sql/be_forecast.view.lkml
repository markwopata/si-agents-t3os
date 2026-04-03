view: be_forecast {
  derived_table: {
    sql:
      select fj.*, pp.DISPLAY
from analytics.pd_dbt.BE_FORECAST_JAN_25 fj
left join analytics.gs.PLEXI_PERIODS pp
on fj.month = pp.TRUNC
where FA_FLAG = 'F'


      ;;
  } dimension: region {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION" ;;
  }


  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_type {
    label: "Market Type"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  dimension: account_number {
    label: "Account Number"
    type: string
    sql: ${TABLE}."ACCOUNT_NUMBER" ;;
  }
  dimension: account_name {
    label: "Account Name"
    type: string
    sql: ${TABLE}."ACCOUNT_NAME" ;;
  }
  dimension: category {
    label: "Type"
    type: string
    sql: ${TABLE}."CATEGORY" ;;
  }
  dimension: month {
    label: "Month"
    type: date_month
    sql: ${TABLE}."MONTH" ;;
  }
  measure: amount {
    label: "Amount"
    type: sum
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: period {
    label: "Period"
    type: date_month_name
    sql: ${TABLE}."DISPLAY" ;;
  }

  }
