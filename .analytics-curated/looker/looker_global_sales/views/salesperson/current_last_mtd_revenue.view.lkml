view: current_last_mtd_revenue {
  derived_table: {
    sql: with current_month_revenue as (
      select
          concat(usales.first_name,' ',usales.last_name) as sales_rep,
          usales.user_id,
          m.name as branch,
          sum(total) as current_month_rental_revenue
      from
          es_warehouse.public.orders o
          left join es_warehouse.public.order_salespersons os on os.order_id = o.order_id
          left join es_warehouse.public.global_invoices i on i.order_id = o.order_id
          left join es_warehouse.public.global_line_items li on li.invoice_id = i.invoice_id
          left join es_warehouse.public.users usales on usales.user_id = os.user_id
          left join es_warehouse.public.users uorder on uorder.user_id = o.user_id
          left join es_warehouse.public.companies c on uorder.company_id = c.company_id
          left join es_warehouse.public.markets m on m.market_id = o.market_id
      where
          --usales.user_id = 10883
          --AND
          (li.line_item_type_id in (1,2) AND li.domain_id = 1)
          AND date_trunc('month',li.created_date) = date_trunc('month',current_date)
          AND {% condition branch_filter %} m.branch {% endcondition %}
          AND {% condition sales_rep_filter %} concat(usales.first_name,' ',usales.last_name) {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND usales.company_id = {{ _user_attributes['company_id'] }}
      group by
          concat(usales.first_name,' ',usales.last_name),
          usales.user_id,
          m.name
      )
      , last_mtd_revenue as (
      select
          concat(usales.first_name,' ',usales.last_name) as sales_rep,
          usales.user_id,
          m.name as branch,
          sum(total) as last_mtd_rental_revenue
      from
          es_warehouse.public.orders o
          left join es_warehouse.public.order_salespersons os on os.order_id = o.order_id
          left join es_warehouse.public.global_invoices i on i.order_id = o.order_id
          left join es_warehouse.public.global_line_items li on li.invoice_id = i.invoice_id
          left join es_warehouse.public.users usales on usales.user_id = os.user_id
          left join es_warehouse.public.users uorder on uorder.user_id = o.user_id
          left join es_warehouse.public.companies c on uorder.company_id = c.company_id
          left join es_warehouse.public.markets m on m.market_id = o.market_id
      where
          --usales.user_id = 10883
          --AND
          (li.line_item_type_id in (1,2) AND li.domain_id = 1)
          AND (MONTH(li.created_date) = MONTH(dateadd('month',-1,current_date)) AND DAY(li.created_date) <= DAY(current_date) AND YEAR(li.created_date) = YEAR(current_date))
          AND {% condition branch_filter %} m.branch {% endcondition %}
          AND {% condition sales_rep_filter %} concat(usales.first_name,' ',usales.last_name) {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND usales.company_id = {{ _user_attributes['company_id'] }}
      group by
          concat(usales.first_name,' ',usales.last_name),
          usales.user_id,
          m.name
      )
      select
          concat(u.first_name,' ',u.last_name) as sales_rep,
          u.user_id,
          coalesce(lmr.branch,cmr.branch) as branch,
          cmr.current_month_rental_revenue,
          lmr.last_mtd_rental_revenue
      from
          es_warehouse.public.users u
          left join current_month_revenue cmr on cmr.user_id = u.user_id
          left join last_mtd_revenue lmr on lmr.user_id = u.user_id
      where
          {% condition sales_rep_filter %} concat(u.first_name,' ',u.last_name) {% endcondition %}
          AND u.company_id = {{ _user_attributes['company_id'] }}
          AND u.deleted = FALSE
          --u.user_id = 10883
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: sales_rep {
    type: string
    sql: ${TABLE}."SALES_REP" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: current_month_rental_revenue {
    type: number
    sql: ${TABLE}."CURRENT_MONTH_RENTAL_REVENUE" ;;
  }

  dimension: last_mtd_rental_revenue {
    type: number
    sql: ${TABLE}."LAST_MTD_RENTAL_REVENUE" ;;
  }

  measure: total_current_month_rental_revenue {
    type: sum
    sql: ${current_month_rental_revenue} ;;
    value_format_name: usd_0
  }

  measure: total_last_mtd_rental_revenue {
    type: sum
    sql: ${last_mtd_rental_revenue} ;;
    value_format_name: usd_0
  }

  measure: current_mtd_vs_last_mtd {
    type: number
    sql: ${total_current_month_rental_revenue} - ${total_last_mtd_rental_revenue} ;;
    value_format_name: usd_0
  }

  filter: sales_rep_filter {}

  filter: branch_filter {}

  set: detail {
    fields: [sales_rep, user_id, current_month_rental_revenue, last_mtd_rental_revenue]
  }
}
