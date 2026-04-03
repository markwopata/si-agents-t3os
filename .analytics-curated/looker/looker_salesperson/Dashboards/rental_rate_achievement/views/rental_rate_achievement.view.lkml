view: rental_rate_achievement {
  sql_table_name: "RATE_ACHIEVEMENT"."RENTAL_RATE_ACHIEVEMENT_LOOKER" ;;

  dimension: advertised_rates {
    type: string
    sql: ${TABLE}."ADVERTISED_RATES" ;;
  }
  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
    value_format: "$#,##0.00"     # Dollars with comma btwn thousands and 2 decimals ($1,234.00)
  }
  measure: rental_revenue {
    type: number
    sql: SUM(${TABLE}."AMOUNT") ;;
    value_format: "$#,##0"     # Dollars with comma btwn thousands and 2 decimals ($1,234.00)
  }
  dimension: avg_oec_clean {
    type: number
    sql: ${TABLE}."AVG_OEC_CLEAN" ;;
    value_format: "$#,##0"     # Dollars with comma btwn thousands and 2 decimals ($1,234.00)
  }
  dimension: benchmark_rates {
    type: string
    sql: ${TABLE}."BENCHMARK_RATES" ;;
  }
  dimension_group: billing_approved {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }
  dimension: book_rate {
    type: number
    sql: ${TABLE}."BOOK_RATE" ;;
    value_format: "$#,##0"     # Dollars with comma btwn thousands and 2 decimals ($1,234.00)
  }
  dimension: book_rates {
    type: string
    sql: ${TABLE}."BOOK_RATES" ;;
  }
  dimension: business_segment {
    type: string
    sql: ${TABLE}."BUSINESS_SEGMENT" ;;
  }
  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }
  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }
  dimension: floor_rates {
    type: string
    sql: ${TABLE}."FLOOR_RATES" ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }
  dimension: line_item_id {
    type: number
    sql: ${TABLE}."LINE_ITEM_ID" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }
  dimension: percent_discount {
    type: number
    sql: ${TABLE}."PERCENT_DISCOUNT" ;;
    value_format: "0%"         # Convert to percent with 2 decimals (.01 becomes 1.00%)
  }
  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }
  dimension: rouse_monthly_rates {
    type: string
    sql: ${TABLE}."ROUSE_MONTHLY_RATES" ;;
  }

  measure: average_percent_discount {
    type: number
    sql: AVG(${TABLE}."PERCENT_DISCOUNT") ;;
    value_format: "0%"         # Convert to percent with 2 decimals (.01 becomes 1.00%)
  }
  measure: count {
    type: count
    drill_fields: [equipment_class_name]
  }
}
