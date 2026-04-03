view: historical_revenue {
  derived_table: {
    sql: select
          concat(usales.first_name,' ',usales.last_name) as sales_rep,
          date_trunc('month',convert_timezone('{{ _user_attributes['user_timezone'] }}',li.created_date)) as created_month,
          usales.user_id,
          m.name as branch,
          sum(total) as monthly_rental_revenue
      from
          es_warehouse.public.orders o
          left join es_warehouse.public.order_salespersons os on os.order_id = o.order_id
          left join es_warehouse.public.global_invoices i on i.order_id = o.order_id
          left join es_warehouse.public.global_line_items li on li.invoice_id = i.invoice_id AND li.domain_id = i.domain_id
          left join es_warehouse.public.users usales on usales.user_id = os.user_id
          left join es_warehouse.public.users uorder on uorder.user_id = o.user_id
          left join es_warehouse.public.companies c on uorder.company_id = c.company_id
          left join es_warehouse.public.markets m on m.market_id = o.market_id
      where
          --usales.user_id = 10883
          --AND
          (li.line_item_type_id in (1,2) AND li.domain_id = 1)
          AND date_trunc('month',convert_timezone('{{ _user_attributes['user_timezone'] }}',li.created_date)) >= date_trunc('month',dateadd('months',-12,convert_timezone('{{ _user_attributes['user_timezone'] }}',current_date)))
          AND {% condition branch_filter %} m.branch {% endcondition %}
          AND {% condition sales_rep_filter %} concat(usales.first_name,' ',usales.last_name) {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
          AND usales.company_id = {{ _user_attributes['company_id'] }}
      group by
          concat(usales.first_name,' ',usales.last_name),
          date_trunc('month',convert_timezone('{{ _user_attributes['user_timezone'] }}',li.created_date)),
          usales.user_id,
          m.name
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

  dimension_group: created_month {
    type: time
    sql: ${TABLE}."CREATED_MONTH" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: branch {
    type: string
    sql: ${TABLE}."BRANCH" ;;
  }

  dimension: monthly_rental_revenue {
    type: number
    sql: ${TABLE}."MONTHLY_RENTAL_REVENUE" ;;
  }

  measure: total_monthly_rental_revenue {
    type: sum
    sql: ${monthly_rental_revenue} ;;
    value_format_name: usd_0
    drill_fields: [detail*]
  }

  dimension: formatted_month_year {
    group_label: "HTML Formatted Day"
    label: "Invoice Month/Year"
    type: date
    sql: ${created_month_raw} ;;
    html: {{ rendered_value | date: "%B %Y" }};;
    # html: {{ rendered_value | append: "-01" | date: "%b %Y" }};;
  }

  filter: sales_rep_filter {}

  filter: branch_filter {}

  set: detail {
    fields: [historical_revenue_drill.sales_rep, historical_revenue_drill.company, historical_revenue_drill.branch, historical_revenue_drill.formatted_created_date, historical_revenue_drill.invoice_no, historical_revenue_drill.total_rental_revenue]
  }
}
