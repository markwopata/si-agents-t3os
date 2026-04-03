view: branch_earnings_budgets {
  sql_table_name: "ANALYTICS"."PUBLIC"."BRANCH_EARNINGS_BUDGETS"
    ;;

  dimension: acctno {
    type: string
    sql: ${TABLE}."ACCTNO" ;;
  }

  dimension: budget_amount {
    type: number
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${TABLE}."BUDGET_AMOUNT" ;;
  }

  dimension: budget_date {
    type: date
    convert_tz: no
    sql: ${TABLE}."BUDGET_DATE" ;;
  }

  dimension: budget_id {
    type: string
    sql: ${TABLE}."BUDGET_ID" ;;
  }

  dimension: entity {
    type: string
    sql: ${TABLE}."ENTITY" ;;
  }

  dimension: market_id {
    type: number
    sql: iff(${TABLE}."MARKET_ID"='15967', '33163', ${TABLE}."MARKET_ID") ;;
  }

  dimension: record_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RECORD_ID" ;;
  }

  dimension_group: updated {
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
    sql: ${TABLE}."UPDATED" ;;
  }

  dimension: version {
    type: string
    sql: ${TABLE}."VERSION" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: sum {
    label: "Budget"
    type: sum
    value_format: "#,##0.00;(#,##0.00);-"
    sql: ${budget_amount} ;;
  }
}
