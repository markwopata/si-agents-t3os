view: commissions {
  sql_table_name: "ANALYTICS"."COMMISSION_CLAWBACKS"."COMMISSIONS"
    ;;

  dimension_group: action {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."ACTION_DATE" ;;
  }

  dimension: amount {
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: billing_approved_date {
    type: string
    sql: ${TABLE}."BILLING_APPROVED_DATE" ;;
  }

  dimension: branch_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: commission_line_item {
    type: yesno
    sql: ${TABLE}."COMMISSION_LINE_ITEM" ;;
  }

  dimension: commission_percentage {
    type: number
    sql: ${TABLE}."COMMISSION_PERCENTAGE" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: salesperson_compensation {
    type: string
    sql: ${TABLE}."SALESPERSON_COMPENSATION" ;;
  }

  dimension: salesperson_type {
    type: number
    sql: ${TABLE}."SALESPERSON_TYPE" ;;
  }

  dimension: split {
    type: number
    sql: ${TABLE}."SPLIT" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: amount_paid {
    type: number
    value_format_name: usd
    sql: ${amount}*${split}*${commission_percentage} ;;
  }

  measure: revenue_amount {
    type: sum
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }

  measure: total_amount {
    type: sum
    value_format_name: usd
    sql: ${amount_paid} ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
