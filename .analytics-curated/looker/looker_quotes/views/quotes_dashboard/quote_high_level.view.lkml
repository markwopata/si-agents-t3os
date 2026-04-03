view: quote_high_level {
    derived_table: {
      sql: with order_billed_amount as (
              select
              i.order_id
              , sum(i.billed_amount) as billed_amount
              , sum(r.purchase_price) as order_revenue
              , count(distinct i.invoice_id) as order_invoice_count
              from
              es_warehouse.public.invoices i
              left join es_warehouse.public.orders o on i.order_id = o.order_id
              left join es_warehouse.public.rentals r on r.order_id = o.order_id
              group by
              i.order_id
              )

              select
                q.created_by
              , case
                  when q.sales_rep_id in (6052, 171481) then 'Amy/Tanner'
                  when cd2.employee_title != 'Territory Account Manager' or q.sales_rep_id = 329563 then 'Non-TAM'
                  else 'TAMs' end as rep_group
              , cd.nickname as created_by_name
              , cd.employee_title as created_by_title
              , q.created_date
              , q.quote_number
              , rr.id as online_rental_request_id
              , o.order_id
              , cd2.nickname as salesperson_name
              , cd2.employee_title as salesperson_title
              , case
              when rr.id is not null then 'Online'
              when cd.employee_title like '%Customer Support%' then 'Customer Support'
              else 'Other'
              end as lead_source
              , qp.rental_subtotal as quoted_revenue
              , oba.order_revenue as order_revenue
              , oba.billed_amount
              , order_invoice_count
              , m.region
              , m.region_name
              , m.district
              , m.market_name
              , m.market_type
              , m.division_name
              from
                quotes.quotes.quote q
                  left join rental_order_request.public.rental_requests rr  on q.id = rr.quote_id
                  left join es_warehouse.public.orders o on q.order_id = o.order_id
                  left join order_billed_amount oba on oba.order_id = o.order_id
                  left join es_warehouse.public.users u on q.created_by = u.user_id
                  left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd on u.email_address = cd.work_email
                  left join es_warehouse.public.users u2 on q.sales_rep_id = u2.user_id
                  left join ANALYTICS.PAYROLL.COMPANY_DIRECTORY cd2 on u2.email_address = cd2.work_email
                  left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m on q.branch_id = m.MARKET_ID
                  left join quotes.quotes.quote_pricing qp on q.ID = qp.QUOTE_ID
                  --where
                  --(cd.employee_title like '%Customer Support%'
                  --or rr.id is not null)
                  --and o.order_id is not null
                  --and
                  --and q.created_date >= '2025-06-17'
                  --and m.region = 4
                  --and q.order_id is not null
                 -- having rep_group = 'Non-TAM'
                  order by q.created_date desc
                 -- limit 20
                   ;;
    }

    measure: count {
      type: count
      drill_fields: [detail*]
    }

    dimension: created_by {
      type: number
      sql: ${TABLE}."CREATED_BY" ;;
    }

    dimension: rep_group {
      type: string
      sql: ${TABLE}."REP_GROUP" ;;
    }

    dimension: created_by_name {
      type: string
      sql: ${TABLE}."CREATED_BY_NAME" ;;
    }

    dimension: created_by_title {
      type: string
      sql: ${TABLE}."CREATED_BY_TITLE" ;;
    }

    dimension_group: created_date {
      type: time
      sql: ${TABLE}."CREATED_DATE" ;;
    }

    dimension: quote_number {
      type: string
      sql: ${TABLE}."QUOTE_NUMBER" ;;
    }

    dimension: online_rental_request_id {
      type: string
      sql: ${TABLE}."ONLINE_RENTAL_REQUEST_ID" ;;
    }

    dimension: order_id {
      type: string
      sql: ${TABLE}."ORDER_ID" ;;
    }

    dimension: salesperson_name {
      type: string
      sql: ${TABLE}."SALESPERSON_NAME" ;;
    }

    dimension: salesperson_title {
      type: string
      sql: ${TABLE}."SALESPERSON_TITLE" ;;
    }

    dimension: lead_source {
      type: string
      sql: ${TABLE}."LEAD_SOURCE" ;;
    }

    dimension: quoted_revenue {
      type: number
      sql: ${TABLE}."QUOTED_REVENUE" ;;
    }

    dimension: order_revenue {
      type: number
      sql: ${TABLE}."ORDER_REVENUE" ;;
    }

    dimension: billed_amount {
      type: number
      sql: ${TABLE}."BILLED_AMOUNT" ;;
    }

    dimension: order_invoice_count {
      type: number
      sql: ${TABLE}."ORDER_INVOICE_COUNT" ;;
    }

    measure: order_invoice_count_sum {
      label: "Order Invoice Count"
      type: sum
      sql: ${order_invoice_count} ;;
    }

    measure: quoted_revenue_sum {
      label: "Quoted Revenue"
      group_label: "Revenue"
      type: sum
    sql: ${quoted_revenue} ;;
    value_format_name: usd_0
   }

    measure: order_revenue_sum {
      label: "Order Revenue"
      group_label: "Revenue"
      type: sum
      sql: ${order_revenue} ;;
      value_format_name: usd_0
    }

    measure: billed_amount_sum {
      label: "Billed Amount"
      group_label: "Revenue"
      type: sum
      sql: ${billed_amount} ;;
      value_format_name: usd_0
    }

    dimension: region {
      type: number
      sql: ${TABLE}."REGION" ;;
    }

    dimension: region_name {
      group_label: "Sales Locations"
      type: string
      sql: ${TABLE}."REGION_NAME" ;;
    }

    dimension: district {
      group_label: "Sales Locations"
      type: string
      sql: ${TABLE}."DISTRICT" ;;
    }

    dimension: market_name {
      group_label: "Sales Locations"
      type: string
      sql: ${TABLE}."MARKET_NAME" ;;
    }

    dimension: market_type {
      group_label: "Sales Locations"
      type: string
      sql: ${TABLE}."MARKET_TYPE" ;;
    }

    dimension: division {
      group_label: "Sales Locations"
      type: string
      sql: ${TABLE}."DIVISION_NAME" ;;
    }

    measure: quote_count {
      group_label: "Counts"
      type: count_distinct
      sql: ${quote_number} ;;
    }

    measure: order_count {
      group_label: "Counts"
      type: count_distinct
      sql: ${order_id} ;;
    }

    measure: quote_order_conversion {
      label: "Quote Conversion"
      group_label: "Conversion Rates"
      type: number
      sql: DIV0(${order_count}, ${quote_count} );;
      value_format_name: percent_1
    }

    set: detail {
      fields: [
        created_by,
        rep_group,
        created_by_name,
        created_by_title,
        created_date_time,
        quote_number,
        online_rental_request_id,
        order_id,
        salesperson_name,
        salesperson_title,
        lead_source,
        quoted_revenue,
        order_revenue,
        billed_amount,
        region,
        region_name
        , district
        , market_name
        , market_type
        , division

      ]
    }
  }
