view: int_high_level_financials_trending {
  sql_table_name: "ANALYTICS"."BRANCH_EARNINGS"."INT_HIGH_LEVEL_FINANCIALS_TRENDING" ;;

  dimension: delivery_expense {
    type: number
    sql: ${TABLE}."DELIVERY_EXPENSE" ;;
  }
  dimension: delivery_revenue {
    type: number
    sql: ${TABLE}."DELIVERY_REVENUE" ;;
  }
  dimension_group: gl {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."GL_DATE" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: net_income {
    type: number
    sql: ${TABLE}."NET_INCOME" ;;
  }
  dimension: nonintercompany_delivery_revenue {
    type: number
    sql: ${TABLE}."NONINTERCOMPANY_DELIVERY_REVENUE" ;;
  }
  dimension: outside_hauling_expense {
    type: number
    sql: ${TABLE}."OUTSIDE_HAULING_EXPENSE" ;;
  }
  dimension: payroll_compensation_expense {
    type: number
    sql: ${TABLE}."PAYROLL_COMPENSATION_EXPENSE" ;;
  }
  dimension: payroll_overtime_expense {
    type: number
    sql: ${TABLE}."PAYROLL_OVERTIME_EXPENSE" ;;
  }
  dimension: payroll_wage_expense {
    type: number
    sql: ${TABLE}."PAYROLL_WAGE_EXPENSE" ;;
  }
  dimension: pk_id {
    type: string
    sql: ${TABLE}."PK_ID" ;;
  }
  dimension: rental_revenue {
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }
  dimension: sales_expense {
    type: number
    sql: ${TABLE}."SALES_EXPENSE" ;;
  }
  dimension: sales_revenue {
    type: number
    sql: ${TABLE}."SALES_REVENUE" ;;
  }
  dimension: total_revenue {
    type: number
    sql: ${TABLE}."TOTAL_REVENUE" ;;
  }
  measure: count {
    type: count
  }
  dimension: Market_Access {
    type: yesno
    sql: ${TABLE}."MARKET_ID" in ({{ _user_attributes['market_id'] }}) ;;
  }
}
