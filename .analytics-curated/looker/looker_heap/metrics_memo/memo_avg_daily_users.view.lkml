view: memo_avg_daily_users {
  derived_table: {
    sql:
with metrics_memo_months as (
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
logins as (
select
        ae.user_id
    ,   u.company_id
    ,   cast(ae.time as date) as event_date
    ,   count(distinct ae.session_id) as sessions
    ,   count(distinct ae.event_id) as events
    ,   count(distinct ae.event_table_name) as unique_event_counts
 from non_prod_business_data_vault.heap_t3_platform_production_heap.tbl_all_events ae
 join non_prod_business_data_vault.heap_t3_platform_production_heap.tbl_users u on ae.user_id = u.user_id
 left join es_warehouse.public.users eu on u._user_id = eu.user_id
 where ae.event_table_name not in ('sessions','fleet_browser_load_app')
    and cast(ae.time as date) >= (select min(month) from distinct_months)
    and u.company_id is not null
    and (u.identity not ilike '%t3%' and u.identity not ilike '%customer%' and u.identity not ilike '%track%' and u.identity not ilike '%support%')
    and (eu.first_name not ilike '%t3%' and eu.first_name not ilike '%customer%' and eu.first_name not ilike '%track%' and eu.first_name not ilike '%accounts%')
    and (eu.last_name not ilike '%support%' and eu.last_name not ilike '%payable%')
    and (u.company_name not ilike '%test%' and u.company_name not ilike '%do not use%' and u.company_name not ilike '%don%t use%')
    and u.mimic_user = 'No'
    and u.company_id not in (1854,10859,16184,420,155,23515,11606,77198,5383,4110,88180,37906,36810,42268,84297,58589)
 group by ae.user_id, u.company_id, cast(ae.time as date)
),
login_counts as (
select
        event_date
    ,   extract(dow from event_date) as dow
    ,   count(distinct case when events > 3 then user_id else null end) as daily_active_users
 from logins
 group by event_date
 )
select
        m.month as event_month
    ,   avg(case
            when l.dow not in (0, 6)
                then l.daily_active_users
            else null
        end) as avg_daily_users_excl_weekends
    ,   avg(l.daily_active_users) as avg_daily_users_incl_weekends
 from distinct_months m
 left join login_counts l on m.month = date_trunc('month', l.event_date)
 group by m.month ;;
  }

  dimension: event_month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}.event_month ;;
  }

  measure: avg_daily_users_incl_weekends {
    label: "Average DAU (Including Weekends)"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.avg_daily_users_incl_weekends ;;
  }

  measure: avg_daily_users_excl_weekends {
    label: "Average DAU (Excluding Weekends)"
    type: sum
    value_format: "#,##0"
    sql: ${TABLE}.avg_daily_users_excl_weekends ;;
  }
}
