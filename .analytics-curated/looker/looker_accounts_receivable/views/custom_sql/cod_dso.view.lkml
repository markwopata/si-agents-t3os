view: cod_dso {
  derived_table: {
    sql:
    with revenue_cte as (
  select
    i.company_id,
    sum(li.amount) as revenue
  from analytics.public.v_line_items as li
  left join es_warehouse.public.invoices as i on li.invoice_id = i.invoice_id
  where i.billing_approved_date is not null
    and i.billed_amount > 0
    and datediff(day, i.billing_approved_date::date, current_date) <= 180
  group by i.company_id
),
customer_agg as (
  select
    i.company_id as customer_id,
    c.name as customer_name,
    nt.name as net_terms,
    c.credit_limit,
    sum(i.owed_amount) as OUTSTANDING_BALANCE,
    ifnull(rc.revenue, 0) as revenue
  from es_warehouse.public.invoices as i
  left join es_warehouse.public.companies as c on i.company_id = c.company_id
  left join es_warehouse.public.net_terms as nt on c.net_terms_id = nt.net_terms_id
  left join revenue_cte as rc on rc.company_id = i.company_id
  where i.billing_approved_date is not null
    and i.billed_amount > 0
    and i.owed_amount > 0
    and c.net_terms_id = 1
  group by
    i.company_id, c.name, nt.name, c.credit_limit, rc.revenue
)
select *,
  case
    when revenue = 0 then null
    else (OUTSTANDING_BALANCE / revenue) * 180
  end as dso
from customer_agg
 ;;
  }


  ##### DIMENSIONS #####

  dimension: customer_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    html: <a href= "https://admin.equipmentshare.com/#/home/companies/{{ cod_dso.customer_id }}/activity" target="_blank" style="color: #0063f3; text-decoration: underline;">{{ value }}</a> ;;
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: net_terms {
    type: string
    sql: ${TABLE}."NET_TERMS" ;;
  }

  dimension: credit_limit {
    value_format_name: usd_0
    type: string
    sql: ${TABLE}."CREDIT_LIMIT" ;;
  }

  dimension: outstanding_balance {
    value_format_name: usd
    type: number
    sql: ${TABLE}."OUTSTANDING_BALANCE" ;;
  }

  dimension: revenue {
    value_format_name: usd
    type: number
    sql: ${TABLE}."REVENUE" ;;
  }

  dimension: dso {
    label: "DSO - 6 Months"
    value_format_name: decimal_2
    type: string
    sql: ${TABLE}."DSO" ;;
  }

  }
