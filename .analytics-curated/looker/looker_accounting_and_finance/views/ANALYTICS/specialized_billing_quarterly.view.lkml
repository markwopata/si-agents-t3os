view: specialized_billing_quarterly {
  sql_table_name: "ANALYTICS"."PL_DBT"."GOLD_SPECIALIZED_BILLING_QUARTERLY" ;;

  dimension: quarter {
    type: string
    sql: case
         when ${TABLE}."QUARTER" = '2025-01-01' then '2025-Q1'
         when ${TABLE}."QUARTER" = '2025-04-01' then '2025-Q2'
         when ${TABLE}."QUARTER" = '2025-07-01' then '2025-Q3'
         when ${TABLE}."QUARTER" = '2025-10-01' then '2025-Q4'
         when ${TABLE}."QUARTER" = '2026-01-01' then '2026-Q1' end

        ;;
  }

  measure: revenue {
    value_format_name: usd_0
    type: sum
    sql: ${TABLE}."REVENUE" ;;
  }

  measure: invoice_count {
    value_format_name: decimal_0
    type: sum
    sql: ${TABLE}."INVOICE_COUNT" ;;
  }

  measure: run_rate_revenue {
    value_format_name: usd_0
    label: "Run Rate Revenue"
    type: number
    sql: iff(${quarter}='2026-Q1',(${revenue} / datediff(day, '2025-12-31',current_date)) * 90,${revenue}) ;;
  }


  measure: run_rate_invoice_count {
    value_format_name: decimal_0
    label: "Run Rate Invoice Count"
    type: number
    sql: iff(${quarter}='2026-Q1',(${invoice_count} / datediff(day, '2025-12-31',current_date)) * 90,${invoice_count}) ;;
  }

}
