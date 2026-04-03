view: ar_monthly_past_due {
  sql_table_name: "PUBLIC"."AR_MONTHLY_PAST_DUE"
    ;;

  dimension: days_1_30 {
    type: number
    sql: ${TABLE}."DAYS_1_30" ;;
  }

  dimension: days_31_60 {
    type: number
    sql: ${TABLE}."DAYS_31_60" ;;
  }

  dimension: days_61_90 {
    type: number
    sql: ${TABLE}."DAYS_61_90" ;;
  }

  dimension: days_91_120 {
    type: number
    sql: ${TABLE}."DAYS_91_120" ;;
  }

  dimension: market_id {
    # primary_key: yes
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: month_ {
    type: string
    sql: ${TABLE}."MONTH_" ;;
  }

  dimension: over_120_days {
    type: number
    sql: ${TABLE}."OVER_120_DAYS" ;;
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [market_name]
  }

  measure: 1_30_Days {
    type: sum
    sql: ${days_1_30} ;;
    value_format_name: usd
  }

  measure: 31_60_Days {
    type: sum
    sql: ${days_31_60} ;;
    value_format_name: usd
  }

  measure: 61_90_Days {
    type: sum
    sql: ${days_61_90} ;;
    value_format_name: usd
  }

  measure: 91_120_Days {
    type: sum
    sql: ${days_91_120} ;;
    value_format_name: usd
  }

  measure: 120_days_plus {
    type: sum
    sql: ${over_120_days} ;;
    value_format_name: usd
  }

  measure: Past_due_total {
    type: sum
    sql: ${days_1_30}+${31_60_Days}+${days_61_90}+${days_91_120}+${over_120_days} ;;
    value_format_name: usd
  }
}
