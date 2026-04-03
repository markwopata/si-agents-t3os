view: contract_scoring_invoice_level {
  sql_table_name: RATE_ACHIEVEMENT.CONTRACT_SCORING_INVOICE_LEVEL ;;
#Moves derived table to snowflake
 dimension: line_item_id {
  type: string
  primary_key: yes
  # hidden: yes
  sql: ${TABLE}.LINE_ITEM_ID  ;;
}

dimension: parent_company_name {
  type: string
  sql: ${TABLE}.PARENT_COMPANY_NAME_NA ;;
}

dimension: company_name {
  type: string
  sql: ${TABLE}.COMPANY_NAME ;;
}


dimension: equipment_class_id {
  type: string
  sql: ${TABLE}.EQUIPMENT_CLASS_ID ;;
}


dimension: invoice_number {
  type: string
  sql: ${TABLE}.INVOICE_NUMBER ;;
}

dimension: invoice_id {
  type: string
  sql: ${TABLE}.INVOICE_ID ;;
}

dimension: equipment_class_name {
  type: string
  sql: ${TABLE}.EQUIPMENT_CLASS_NAME ;;
}
dimension: type {
  type: string
  sql: ${TABLE}.TYPE ;;
}

dimension: monthly_rate {
  type: string
  sql: ${TABLE}.MONTHLY_RATE ;;
}

# dimension: invoice_year {
#   type: string
#   sql: ${TABLE}."INVOICE_YEAR" ;;
# }

# dimension: invoice_quarter {
#   type: string
#   sql: ${TABLE}."INVOICE_QUARTER" ;;
# }


dimension: commission_amount {
  type: string
  sql: ${TABLE}.MONTHLY_COMMISSION_AMOUNT ;;
}

dimension: rebate_pct {
  type: string
  sql: ${TABLE}.REBATE_PCT ;;
}

dimension: rebate_amount {
  type: string
  sql: ${TABLE}.MONTHLY_REBATE_AMOUNT ;;
}

dimension: monthly_amort {
  type: string
  sql: ${TABLE}.MONTHLY_AMORT ;;
}


dimension: monthly_service_costs {
  type: string
  sql: ${TABLE}.MONTHLY_SERVICE_COSTS ;;
}

dimension_group: invoice {
  type: time
  timeframes: [
    date,
    month,
    quarter,
    year
  ]
  sql: CAST(${TABLE}.INVOICE_DATE AS TIMESTAMP_NTZ) ;;
}


dimension: shift_type_id {
  type: string
  sql: ${TABLE}.SHIFT_TYPE_ID ;;
}

dimension: breakeven_rate {
  type: string
  value_format: "$#,##0"
  sql: ${TABLE}.BREAKEVEN_RATE ;;
}

dimension: rental_revenue{
  type: number
  value_format_name: usd
  value_format: "$#,##0"
  sql: ${TABLE}.RENTAL_REVENUE ;;
}


dimension: gross_profit_margin{
  type:  number
  value_format_name: usd
  value_format: "$#,##0"
  sql:  ${TABLE}.GROSS_PROFIT_MARGIN ;;
}

dimension: gross_profit_margin_pct{
  type:  number
  value_format: "0.00%"
  sql:  ${TABLE}.GROSS_PROFIT_MARGIN_PCT ;;
}

measure: monthly_rate_avg {
  type: average
  value_format_name: usd
  value_format: "$#,##0"
  sql: ${TABLE}.MONTHLY_RATE ;;
}

measure: breakeven_rate_sum {
  type:  sum
  value_format_name: usd
  value_format: "$#,##0"
  sql: ${TABLE}.BREAKEVEN_RATE ;;
}


measure: rental_revenue_sum {
  type:  sum
  value_format_name: usd
  value_format: "$#,##0"
  sql:  ${TABLE}.RENTAL_REVENUE ;;
  # link: {
  #   label: "Additional Details"
  #   url: "{{ drill_fields_invoice._link}}"
  # }
}



measure: gross_profit_margin_pct_sum {
  type: number
  sql: CASE
          WHEN ${rental_revenue_sum} != 0 THEN ${gross_profit_margin_sum} / ${rental_revenue_sum}
          ELSE 0
        END ;;
  value_format: "0.00%" # Formats the result as a percentage
}


measure:  drill_fields_invoice {
  hidden:  yes
  type:  sum
  sql:  0;;
  drill_fields:
  [contract_scoring_invoice_level.parent_company_name_na, contract_scoring_invoice_level.company_name, contract_scoring_invoice_level.equipment_class_name, contract_scoring_invoice_level.line_item_id,contract_scoring_invoice_level.invoice_date, contract_scoring_invoice_level.shift_type_id, contract_scoring_invoice_level.monthly_service_costs,contract_scoring_invoice_level.monthly_amort, contract_scoring_invoice_level.commission_amount, contract_scoring_invoice_level.rebate_amount, contract_scoring_invoice_level.breakeven_rate, contract_scoring_invoice_level.rental_revenue, contract_scoring_invoice_level.gross_profit_margin, contract_scoring_invoice_level.gross_profit_margin_pct]
#contract_scoring_invoice_level.invoice_number,
}




measure: gross_profit_margin_sum{
  type:  sum
  value_format_name: usd
  value_format: "$#,##0"
  sql:  ${TABLE}.GROSS_PROFIT_MARGIN ;;
  link: {
    label: "Additional Details"
    url: "{{ drill_fields_invoice._link}}"
  }
}



}
