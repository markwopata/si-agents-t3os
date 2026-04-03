view: memo_paying_customers {
  derived_table: {
    sql: with metrics_memo_months as (
      select distinct
              date_trunc('month',billing_approved_date) as month
          ,   dateadd(month, -12, date_trunc('month',billing_approved_date)) as ytd_start_month
      from es_warehouse.public.invoices
      where date_trunc('month',billing_approved_date) is not null
      and date_trunc('month',billing_approved_date) >= '2023-01-01'
      and date_trunc('month',billing_approved_date) < date_trunc('month', current_date)
      ),
      distinct_months as (
      select month as month from metrics_memo_months
      union
      select ytd_start_month as month from metrics_memo_months
      ),
      paying_customers as (
      select
              date_trunc('month',i.billing_approved_date) as invoiced_month
          ,   i.company_id
          ,   row_number() over (partition by i.company_id order by date_trunc('month',i.billing_approved_date)) as rownum
       from es_warehouse.public.invoices i
      join es_warehouse.public.line_items l on i.invoice_id = l.invoice_id
      where l.line_item_type_id = '33'
      )
      select distinct
              m.month as invoiced_month
          ,   p.company_id
          ,   case
                  when p.rownum = 1
                      then 'Y'
                  else 'N'
              end as new_customer
       from distinct_months m
       left join paying_customers p on m.month = p.invoiced_month ;;
  }


  dimension: invoiced_month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}."INVOICED_MONTH" ;;
  }

  measure: paying_customer_count {
    label: "Paying Customers"
    type: count_distinct
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  measure: new_logo_count {
    label: "New Logos"
    type: count_distinct
    sql:  case when ${TABLE}."NEW_CUSTOMER" = 'Y' then ${TABLE}."COMPANY_ID" else null end ;;
  }
}
