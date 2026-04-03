view: walsh_invoice_aging {
 derived_table: {
  sql: select
      c.name as company
      , invoice_date
      , invoice_no
      , po.name as "po/reference"
      , due_date
      , iff(datediff(day,due_date , current_date()) <= 0, 0,datediff(day,due_date , current_date())) as days_overdue
      , iff(datediff(day,invoice_date , current_date()) <= 0, 0,datediff(day,invoice_date , current_date())) as days_since_invoice
      , owed_amount
      , billed_amount
      , i.paid
      --*
      from
      es_warehouse.public.invoices i
      left join es_warehouse.public.purchase_orders po on po.purchase_order_id = i.purchase_order_id
      left join es_warehouse.public.companies c on i.company_id = c.company_id
      where
            i.company_id in (select company_id from analytics.bi_ops.v_parent_company_relationships where parent_company_id =
            (select parent_company_id from analytics.bi_ops.v_parent_company_relationships where company_id = 13089))
            --and i.paid = false
            and sent = true
            ;;
}

measure: count {
  type: count
  drill_fields: [detail*]
}

dimension: company {
  type: string
  sql: ${TABLE}."COMPANY" ;;
}

dimension_group: invoice_date {
  type: time
  sql: ${TABLE}."INVOICE_DATE" ;;
}

dimension: invoice_no {
  type: string
  sql: ${TABLE}."INVOICE_NO" ;;
}

dimension: poreference {
  label: "PO/Reference"
  type: string
  sql: ${TABLE}."po/reference" ;;
}

dimension_group: due_date {
  type: time
  sql: ${TABLE}."DUE_DATE" ;;
}

dimension: days_overdue {
  type: number
  sql: ${TABLE}."DAYS_OVERDUE" ;;
}

dimension: days_since_invoice {
  type: number
  sql: ${TABLE}."DAYS_SINCE_INVOICE" ;;
}

dimension: owed_amount {
  type: number
  sql: ${TABLE}."OWED_AMOUNT" ;;
}

dimension: billed_amount {
  type: number
  sql: ${TABLE}."BILLED_AMOUNT" ;;
}

dimension: paid {
  type: string
  sql: ${TABLE}."PAID" ;;
}

set: detail {
  fields: [
    company,
    invoice_date_time,
    invoice_no,
    poreference,
    due_date_time,
    days_overdue,
    owed_amount,
    billed_amount
  ]
}

measure: total_spend {
  label: "Total Spend"
  type: sum
  value_format_name: usd
  sql:${billed_amount};;
}

measure: full_previous_month_spend {
  label: "Full Previous Month Spend"
  type: sum
  value_format_name: usd
  sql:
  CASE
    WHEN ${invoice_date_date} BETWEEN
      DATE_TRUNC('month', DATEADD(month, -1, CURRENT_DATE))
      AND LAST_DAY(DATEADD(month, -1, CURRENT_DATE))
    THEN ${billed_amount}
  END ;;
}

measure: full_previous_month_last_year_spend {
  label: "Full Previous Month Last Year Spend"
  type: sum
  value_format_name: usd
  sql:
  CASE
    WHEN ${invoice_date_date} BETWEEN
      DATEADD(
        year, -1,
        DATE_TRUNC('month', DATEADD(month, -1, CURRENT_DATE))
      )
      AND DATEADD(
        year, -1,
        LAST_DAY(DATEADD(month, -1, CURRENT_DATE))
      )
    THEN ${billed_amount}
  END ;;
}

measure: full_previous_month_yoy_pct {
  label: "YoY % - Previous Full Month"
  type: number
  value_format_name: percent_2
  sql:
  (
    ${full_previous_month_spend}
    -
    ${full_previous_month_last_year_spend}
  )
  /
  NULLIF(${full_previous_month_last_year_spend}, 0)
;;
}


measure: current_year_spend {
  label: "Current Year Spend (YTD)"
  type: sum
  value_format_name: usd
  sql:
  CASE
    WHEN ${invoice_date_date} BETWEEN
      DATE_TRUNC('year', CURRENT_DATE)
      AND CURRENT_DATE
    THEN ${billed_amount}
  END ;;
}

measure: last_year_spend {
  label: "Last Year Spend (YTD Last Year)"
  type: sum
  value_format_name: usd
  sql:
  CASE
    WHEN ${invoice_date_date} BETWEEN
      DATEADD(year, -1, DATE_TRUNC('year', CURRENT_DATE))
      AND DATEADD(year, -1, CURRENT_DATE)
    THEN ${billed_amount}
  END ;;
}

measure: last_year_total_spend {
  label: "Last Year Total Spend"
  type: sum
  value_format_name: usd
  sql:
  CASE
    WHEN ${invoice_date_date} BETWEEN
      DATE_TRUNC('year', DATEADD(year, -1, CURRENT_DATE))
      AND LAST_DAY(DATE_TRUNC('year', DATEADD(year, -1, CURRENT_DATE)) + INTERVAL '11 MONTH')
    THEN ${billed_amount}
  END ;;
}


}
