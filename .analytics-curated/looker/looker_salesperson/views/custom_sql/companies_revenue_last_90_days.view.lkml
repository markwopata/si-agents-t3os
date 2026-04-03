view: companies_revenue_last_90_days {
  derived_table:{
    sql:
    select
            c.company_id,
            c.name,
            sum(li.amount) as total_rev
            from ES_WAREHOUSE.public.assets a
LEFT join ES_WAREHOUSE.public.rentals r
  on a.asset_id=r.asset_id
left join ES_WAREHOUSE.public.orders o
  on o.order_id = r.order_id
left join ES_WAREHOUSE.public.markets m
  on o.market_id=m.market_id
left join ES_WAREHOUSE.public.users cu
  on o.user_id=cu.user_id
left join ANALYTICS.public.v_line_items li
  on r.rental_id=li.rental_id
left join ES_WAREHOUSE.public.invoices i
  on li.invoice_id=i.invoice_id
left join ES_WAREHOUSE.public.users u
    on i.salesperson_user_id = u.user_id
left join ES_WAREHOUSE.public.equipment_classes_models_xref x
    on a.equipment_model_id = x.equipment_model_id
left join ES_WAREHOUSE.public.companies c
  on cu.company_id=c.company_id
            where
              li.line_item_type_id in (6,8,108,109)
              and date_trunc('month',li.gl_date_created ::DATE) >= (date_trunc('month',current_date) - interval '90 days')
            group by
              c.company_id,
            c.name
    ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID";;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."NAME";;
  }

  dimension: total_rev {
    type: number
    sql: ${TABLE}."TOTAL_REV";;
  }

  measure: revenue_sum {
    type: sum
    sql: ${total_rev} ;;
  }

}
