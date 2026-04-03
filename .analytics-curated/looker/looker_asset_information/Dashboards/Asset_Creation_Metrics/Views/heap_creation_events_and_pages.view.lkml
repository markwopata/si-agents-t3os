view: heap_creation_events_and_pages {
  derived_table: {
    sql:
with session_event_times as (
select
    session_id,
    user_id,
    event_id,
    event_table_name,
    convert_timezone('America/Chicago',ae.time::date) as event_date,
    time,
    datediff(seconds,lag(time,1) over (partition by session_id order by time asc), time) as seconds
from
    HEAP_T3_PLATFORM_PRODUCTION.HEAP.ALL_EVENTS ae
where
   time::date >= date('2023-01-01')
and event_table_name in ('user_segments_fleet__fleet_assets_bulk_add_asset_navigate','user_segments_fleet__fleet_assets_add_asset_click','custom_events_fleet_assets_click_upload','user_segments_fleet__fleet_assets_add_asset_click','user_segments_fleet__fleet_assets_submit_add_asset')
)
select
    u._user_id as user_id,
    coalesce(concat(u2.first_name, ' ', u2.last_name), 'N/A') as user_name,
    coalesce(c.name, 'N/A') as company,
    event_date,
    session_id,
    event_id,
    event_table_name,
    seconds,
    case
      when event_table_name in ('custom_events_fleet_assets_click_partial_upload','custom_events_fleet_assets_click_upload') then 'Bulk Asset Upload'
      else 'Normal Upload'
    end as asset_add_type
from
    session_event_times st
left join
    HEAP_T3_PLATFORM_PRODUCTION.HEAP.users u on u.user_id = st.user_id
left join
    es_warehouse.public.users u2 on u2.user_id = u._user_id
left join
    es_warehouse.public.companies c on u2.company_id = c.company_id
where
    event_table_name in ('custom_events_fleet_assets_click_partial_upload','custom_events_fleet_assets_click_upload','user_segments_fleet__fleet_assets_submit_add_asset')
    and event_date between
  {% date_start date_filter %} and
  {% date_end date_filter %}
                ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID";;
  }

  dimension: user_name {
    type: string
    sql: ${TABLE}."USER_NAME";;
  }

  dimension: company {
    type: string
    sql: ${TABLE}."COMPANY";;
  }

  dimension: event_date {
    type: date
    sql: ${TABLE}."EVENT_DATE";;
  }

  dimension: session_id {
    type: number
    sql: ${TABLE}."SESSION_ID";;
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID";;
  }

  dimension: page {
    type: string
    sql: ${TABLE}."PAGE";;
  }

  dimension: seconds {
    type: number
    sql: ${TABLE}."SECONDS";;
  }

  dimension: asset_add_type {
    type: string
    sql: ${TABLE}."ASSET_ADD_TYPE" ;;
  }

  measure: dwell_time {
    type: average
    sql:  ${seconds};;
    value_format_name: decimal_2
  }

  filter: date_filter {
    type: date_time
  }
}
