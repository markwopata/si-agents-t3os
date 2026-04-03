view: dormant_customer_accounts {
  derived_table: {
    # datagroup_trigger: Every_Two_Hours_Update
    sql: with company_start_date as (
          select
          -- this is the date we'll actually use for the quarter
          r.end_date::date as rental_end_date
          -- this creates the NEXT rental date
          ,lead(r.end_date::date) over (
          partition by c.company_id, m.market_id
          order by c.company_id, m.market_id, r.end_date) as second_rental_end_date
          -- this creates the PREVIOUS rental date (should be blank for new accounts)
          ,lag(r.end_date::date) over (
          partition by c.company_id, m.market_id
          order by c.company_id, m.market_id, r.end_date) as previous_rental_end_date
          ,m.market_id
          ,c.company_id as company_id
          ,n.name as net_terms
          ,c.name as company_name
          ,m.name as market_name
          ,r.rental_id
          ,o.order_id
          ,mrx.region_name
          from ES_WAREHOUSE.public.rentals r
          left join ES_WAREHOUSE.public.orders o
          on r.order_id = o.order_id
          left join ES_WAREHOUSE.public.markets m
          on o.market_id = m.market_id
          left join market_region_xwalk mrx
          on mrx.market_id = m.market_id
          left join ES_WAREHOUSE.public.assets a
          on r.asset_id = a.asset_id
          left join ES_WAREHOUSE.public.asset_types a_types
          on a.asset_type_id = a_types.asset_type_id
          left join ES_WAREHOUSE.public.users u
          on o.user_id = u.user_id
          left join ES_WAREHOUSE.public.users sp
          on o.salesperson_user_id = sp.user_id
          left join ES_WAREHOUSE.public.companies c
          on u.company_id = c.company_id
          left join ES_WAREHOUSE.PUBLIC.net_terms n on
          c.net_terms_id = n.net_terms_id
          where
          m.market_id is not null
          and u.company_id is not null
          and m.company_id = 1854
          -- this eliminates re-rentals & CODs
          and ((SUBSTR(TRIM(a.serial_number), 1, 3) != 'RR-' and SUBSTR(TRIM(a.serial_number), 1, 2) != 'RR') or a.serial_number is null)
          and n.name not like '%Cash on Deliv%'
          and r.rental_status_id != 8
          --and u.company_id in (25143
          --,25705)
          order by
          company_id
          , market_id
          , rental_end_date
          )
          ,rank_company_start_date as (
          select
          rental_end_date,
          region_name,
          company_id,
          company_name,
          market_name,
          rental_id,
          order_id,
          row_number ()
          over (
          partition by
          company_id, region_name
          order by
          rental_end_date desc
          ) as ranking_last_rental
          from
          company_start_date
          )
          ,determine_dormant_accts as (
          select
          rental_end_date,
          region_name,
          company_id,
          company_name,
          market_name,
          rental_id,
          order_id,
          case when ((current_date - rental_end_date) >= 120) then 1 else 0 end as dormant_acct,
          case when ccf.legal is not null then 1 else 0 end as legal_customer
          from
          rank_company_start_date rc
          left join collector_cust_flags ccf on ccf.customer_id = rc.company_id::text
          where
          ranking_last_rental = 1
          )
          select
          rental_end_date,
          region_name,
          company_id,
          company_name,
          market_name,
          rental_id,
          order_id,
          dormant_acct
          from
          determine_dormant_accts
          where
          dormant_acct = 1
          and legal_customer = 0
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: rental_end_date {
    type: date
    sql: ${TABLE}."RENTAL_END_DATE" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    link: {
      label: "View Customer Information Dashboard"
      url: "https://equipmentshare.looker.com/dashboards/28?Company%20Name={{ company_name._filterable_value | url_encode }}"
    }
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: dormant_acct {
    type: number
    sql: ${TABLE}."DORMANT_ACCT" ;;
  }

  set: detail {
    fields: [
      rental_end_date,
      region_name,
      company_id,
      company_name,
      market_name,
      rental_id,
      order_id,
      dormant_acct
    ]
  }
}
