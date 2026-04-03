view: branch_customers {
  derived_table: {
    sql:
     with customer_monthly as (select mrx.market_id
                               , mrx.market_name    as                          market_name
                               , mrx.region
                               , mrx.district
                               , mrx.market_type
                               , c.company_id
                               , c.name             as                          customer_name
                               , date_trunc(month, billing_approved_date::date) billing_month
                               , count(r.rental_id) as                          rental_count
                               , sum(li.amount)                                 amount
                          from es_warehouse.public.orders o

                                  inner join es_warehouse.public.invoices
     as i on (i.order_id) = (o.order_id)
inner join analytics.public.v_line_items li
      on (li.invoice_id) = (i.invoice_id)
left join analytics.public.market_region_xwalk mrx
      on ((i.ship_from):branch_id::number) = (mrx.market_id)
left join es_warehouse.public.users u
on o.user_id = u.user_id
left join es_warehouse.public.companies c
                                        on u.company_id = c.company_id
left join es_warehouse.public.rentals r
on li.rental_id = r.rental_id
                          left join analytics.public.es_companies as ec
                                        on c.company_id = ec.company_id
                          where li.line_item_type_id in (6, 8, 44, 108, 109)
                            and ec.company_id is null
                            and mrx.market_name not ilike '%XOM%'
                            and mrx.market_name not ilike '%TES -%'
                          group by mrx.market_id, mrx.market_name, mrx.region, mrx.district, mrx.market_type, c.company_id, c.name, billing_month
                          order by billing_month),

     market_summary as (select market_name,
                               market_id,
                               billing_month,
                               sum(rental_count) as num_rentals,
                               sum(amount)       as rental_revenue,
                               count(*)          as total_customers
                        from customer_monthly cm
                        group by billing_month, market_name, market_id),

    top_customers as (select row_number() over (partition by billing_month, market_id order by amount desc) rn,
                             market_id,
                          market_name,
                          billing_month,
                          market_type,
                          district,
                          region,
                              customer_name,
                              rental_count,
                              amount
                       from customer_monthly)



select tc.market_name,tc.market_id,tc.billing_month,tc.customer_name, tc.rental_count,tc.amount, ms.num_rentals,ms.rental_revenue, ms.total_customers,
       rental_count / num_rentals as tc_rental_share, amount/rental_revenue as tc_rev_share,pp.display,
      datediff(month,m.BRANCH_EARNINGS_START_MONTH,tc.billing_month) +1 as months_open,
      tc.district,tc.market_type,
       case
                                when tc.region = 1 then '1 - Pacific'
                                when tc.region = 2 then '2 - Mountain West'
                                when tc.region = 3 then '3 - Southwest'
                                when tc.region = 4 then '4 - Midwest'
                                when tc.region = 5 then '5 - Southeast'
                                when tc.region = 6 then '6 - Northeast'
                                when tc.region = 7 then '7 - Industrial'
                                else 'No Region' end                 as region,
from top_customers tc
left join market_summary ms
on tc.market_id = ms.market_id
and tc.billing_month = ms.billing_month
left join analytics.gs.PLEXI_PERIODS pp
on tc.billing_month = pp.TRUNC
left join ANALYTICS.BRANCH_EARNINGS.MARKET as m
on tc.MARKET_ID = m.MARKET_ID
where rn = 1
and rental_revenue > 0
and num_rentals > 0
and months_open is not null
order by market_id, billing_month


      ;;
  }

  dimension: market_name {
    label: "Market Name"
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }
  dimension: market_id {
    label: "Market ID"
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }
  dimension: Month {
    label: "Month"
    type: string
    sql: ${TABLE}."DISPLAY" ;;
  }

  dimension: customer_name {
    label: "Top Customer"
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }
  dimension: top_customer_rental_count {
    label: "# of Rentals from Top Customer"
    type: number
    sql: ${TABLE}."RENTAL_COUNT" ;;
  }
  dimension: Amount {
    label: "Revenue from Top Customer"
    type: number
    sql: ${TABLE}."AMOUNT" ;;
  }
  dimension: total_rentals {
    label: "Total Monthly Rentals"
    type: number
    sql: ${TABLE}."NUM_RENTALS" ;;
  }
  dimension: rental_revenue {
    label: "Total Rental Revenue"
    type: number
    sql: ${TABLE}."RENTAL_REVENUE" ;;
  }
  dimension: total_customers {
    label: "Total Customers"
    type: number
    sql: ${TABLE}."TOTAL_CUSTOMERS" ;;
  }
  dimension: top_customer_rental_share {
    label: "Top Customer Rental Share"
    type: number
    sql: ${TABLE}."TC_RENTAL_SHARE" ;;
  }
  dimension: top_customer_revenue_share {
    label: "Top Customer Revenue Share"
    type: number
    sql: ${TABLE}."TC_REV_SHARE" ;;
  }
  dimension: months_open {
    label: "Months Open"
    type: number
    sql: ${TABLE}."MONTHS_OPEN" ;;
  }
  dimension: district {
    label: "District"
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }
  dimension: region {
    label: "Region"
    type: string
    sql: ${TABLE}."REGION" ;;
  }
  dimension: market_type {
    label: "Market Type"
    type: string
    sql: ${TABLE}."MARKET_TYPE" ;;
  }

  }
