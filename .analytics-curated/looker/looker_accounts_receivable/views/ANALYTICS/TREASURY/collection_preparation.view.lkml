view: collection_preparation {
  sql_table_name: ANALYTICS.TREASURY.COLLECTION_PREPARATION ;;

######## DIMENSIONS ########


  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ collection_preparation.customer_id }}" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }


  dimension: remaining_credit_amount {
    value_format_name: usd
    type: number
    sql: ${TABLE}."REMAINING_CREDIT_AMOUNT" ;;
  }

  dimension: pre_over_payments {
    label: "Pre/Overpayments"
    value_format_name: usd
    type: number
    sql: IFNULL(${TABLE}."PRE_OVER_PAYMENTS",0) ;;
  }

  dimension: market_id {
    label: "Market ID"
    value_format_name: id
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: final_collector {
    type: string
    suggest_persist_for: "1 minute"
    sql: ${TABLE}."FINAL_COLLECTOR" ;;
  }

  dimension: region_district {
    type: string
    sql: ${TABLE}."REGION_DISTRICT" ;;
  }

  dimension: dnr {
    label: "DNR"
    type: string
    sql: ${TABLE}."DNR" ;;
  }

  dimension: credit_limit {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."CREDIT_LIMIT" ;;
  }

  dimension: equipment_on_rent {
    type: string
    sql: ${TABLE}."EQUIPMENT_ON_RENT" ;;
  }

  dimension_group: last_payment {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."LAST_PAYMENT_DATE" ;;
  }

  dimension: salesperson_user_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SALESPERSON_USER_ID" ;;
  }

  dimension: tam {
    label: "TAM"
    type: string
    sql: IFNULL(${TABLE}."TAM",'No Salesperson Assigned') ;;
  }

  dimension: assets_on_rent {
    label: "Assets on Rent"
    type:  number
    value_format_name: decimal_0
    sql: ifnull(${TABLE}."ASSETS_ON_RENT",0) ;;
  }

  dimension: most_recent_note {
    type: string
    sql:  ${TABLE}."MOST_RECENT_NOTE" ;;
  }



  ######## MEASURES ########

  measure: current_balance {
    label: "Aging: Current"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."CURRENT_BALANCE" ;;
  }

  measure: last_payment_amount {
    type: average
    value_format_name: usd
    sql: ${TABLE}."LAST_PAYMENT_AMOUNT" ;;
  }

  measure: owed_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."OWED_AMOUNT" ;;
  }

  measure: past_due_01_30_days {
    label: "Aging: 1 - 30"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PAST_DUE_01_30_DAYS" ;;
  }

  measure: past_due_121_180_days {
    label: "Aging: 121 - 180"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PAST_DUE_121_180_DAYS" ;;
  }

  measure: past_due_181_365_days {
    label: "Aging: 181 - 365"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PAST_DUE_181_365_DAYS" ;;
  }

  measure: past_due_31_60_days {
    label: "Aging: 31 - 60"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PAST_DUE_31_60_DAYS" ;;
  }

  measure: past_due_61_90_days {
    label: "Aging: 61 - 90"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PAST_DUE_61_90_DAYS" ;;
  }

  measure: past_due_91_120_days {
    label: "Aging: 91 - 120"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PAST_DUE_91_120_DAYS" ;;
  }

  measure: past_due_over_365_days {
    label: "Aging: 365+"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."PAST_DUE_OVER_365_DAYS" ;;
  }

  measure: total_past_due {
    label: "Total Past Due"
    type: sum
    value_format_name: usd
    sql: ${TABLE}."TOTAL_PAST_DUE" ;;
  }

measure: percent_over_credit_limit  {
  type: number
  value_format_name: percent_1
  sql: iff((${credit_limit} is null) or (${credit_limit} = 0),1,${owed_amount} / ${credit_limit});;
}


}
