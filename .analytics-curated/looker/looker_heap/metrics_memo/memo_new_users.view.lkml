view: memo_new_users {
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
      new_heap_users as (
      select
              m.month as first_heap_session_month
          ,   u.company_id
          ,   u.user_id as heap_user_id
          ,   u._user_id as es_user_id
       from distinct_months m
       left join non_prod_business_data_vault.heap_t3_platform_production_heap.tbl_users u on m.month = date_trunc('month',cast(u.joindate as date))
       left join es_warehouse.public.users eu on u._user_id = eu.user_id
       where u.company_id not in (1854,10859,16184,420,155,23515,11606,4110,5383,77198,88180,37906,36810)
        and (eu.first_name not ilike '%t3%' and eu.first_name not ilike '%customer%' and eu.first_name not ilike '%track%' and eu.first_name not ilike '%accounts%')
        and (eu.last_name not ilike '%support%' and eu.last_name not ilike '%payable%')
        and (u.company_name not ilike '%test%' and u.company_name not ilike '%do not use%' and u.company_name not ilike '%don%t use%')
        and u.mimic_user = 'No'
        and u.company_id is not null
      )
      select
              h.first_heap_session_month
          ,   h.company_id
          ,   h.heap_user_id
          ,   case
                  when r.first_rental_month <= h.first_heap_session_month and a.first_owned_asset_month <= h.first_heap_session_month then 'Hybrid'
                  when r.first_rental_month <= h.first_heap_session_month and a.first_owned_asset_month is null then 'Rental'
                  when r.first_rental_month is null and a.first_owned_asset_month <= h.first_heap_session_month then 'T3'
                  when r.first_rental_month is null and a.first_owned_asset_month is null and c.first_credit_app_received_month  <= h.first_heap_session_month then 'Intent To Rent'
                  else 'No Assets/Rentals'
              end as cohort
       from new_heap_users h
       left join (
                  select
                           u.company_id
                      ,   min(date_trunc('month', cast(r.start_date as date))) as first_rental_month
                  from es_warehouse.public.rentals r
                  join es_warehouse.public.orders o on o.order_id = r.order_id
                  join es_warehouse.public.users u on u.user_id = o.user_id
                  where r.rental_type_id != 4
                    and r.deleted = false
                    and u.company_id not in (1854, 10859, 16184, 420, 155, 23515, 11606, 77198, 5383, 4110, 88180, 37906, 36810, 42268, 84297, 58589)
                  group by u.company_id
                  ) r on h.company_id = r.company_id
                     and r.first_rental_month <= h.first_heap_session_month
       left join (
                  select
                          ao.asset_company_id as company_id
                      ,   min(date_trunc('month',cast(a.date_created as date))) as first_owned_asset_month
                  from es_warehouse.public.assets a
                  join analytics.bi_ops.asset_ownership ao on a.asset_id = ao.asset_id
                  where a.asset_type_id in (1, 2, 3)
                  and ao.ownership in ('CUSTOMER', 'OWN')
                  group by ao.asset_company_id
                  ) a on h.company_id = a.company_id
                     and a.first_owned_asset_month <= h.first_heap_session_month
       left join (
                  select
                          company_id
                      ,   min(date_trunc('month',date_received)) as first_credit_app_received_month
                   from analytics.bi_ops.credit_app_master_retool
                   group by company_id
                 ) c on h.company_id = c.company_id
                    and c.first_credit_app_received_month <= h.first_heap_session_month ;;
  }

  dimension: first_heap_session_month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}."FIRST_HEAP_SESSION_MONTH" ;;
  }

  dimension: cohort {
    type: string
    sql: ${TABLE}."COHORT" ;;
  }

  measure: new_company_count {
    label: "New Companies"
    type: count_distinct
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  measure: new_users {
    label: "New Users"
    type: count_distinct
    sql: ${TABLE}."HEAP_USER_ID" ;;
  }


  measure: new_rental_users {
    label: "New Rental Users"
    type: count_distinct
    sql: case when ${TABLE}."COHORT" = 'Rental' then ${TABLE}."HEAP_USER_ID" end ;;
  }

  measure: new_hyrbid_users {
    label: "New Hybrid Users"
    type: count_distinct
    sql: case when ${TABLE}."COHORT" = 'Hybrid' then ${TABLE}."HEAP_USER_ID" end ;;
  }

  measure: new_t3_sub_users {
    label: "New T3 Sub Users"
    type: count_distinct
    sql: case when ${TABLE}."COHORT" = 'T3' then ${TABLE}."HEAP_USER_ID" end ;;
  }

  measure: new_intent_to_rent_users {
    label: "New Intent to Rent Users"
    type: count_distinct
    sql: case when ${TABLE}."COHORT" = 'Intent To Rent' then ${TABLE}."HEAP_USER_ID" end ;;
  }

  measure: new_unknown_users {
    label: "New No Assets/Rentals Users"
    type: count_distinct
    sql: case when ${TABLE}."COHORT" = 'No Assets/Rentals' then ${TABLE}."HEAP_USER_ID" end ;;
  }


}
