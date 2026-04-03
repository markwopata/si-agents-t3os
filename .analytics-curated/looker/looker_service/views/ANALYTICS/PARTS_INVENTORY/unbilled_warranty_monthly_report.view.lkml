view: unbilled_warranty_monthly_report {
  sql_table_name: "ANALYTICS"."PARTS_INVENTORY"."UNBILLED_WARRANTY_MONTHLY_REPORT" ;;

  dimension: accrual_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."ACCRUAL_AMOUNT" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension_group: date_completed {
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: labor_accrual_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."LABOR_ACCRUAL_AMOUNT" ;;
  }
  dimension: make {
    type: string
    sql: ${TABLE}."MAKE" ;;
  }
  dimension: multiplier {
    type: number
    value_format_name: percent_3
    sql: ${TABLE}."MULTIPLIER" ;;
  }
  dimension: parts_accrual_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PARTS_ACCRUAL_AMOUNT" ;;
  }
  dimension: parts_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}."PARTS_COST" ;;
  }
  dimension: total_time {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}."TOTAL_TIME" ;;
  }
  dimension: warranty_labor_rate {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."WARRANTY_LABOR_RATE" ;;
  }
  dimension: warranty_labor_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}."WARRANTY_LABOR_VALUE" ;;
  }
  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  measure: count {
    type: count
  }
}
