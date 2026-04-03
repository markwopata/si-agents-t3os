view: company_revenue {
derived_table: {
  sql:
    WITH date_series AS (SELECT series AS date
                         FROM TABLE (es_warehouse.public.generate_series('2020-01-01'::timestamp_tz,
                                                                         CURRENT_DATE()::timestamp_tz, 'month'))),
       revenue     AS (SELECT DATE_TRUNC('month', li.date_created) AS date,
                              i.company_id,
                              li.line_item_type_id,
                              SUM(li.amount)                       AS amount
                         FROM es_warehouse.public.line_items li
                              INNER JOIN es_warehouse.public.invoices i
                                         ON li.invoice_id = i.invoice_id
                        GROUP BY date, i.company_id, li.line_item_type_id)


SELECT date.date,
       company_id,
       line_item_type_id,
       IFF(line_item_type_id IN (30, 31, 32, 33, 34) AND date.date >= DATEADD('day', -60, CURRENT_DATE()), True, False) as active_t3_rev,
       amount

  FROM date_series date
       LEFT JOIN revenue r
                 ON date.date = r.date

 ORDER BY date.date DESC
  ;;
}

dimension: pkey {
  primary_key: yes
  type: string
  sql: CONCAT(${date_month}, ' - ', ${company_id}, ' - ', ${line_item_type_id}) ;;
}

dimension_group: date {
  type: time
  timeframes: [month]
  sql: ${TABLE}."DATE" ;;
}

dimension: company_id {
  type: number
  sql: ${TABLE}."COMPANY_ID" ;;
}

# dimension: market_id {
#   type: number
#   sql: ${TABLE}."BRANCH_ID" ;;
# }

dimension: line_item_type_id {
  type: number
  sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
}

dimension: active_t3_revenue {
  type: yesno
  sql: ${TABLE}."ACTIVE_T3_REV" ;;
}

dimension: amount {
  type: number
  sql: ${TABLE}."AMOUNT" ;;
}


# - - - - - MEASURES - - - - -

measure: total_amount {
  type: sum
  sql: ${amount} ;;
  drill_fields: [invoices.invoice_no, invoices.date_created_date, line_item_types.name, line_items.amount]
}

measure: t3_revenue {
  type: sum
  sql: ${amount} ;;
  drill_fields: [invoices.invoice_no, invoices.date_created_date, line_item_types.name, line_items.amount]
  filters: [line_item_type_id: "30, 31, 32, 33, 34"]
}

  measure: t3_revenue_60_days{
    type: sum
    sql: ${amount} ;;
    drill_fields: [invoices.invoice_no, invoices.date_created_date, line_item_types.name, line_items.amount]
    filters: [line_item_type_id: "30, 31, 32, 33, 34", date_month: "60 days ago for 60 days"]
  }

  # measure: is_t3_company {
  #   type: yesno
  #   sql: ${t3_revenue_60_days} > 0 ;;
  #   drill_fields: [invoices.invoice_no, invoices.date_created_date, line_item_types.name, line_items.amount]
  # }
}
