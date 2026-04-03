view: daily_active_users_by_company {
  derived_table: {
    sql:
with generate_series as (
      select * from table(generate_series(
      '2022-12-01'::timestamp_tz,
      current_date::timestamp_tz,
      'day'))
)
, user_events AS (
    select
        ae.user_id,
        u.company_id,
        date_trunc('day', ae.time) as event_date,
        count(distinct ae.session_id) as sessions,
        count(distinct ae.event_id) as events,
        count(distinct ae.event_table_name) as unique_event_counts
    from
        non_prod_business_data_vault.heap_t3_platform_production_heap.tbl_all_events ae
    join
        non_prod_business_data_vault.heap_t3_platform_production_heap.tbl_users u on ae.user_id = u.user_id
    left join
        es_warehouse.public.users eu on u._user_id = eu.user_id
    where
        ae.event_table_name not in ('sessions','fleet_browser_load_app')
        and ae.time::date > date('2022-01-01')
        and u.company_id is not null
        and (u.identity not ilike '%t3%' and u.identity not ilike '%customer%' and u.identity not ilike '%track%' and u.identity not ilike '%support%')
        and (eu.first_name not ilike '%t3%' and eu.first_name not ilike '%customer%' and eu.first_name not ilike '%track%' and eu.first_name not ilike '%accounts%')
        and (eu.last_name not ilike '%support%' and eu.last_name not ilike '%payable%')
        and (u.company_name not ilike '%test%' and u.company_name not ilike '%do not use%' and u.company_name not ilike '%don%t use%')
        and u.mimic_user = 'No'
    group by
        ae.user_id,
        u.company_id,
        date_trunc('day', ae.time)
)
    select
        gs.series::date as event_date,
        --ue.company_id,
        dayname(gs.series::date) as day,
        count(distinct case when ue.events > 3 then ue.user_id else null end) as daily_active_users
    from
        generate_series gs
    left join
        user_events ue on ue.event_date = gs.series::date
    where
        ue.company_id not in (1854,10859,16184,420,155,23515,11606,77198,5383,4110,88180,37906,36810,42268,84297,58589)
    group by
        gs.series::date
        --, ue.company_id
      ;;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}."EVENT_DATE" ;;
  }

  dimension_group: grouped_event_date {
    type: time
    label: "DAU"
    sql: ${TABLE}."EVENT_DATE" ;;
    convert_tz: no
  }

  # dimension: company_id {
  #   type: number
  #   sql: ${TABLE}."COMPANY_ID" ;;
  # }

  # dimension: name {
  #   type: string
  #   label: "Company Name"
  #   sql: ${TABLE}."NAME" ;;
  # }

    dimension: day {
    type: string
    label: "Day of Week"
    sql: ${TABLE}."DAY" ;;
  }

  dimension: day_name_rank {
    type: number
    sql:
      case
        when ${day} = 'Mon' then 1
        when ${day} = 'Tue' then 2
        when ${day} = 'Wed' then 3
        when ${day} = 'Thu' then 4
        when ${day} = 'Fri' then 5
        when ${day} = 'Sat' then 6
        when ${day} = 'Sun' then 7
      end
      ;;
  }

  dimension: daily_active_users {
    type: number
    sql: ${TABLE}."DAILY_ACTIVE_USERS" ;;
  }

  measure: dau {
    label: "DAU"
    type: sum
    sql: ${daily_active_users} ;;
  }

  measure: avg_dau {
    label: "Average DAU (Including Weekends)"
    type: average
    sql: ${daily_active_users} ;;
    value_format_name: decimal_0
  }

  measure: avg_dau_excluding_wknd {
    label: "Average DAU (Excluding Weekends)"
    type: average
    sql: case when ${day} not in ('Sat','Sun') then ${daily_active_users} else null end ;;
    value_format_name: decimal_0
  }
}
