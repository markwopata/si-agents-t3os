view: market_first_order {
  derived_table: {
    sql:
-- first order and invoice dates
SELECT orders.market_id
     , orders.market_name
     , orders.order_id
     , orders.order_date
     , orders.invoice_id
     , orders.invoice_no
     , orders.invoice_date
     , assignment.asset_assignment_date
     , LEAST(orders.order_date, orders.invoice_date, assignment.asset_assignment_date) AS earliest_date
  FROM (
       SELECT i.ship_from:branch_id::int AS market_id
            , m.name                     AS market_name
            , o.order_id
            , o.date_created::DATE       AS order_date
            , i.invoice_no
            , i.invoice_id
            , i.date_created::DATE       AS invoice_date
         FROM es_warehouse.public.orders o
              JOIN es_warehouse.public.invoices i
                   ON o.order_id = i.order_id
              JOIN es_warehouse.public.markets m
                   ON i.ship_from:branch_id = m.market_id
              left join es_warehouse.public.users u on u.user_id = o.user_id
              left join es_warehouse.public.companies c on c.company_id = u.company_id
        WHERE m.company_id = 1854
        AND c.company_id <> 1854
      QUALIFY ROW_NUMBER() OVER (PARTITION BY i.ship_from:branch_id ORDER BY o.date_created, i.date_created) = 1
       ) orders
           -- first asset assignment to rental branch
       JOIN (
            SELECT m.market_id
                 , date_start::DATE AS asset_assignment_date
              FROM es_warehouse.scd.scd_asset_rsp scd
                   JOIN analytics.asset_details.asset_physical a
                        ON scd.asset_id = a.asset_id
                   JOIN es_warehouse.public.markets m
                        ON scd.rental_branch_id = m.market_id
             WHERE m.company_id = 1854
           QUALIFY ROW_NUMBER() OVER (PARTITION BY scd.rental_branch_id ORDER BY scd.date_start) = 1
            ) assignment
            ON orders.market_id = assignment.market_id
;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension_group: order {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."ORDER_DATE" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: invoice_no {
    label: "Invoice Number"
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
  }

  dimension_group: invoice_date {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }

  dimension_group: asset_assignment_date {
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."ASSET_ASSIGNMENT_DATE" ;;
  }

  dimension_group: earliest_of_dates {
    description: "The earliest of the order, the invoice, and the asset assignment dates"
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."EARLIEST_DATE" ;;
  }

}
