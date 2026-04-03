view: dormant_accounts {
  derived_table: {
    sql: with company_start_date as (
          select
          r.end_date::date as rental_end_date,
          lead(r.end_date::date) over (
          partition by c.company_id, m.market_id
          order by c.company_id, m.market_id, r.end_date) as second_rental_end_date,
          lag(r.end_date::date) over (
          partition by c.company_id, m.market_id
          order by c.company_id, m.market_id, r.end_date) as previous_rental_end_date,
          m.market_id,
          c.company_id as company_id,
          n.name as net_terms,
          c.name as company_name,
          m.name as market_name,
          r.rental_id,
          o.order_id
      from
          ES_WAREHOUSE.public.rentals r
          left join ES_WAREHOUSE.public.orders o on r.order_id = o.order_id
          left join ES_WAREHOUSE.public.markets m on o.market_id = m.market_id
          left join ES_WAREHOUSE.public.assets a on r.asset_id = a.asset_id
          left join ES_WAREHOUSE.public.asset_types a_types on a.asset_type_id = a_types.asset_type_id
          left join ES_WAREHOUSE.public.users u on o.user_id = u.user_id
          LEFT JOIN ES_WAREHOUSE.PUBLIC.order_salespersons os ON os.order_id = o.order_id
          left join ES_WAREHOUSE.public.users sp on coalesce(os.user_id,o.salesperson_user_id)  = sp.user_id
          left join ES_WAREHOUSE.public.companies c on u.company_id = c.company_id
          left join ES_WAREHOUSE.PUBLIC.net_terms n on c.net_terms_id = n.net_terms_id
      where
          m.market_id is not null
          and sp.company_id = {{ _user_attributes['company_id'] }}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          and n.name not like '%Cash on Deliv%'
          and r.rental_status_id != 8
--      order by
--          company_id,
--          market_id,
--          rental_end_date
      )
      ,rank_company_start_date as (
      select
          rental_end_date,
          company_id,
          company_name,
          market_name,
          rental_id,
          order_id,
          row_number ()
          over (
          partition by
          company_id
          order by
          rental_end_date desc
          ) as ranking_last_rental
      from
          company_start_date
      )
      ,determine_dormant_accts as (
      select
          rental_end_date,
          company_id,
          company_name,
          market_name,
          rental_id,
          order_id,
          case when ((current_date - rental_end_date) >= 120) then 1 else 0 end as dormant_acct
      from
          rank_company_start_date rc
      where
          ranking_last_rental = 1
      )
      select
          rental_end_date,
          company_id,
          company_name,
          market_name,
          rental_id as last_rental_id,
          order_id as last_order_id
      from
          determine_dormant_accts
      where
          dormant_acct = 1
          AND DATE_TRUNC('month',rental_end_date) BETWEEN DATE_TRUNC('month',DATEADD('months',-12,current_date)) AND current_date
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

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: last_rental_id {
    type: number
    sql: ${TABLE}."LAST_RENTAL_ID" ;;
    value_format_name: id
  }

  dimension: last_order_id {
    type: number
    sql: ${TABLE}."LAST_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: formatted_rental_end_date {
    group_label: "HTML Formatted Time"
    label: "End Date"
    type: date
    sql: ${rental_end_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  filter: sales_rep_filter {}

  filter: branch_filter {}

  set: detail {
    fields: [
      rental_end_date,
      company_id,
      company_name,
      market_name,
      last_rental_id,
      last_order_id
    ]
  }
}
