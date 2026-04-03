view: ar_monthly_outstandings {
  sql_table_name: "PUBLIC"."AR_MONTHLY_OUTSTANDINGS"
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

  dimension: days_current {
    type: number
    sql: ${TABLE}."DAYS_CURRENT" ;;
  }

  dimension: market_id {
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
    type: count
    drill_fields: [market_name]
  }
}
