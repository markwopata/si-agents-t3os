view: memo_app_usage {
  derived_table: {
    sql:

with heap_events as (
select
        e.heap_user_id
    ,   e.session_id
    ,   e.event_table_name
    ,   cast(date_trunc('month', event_time) as datetime) as event_month
    ,   f.company_id
    ,   f.es_user_id
 from analytics.t3_analytics.heap_event_data_global_clean e
 join analytics.t3_analytics.filtered_users_data f on e.heap_user_id = f.heap_user_id
 join analytics.t3_analytics.heap_session_details d on e.session_id = d.session_id
 where e.event_time >= '2023-01-01'
 and e.customer_support_user = 'FALSE'
 and e.mimic_user = 'FALSE'
 and f.company_id is not null
 and f.company_id <> '1854'
 and d.active_session = 'TRUE'
)
select
        event_month
    ,   'Link App' as app_name
    ,   count(distinct company_id) as company_count
 from heap_events
 where event_table_name like '%linkapp_mobile_app_load_app%'
 group by event_month
union
select
        event_month
    ,   'Rent App' as app_name
    ,   count(distinct company_id) as company_count
 from heap_events
 where event_table_name like '%rentapp_mobile_app_load_app%'
 group by event_month
union
select
        event_month
    ,   'Analytics' as app_name
    ,   count(distinct company_id) as company_count
from heap_events
where event_table_name like '%analytics_browser_load_app%'
 group by event_month
union
select
        event_month
    ,   'Work Orders' as app_name
    ,   count(distinct company_id) as company_count
 from heap_events
 where event_table_name in ('work_orders_service_click_work_orders', 'linkapp_app_menu_touch_work_orders')
 group by event_month
union
select
        event_month
    ,   'Time Cards' as app_name
    ,   count(distinct company_id) as company_count
 from heap_events
 where event_table_name like '%time_tracking_browser_load_app%'
  group by event_month
union
select
        event_month
    ,   'E-Logs' as app_name
    ,   count(distinct company_id) as company_count
 from heap_events
 where event_table_name like '%e_logs_mobile_app_load_app%'
        or event_table_name like '%e_logs_browser_load_app%'
  group by event_month
union
select
        event_month
    ,   'Fleet Map' as app_name
    ,   count(distinct company_id) as company_count
 from heap_events
 where event_table_name = 'fleet_map_click_search'
 group by event_month
union
select
        event_month
    ,   'Dash Cam' as app_name
    ,   count(distinct company_id) as company_count
 from heap_events
 where event_table_name = 'user_segments_fleet__fleet_navigation_menu_click_camera'
 group by event_month
;;
  }


  dimension: event_month {
    type: date_month
    convert_tz: no
    sql: ${TABLE}."EVENT_MONTH" ;;
  }

  dimension: app_name {
    label: "T3 Application"
    type: string
    sql: ${TABLE}."APP_NAME" ;;
  }

  measure: company_count {
    type: sum
    sql: ${TABLE}."COMPANY_COUNT" ;;
  }

  measure: time_cards {
    type: sum
    sql: case when ${TABLE}."APP_NAME" = 'Time Cards' then ${TABLE}."COMPANY_COUNT" end ;;
  }

  measure: e_logs {
    label: "E-Logs"
    type: sum
    sql: case when ${TABLE}."APP_NAME" = 'E-Logs' then ${TABLE}."COMPANY_COUNT" end ;;
  }

  measure: work_orders {
    type: sum
    sql: case when ${TABLE}."APP_NAME" = 'Work Orders' then ${TABLE}."COMPANY_COUNT" end ;;
  }

  measure: dash_cam {
    type: sum
    sql: case when ${TABLE}."APP_NAME" = 'Dash Cam' then ${TABLE}."COMPANY_COUNT" end ;;
  }

  measure: fleet_map {
    type: sum
    sql: case when ${TABLE}."APP_NAME" = 'Fleet Map' then ${TABLE}."COMPANY_COUNT" end ;;
  }

  measure: link_app {
    type: sum
    sql: case when ${TABLE}."APP_NAME" = 'Link App' then ${TABLE}."COMPANY_COUNT" end ;;
  }

  measure: rent_app {
    type: sum
    sql: case when ${TABLE}."APP_NAME" = 'Rent App' then ${TABLE}."COMPANY_COUNT" end ;;
  }

  measure: analytics {
    type: sum
    label: "Analytics"
    sql: case when ${TABLE}."APP_NAME" = 'Analytics' then ${TABLE}."COMPANY_COUNT" end ;;
  }
}
