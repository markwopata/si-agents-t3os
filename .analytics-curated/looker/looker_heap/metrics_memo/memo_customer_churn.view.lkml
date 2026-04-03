view: memo_customer_churn {
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
      company_churn as (
      select
              property_closed_date
          ,   try_cast(property_es_admin_id as int) as company_id
          ,   round(cast(replace(property_arrev_lost, '$', '') as int), 2) as arr_lost
       from analytics.hubspot_customer_success.ticket
       where property_churn_type = 'Company Churn'
       and try_cast(property_es_admin_id as int) is not null
       and property_closed_date is not null
      )
      select
              m.month as churn_month
          ,   c.company_id
          ,   c.arr_lost
       from distinct_months m
       left join company_churn c on m.month = date_trunc('month', cast(c.property_closed_date as date)) ;;
  }

  dimension: churn_month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}."CHURN_MONTH" ;;
  }

  measure: churned_company_count {
    label: "Churned Companies"
    type: count_distinct
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  measure: arr_lost {
    label: "ARR Lost"
    value_format_name: "usd_0"
    type: sum
    sql: ${TABLE}."ARR_LOST" ;;
  }
}
