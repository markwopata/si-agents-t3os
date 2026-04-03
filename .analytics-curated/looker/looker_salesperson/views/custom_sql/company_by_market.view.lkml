view: company_by_market {
  derived_table: {
    sql: with all_revenue as(
select
        c.company_id,
        c.name as company_name ,
        m.market_id ,
        m.name as market_name,
        case when(sum(i.billed_amount)=0) then 0.001 else sum(i.billed_amount) end as total_rev,
        sum(i.owed_amount ) as total_ar
from ES_WAREHOUSE.public.orders o
left join ES_WAREHOUSE.public.invoices i
    on o.order_id=i.order_id
--per changes Jack G made to another identical query in SeekWell, removing this join to reduce duplicating lines that inflated billed and owed amounts (Jolene 2/3/22)
--left join ES_WAREHOUSE.PUBLIC.line_items li
--    on li.invoice_id=i.invoice_id
left join ES_WAREHOUSE.public.users u
    on i.salesperson_user_id=u.user_id
left join ES_WAREHOUSE.public.users cu
    on o.user_id=cu.user_id
LEFT join ES_WAREHOUSE.PUBLIC.companies c
on cu.company_id = c.company_id
left join ES_WAREHOUSE.PUBLIC.markets m
 on o.market_id=m.market_id
        --where
         -- li.line_item_type_id = 8
        group by
          c.company_id,
        c.name,
        m.market_id ,
        m.name
)
, percent_of_total as(
select
        company_id,
        company_name,
        market_id ,
        market_name,
        total_ar,
        case when(total_ar > 0) then 1 else 0 end as active_company,
        total_rev,
        total_rev/sum(total_rev) over (partition by company_id) as perc_of_rev ,
        sum(total_rev) over (partition by company_id) as rev_all_markets ,
        ROW_NUMBER() OVER (PARTITION BY company_id ORDER BY total_rev DESC) AS rn
from all_revenue
where total_ar is not null
)
,revenue_threshold as(
select
        company_id,
        company_name,
        market_id ,
        market_name,
        total_ar,
        active_company ,
        perc_of_rev
from percent_of_total
where rn= 1
)
select
company_id::varchar as m_company_id,
company_name as m_company_name,
market_name as m_market_name
from revenue_threshold
where company_id is not null
       ;;
  }



  dimension: m_company_id {
    type: string
    sql: ${TABLE}.m_company_id ;;
  }

  dimension: m_company_name {
    type: string
    sql: ${TABLE}.m_company_name ;;
  }

  dimension: m_market_name {
    type: string
    sql: ${TABLE}.m_market_name ;;
  }


  }
