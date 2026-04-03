view: cip_budget_amounts {
 sql_table_name: "ANALYTICS"."RETOOL"."CIP_BUDGET_AMOUNTS" ;;

dimension: pk {
  type: string
  primary_key: yes
  sql: ${TABLE}.pk ;;
}

dimension: market_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.market_id ;;
}

dimension: division_code {
  type: string
  sql: ${TABLE}.division_code ;;
}

dimension: budget_amount {
  type: number
  sql: ${TABLE}.budget_amount ;;
}

measure: budget_amount_sum {
  label: "Budget Amount"
  type: sum
  value_format: "$#,##0.00;($#,##0.00)"
  sql: coalesce(${budget_amount},0) ;;
}

dimension: budget_revision {
  type: number
  sql: ${TABLE}.budget_revision ;;
}

  measure: budget_revision_sum {
    label: "Budget Revision"
    type: sum
    value_format: "$#,##0.00;($#,##0.00)"
    sql: coalesce(${budget_revision},0) ;;
  }

dimension_group: date_created {
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
  sql: ${TABLE}.date_created ;;
}

dimension_group: date_updated {
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
  sql: ${TABLE}.date_updated ;;
}

}
