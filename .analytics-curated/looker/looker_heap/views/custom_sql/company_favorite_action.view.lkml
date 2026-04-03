view: company_favorite_action {
  derived_table: {
    sql:

{% if platform_app._parameter_value == 't3_main' %}
    with totals as (
    select u.company_id,
           e.EVENT_TABLE_NAME,
           count(*) as event_count
    from HEAP_MAIN_PRODUCTION.HEAP.ALL_EVENTS e
             inner join HEAP_MAIN_PRODUCTION.HEAP.USERS u
                        on e.USER_ID = u.USER_ID
    where e.EVENT_TABLE_NAME not in ('pageviews', 'sessions')
    and u.company_id not in (1854, 42268, 420, 43362, 16184, 6302)
    group by u.company_id, e.EVENT_TABLE_NAME)
    select company_id,
       EVENT_TABLE_NAME,
       100 * ratio_to_report(event_count) over ( partition by company_id) as ratio_to_report,
       event_count,
       row_number() over (partition by company_id order by event_count desc) as event_rank
from totals

{% elsif platform_app._parameter_value == 'link_app' %}
    with totals as (
    select u.company_id,
           e.EVENT_TABLE_NAME,
           count(*) as event_count
    from HEAP_LINK_PRODUCTION.HEAP.ALL_EVENTS e
             inner join HEAP_LINK_PRODUCTION.HEAP.USERS u
                        on e.USER_ID = u.USER_ID
    where e.EVENT_TABLE_NAME not in ('pageviews', 'sessions')
    and u.company_id not in (1854, 42268, 420, 43362, 16184, 6302)
    group by u.company_id, e.EVENT_TABLE_NAME)
    select company_id,
       EVENT_TABLE_NAME,
       100 * ratio_to_report(event_count) over ( partition by company_id) as ratio_to_report,
       event_count,
       row_number() over (partition by company_id order by event_count desc) as event_rank
    from totals

{% elsif platform_app._parameter_value == 'rent_app' %}
    with totals as (
    select u.company_id,
           e.EVENT_TABLE_NAME,
           count(*) as event_count
    from HEAP_RENT_MOBILE_PRODUCTION.HEAP.ALL_EVENTS e
             inner join HEAP_RENT_MOBILE_PRODUCTION.HEAP.USERS u
                        on e.USER_ID = u.USER_ID
    where e.EVENT_TABLE_NAME not in ('pageviews', 'sessions')
    and u.company_id not in (1854, 42268, 420, 43362, 16184, 6302)
    group by u.company_id, e.EVENT_TABLE_NAME)
    select company_id,
       EVENT_TABLE_NAME,
       100 * ratio_to_report(event_count) over ( partition by company_id) as ratio_to_report,
       event_count,
       row_number() over (partition by company_id order by event_count desc) as event_rank
    from totals

{% elsif platform_app._parameter_value == 'analytics_app' %}
    with totals as (
    select u.company_id,
           e.EVENT_TABLE_NAME,
           count(*) as event_count
    from HEAP_T3_ANALYTICS_APP_PRODUCTION.HEAP.ALL_EVENTS e
             inner join HEAP_T3_ANALYTICS_APP_PRODUCTION.HEAP.USERS u
                        on e.USER_ID = u.USER_ID
    where e.EVENT_TABLE_NAME not in ('pageviews', 'sessions')
    and u.company_id not in (1854, 42268, 420, 43362, 16184, 6302)
    group by u.company_id, e.EVENT_TABLE_NAME)
    select company_id,
       EVENT_TABLE_NAME,
       100 * ratio_to_report(event_count) over ( partition by company_id) as ratio_to_report,
       event_count,
       row_number() over (partition by company_id order by event_count desc) as event_rank
    from totals

{% elsif platform_app._parameter_value == 'all_apps' %}
    with totals as (
    select u.company_id,
           e.EVENT_TABLE_NAME,
           count(*) as event_count
          from (
select * from heap_main_production.heap.all_events
where EVENT_TABLE_NAME not in ('pageviews', 'sessions')
union
select * from heap_link_production.heap.all_events
where EVENT_TABLE_NAME not in ('pageviews', 'sessions')
union
select * from heap_rent_mobile_production.heap.all_events
where EVENT_TABLE_NAME not in ('pageviews', 'sessions')
union
select * from heap_t3_analytics_app_production.heap.all_events
where EVENT_TABLE_NAME not in ('pageviews', 'sessions')
) e
inner join analytics.heap_adjunct.heap_users u
on e.user_id = u.user_id
group by u.company_id, e.event_table_name)

    select company_id,
       EVENT_TABLE_NAME,
       100 * ratio_to_report(event_count) over ( partition by company_id) as ratio_to_report,
       event_count,
       row_number() over (partition by company_id order by event_count desc) as event_rank
from totals

{% else %}
    with totals as (
    select u.company_id,
           e.EVENT_TABLE_NAME,
           count(*) as event_count

    from HEAP_MAIN_PRODUCTION.HEAP.ALL_EVENTS e
             inner join HEAP_MAIN_PRODUCTION.HEAP.USERS u
                        on e.USER_ID = u.USER_ID
    where e.EVENT_TABLE_NAME not in ('pageviews', 'sessions')
    and u.company_id not in (1854, 42268, 420, 43362, 16184, 6302)
    group by u.company_id, e.EVENT_TABLE_NAME)
    select company_id,
       EVENT_TABLE_NAME,
       100 * ratio_to_report(event_count) over ( partition by company_id) as ratio_to_report,
       event_count,
       row_number() over (partition by company_id order by event_count desc) as event_rank
      from totals
{% endif %}


)

 ;;


  }

  parameter: platform_app {
    type: unquoted
    default_value: "t3_main"
    allowed_value: {
      label: "T3 Main"
      value: "t3_main"
    }
    allowed_value: {
      label: "Link App"
      value: "link_app"
    }
    allowed_value: {
      label: "Rent App"
      value: "rent_app"
    }
    allowed_value: {
      label: "Analytics App"
      value: "analytics_app"
    }
    allowed_value: {
      label: "All Apps"
      value: "all_apps"
    }
  }

  dimension: pkey {
    primary_key: yes
    type: string
    sql: CONCAT(${company_id}, ' - ', ${event_table_name}) ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: event_table_name {
    type: string
    sql: ${TABLE}."EVENT_TABLE_NAME" ;;
  }

  dimension: event_ratio {
    type: number
    sql: ${TABLE}."RATIO_TO_REPORT" ;;
  }

  dimension: event_count {
    type: number
    sql: ${TABLE}."EVENT_COUNT" ;;
  }

  dimension: company_event_rank {
    type: number
    sql: ${TABLE}."EVENT_RANK" ;;
  }

  }
