view: flex_payout_output {
  sql_table_name: "CONTRACTOR_PAYOUTS"."FLEX_PAYOUT_OUTPUT"
    ;;

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  measure: asset_payout_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."ASSET_PAYOUT_AMOUNT" ;;
  }

  measure: tracker_deduction {
    type: sum
    value_format_name: usd
    sql: 15 ;;
  }

  measure: net_payout {
    type: sum
    value_format_name: usd
    sql: IFNULL(${TABLE}."ASSET_PAYOUT_AMOUNT", 0) - 15 ;;
  }

  measure: revenue {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: asset_payout_percentage {
    type: number
    sql: ${TABLE}."ASSET_PAYOUT_PERCENTAGE" ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension_group: dte {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DTE" ;;
  }

  dimension: invoice_id {
    type: string
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension_group: payout_month {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."PAYOUT_MONTH" ;;
  }

  dimension: payout_month_string {
    type: string
    sql: ${payout_month_month} ;;
  }

  measure: count {
    type: count
    drill_fields: [company_name, market_name]
  }

  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension_group: start_date {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."START_DATE" ;;
  }
}
