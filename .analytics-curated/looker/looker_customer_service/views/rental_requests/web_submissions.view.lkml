view: web_submissions {
  derived_table: {
    sql: with quotes_calc as
      (
      select
      distinct
          date(rr.created_at) as request_created_date, rr.order_total, date(quote.created_date) as quote_created_date, qp.total as quote_total, date(quote.order_created_date) as order_created_date, rr.id as rental_request_id, rr.quote_id, quote.order_id, quote.quote_number, quote.contact_email,  quote.company_id, i.invoice_id, i.billed_amount, date(i.date_created) as invoice_date_created, quote.sales_rep_id as salesperson_id, spi.name as salesperson_name
      from
        rental_order_request.public.rental_requests rr
      left join quotes.quotes.quote on quote.id = rr.quote_id
      left join quotes.quotes.quote_pricing qp on qp.quote_id = rr.quote_id
      left join es_warehouse.public.orders o on o.order_id = quotes.quote.order_id
      left join es_warehouse.public.purchase_orders po on o.purchase_order_id = po.purchase_order_id
      left join es_warehouse.public.invoices i on i.order_id = o.order_id
      left join analytics.bi_ops.salesperson_info spi on spi.user_id = quote.sales_rep_id
       where
       -- rr.quote_id is not nulland
      -- rr.quote_id is null and
          quote.contact_email not like '%kickdrumtech.com'
          and quote.contact_email not like '%equipmentshare.com'
          order by order_id
        --order by request_created_date asc, rental_request_id asc
       )
       select
        case when SALESPERSON_ID in (6052, 171481) then 'Amy/Tanner' else 'TAMs' end as rep_group
      , count(distinct rental_request_id) as rental_requests
      , count(distinct quote_id) as quotes
      , count(distinct order_id) as orders
      , count(distinct invoice_id) as invoices
      , quotes / rental_requests
      , orders / quotes
      , sum(billed_amount) as invoice_billed
      , invoice_billed / rental_requests as billed_amt_per_rental_request_avg
      , invoice_billed / quotes as billed_amt_per_quote_avg
      , invoice_billed / orders as billed_amt_per_order_avg

      from
      quotes_calc
      --where SALESPERSON_ID not in (6052, 171481)
      --where SALESPERSON_ID in (6052, 171481)
      GROUP BY rep_group
      --through 10/28/24
      UNION
      select
      'Both Amy/Tanner and TAMs' as rep_group
      , count(distinct rental_request_id) as rental_requests
      , count(distinct quote_id) as quotes
      , count(distinct order_id) as orders
      , count(distinct invoice_id) as invoices
      , quotes / rental_requests
      , orders / quotes
      , sum(billed_amount) as invoice_billed
      , invoice_billed / rental_requests as billed_amt_per_rental_request_avg
      , invoice_billed / quotes as billed_amt_per_quote_avg
      , invoice_billed / orders as billed_amt_per_order_avg

      from
      quotes_calc
      )
      --where SALESPERSON_ID not in (6052, 171481)
      --where SALESPERSON_ID in (6052, 171481)
      --GROUP BY rep_group ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rep_group {
    type: string
    sql: ${TABLE}."REP_GROUP" ;;
  }

  dimension: rental_requests {
    type: number
    sql: ${TABLE}."RENTAL_REQUESTS" ;;
  }

  dimension: quotes {
    type: number
    sql: ${TABLE}."QUOTES" ;;
  }

  dimension: orders {
    type: number
    sql: ${TABLE}."ORDERS" ;;
  }

  dimension: invoices {
    type: number
    sql: ${TABLE}."INVOICES" ;;
  }

  dimension: quotes__rental_requests {
    type: number
    label: "Quote Conversion"
    value_format: "0.00\%"
    sql: ${TABLE}."QUOTES / RENTAL_REQUESTS" * 100;;
  }

  dimension: orders__quotes {
    type: number
    label: "Order Conversation"
    value_format: "0.00\%"
    sql: ${TABLE}."ORDERS / QUOTES" * 100;;
  }

  dimension: invoice_billed {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}."INVOICE_BILLED" ;;
  }

  dimension: billed_amt_per_rental_request_avg {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}."BILLED_AMT_PER_RENTAL_REQUEST_AVG" ;;
  }

  dimension: billed_amt_per_quote_avg {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}."BILLED_AMT_PER_QUOTE_AVG" ;;
  }

  dimension: billed_amt_per_order_avg {
    type: number
    value_format: "$#,##0"
    sql: ${TABLE}."BILLED_AMT_PER_ORDER_AVG" ;;
  }

  set: detail {
    fields: [
      rep_group,
      rental_requests,
      quotes,
      orders,
      invoices,
      quotes__rental_requests,
      orders__quotes,
      invoice_billed,
      billed_amt_per_rental_request_avg,
      billed_amt_per_quote_avg,
      billed_amt_per_order_avg
    ]
  }
}
