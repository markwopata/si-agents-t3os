view: sales_rep_rank_monthly {
  derived_table: {
    sql:
SELECT u.user_id.                                                              AS sales_rep_id,
       CONCAT(u.first_name, ' ', u.last_name)                                  AS sales_rep,
       ANY_VALUE(cd.market_id)                                                 AS home_market_id,
       DATE_TRUNC('month', li.gl_billing_approved_date)                        AS month,
       SUM(li.amount)                                                          AS revenue,
       DENSE_RANK() OVER (PARTITION BY month ORDER BY revenue DESC NULLS LAST) AS monthly_rank

  FROM es_warehouse.public.invoices i
       INNER JOIN es_warehouse.public.approved_invoice_salespersons ais
                  ON i.invoice_id = ais.invoice_id
       INNER JOIN analytics.public.v_line_items li
                  ON i.invoice_id = li.invoice_id
       INNER JOIN es_warehouse.public.users u
                  ON ais.primary_salesperson_id = u.user_id
       INNER JOIN analytics.payroll.company_directory cd
                  ON TRY_TO_NUMBER(u.employee_id) = cd.employee_id


 WHERE li.gl_billing_approved_date >= DATEADD('year', -1, CURRENT_DATE())
   AND li.line_item_type_id IN (6, 8, 108, 109)
   AND sales_rep NOT ILIKE '% Sales%'

 GROUP BY sales_rep_id, sales_rep, month;;
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

  dimension: home_market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."HOME_MARKET_ID" ;;
  }

  dimension: month {
    type: date
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: revenue {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: monthly_rank {
    type: number
    sql: ${TABLE}."MONTHLY_RANK" ;;
  }

  measure: total_revenue {
    type: sum
    sql: ${revenue} ;;
  }
}
