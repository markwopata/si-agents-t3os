view: sales_rep_rank_by_market {
  derived_table: {
    sql:
SELECT u.user_id                                                                                                                              AS sales_rep_id,
       CONCAT(u.first_name, ' ', u.last_name)                                                                                                  AS sales_rep,
       m.name                                                                                                                                  AS market_name,
       m.market_id,
       SUM(IFF(DATE_TRUNC('month', li.gl_billing_approved_date) = DATEADD('month', -1, DATE_TRUNC('month', CURRENT_DATE())), li.amount, NULL)) AS last_month_revenue,
       DENSE_RANK() OVER (PARTITION BY market_name ORDER BY last_month_revenue DESC NULLS LAST)                                                AS previous_rank_in_market,
       SUM(IFF(DATE_TRUNC('month', li.gl_billing_approved_date) = DATE_TRUNC('month', CURRENT_DATE()), li.amount, NULL))                       AS this_month_revenue,
       DENSE_RANK() OVER (PARTITION BY market_name ORDER BY this_month_revenue DESC NULLS LAST)                                                AS current_rank_in_market

  FROM es_warehouse.public.invoices i
       INNER JOIN es_warehouse.public.approved_invoice_salespersons ais
                  ON i.invoice_id = ais.invoice_id
       INNER JOIN analytics.public.v_line_items li
                  ON i.invoice_id = li.invoice_id
       INNER JOIN es_warehouse.public.markets m
                  ON li.branch_id = m.market_id
       INNER JOIN es_warehouse.public.users u
                  ON ais.primary_salesperson_id = u.user_id

 WHERE li.gl_billing_approved_date >= DATEADD('month', -2, CURRENT_DATE())
   AND li.line_item_type_id IN (6, 8, 108, 109)
   AND sales_rep NOT ILIKE '% Sales%'

 GROUP BY sales_rep_id, sales_rep, market_name, market_id
;;
  }

  dimension: sales_rep_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."SALES_REP_ID" ;;
  }

  dimension: sales_rep {
    type: string
    sql: ${TABLE}."SALES_REP" ;;
  }

  dimension: sales_rep_with_id {
    type: string
    sql: CONCAT(${sales_rep}, ' - ', ${sales_rep_id}) ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: last_month_revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."LAST_MONTH_REVENUE" ;;
  }

  dimension: this_month_revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."THIS_MONTH_REVENUE" ;;
  }

  dimension: previous_rank_in_market {
    type: number
    sql: ${TABLE}."PREVIOUS_RANK_IN_MARKET" ;;
  }

  dimension: current_rank_in_market {
    type: number
    sql: ${TABLE}."CURRENT_RANK_IN_MARKET" ;;
  }
}
