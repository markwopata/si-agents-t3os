view: homepage_recent_dashboard_views {
  derived_table: {
    sql: with ranking_dashboard as (
      select
          apl.dashboard_name as dashboard_name,
          concat(apl.domain,apl.path) as dashboard_link,
          max(time) as most_recent_dashboard_view,
          row_number() over (partition by dashboard_name order by apl.time desc) as row_number
      from
        heap_t3_platform_production.heap.users u
        join heap_t3_platform_production.heap.analytics_looker_event_dashboard_loaded apl on apl.user_id = u.user_id
      where
          u._user_id = {{ _user_attributes['user_id'] }}
          and apl.dashboard_name is not null
          AND apl.dashboard_name not in ('Home')
          and apl._app_name = 'Analytics'
          and u.mimic_user = 'No'
      group by
        apl.dashboard_name,
        apl.time,
        concat(apl.domain,apl.path)
      )
      select
          rank() over (order by most_recent_dashboard_view desc) as most_recent_dashboard_view_rank,
          dashboard_name,
          dashboard_link,
          most_recent_dashboard_view
      from
          ranking_dashboard
      where
          row_number = 1
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: most_recent_dashboard_view_rank {
    type: number
    sql: ${TABLE}."MOST_RECENT_DASHBOARD_VIEW_RANK" ;;
  }

  dimension: dashboard_name {
    type: string
    sql: ${TABLE}."DASHBOARD_NAME" ;;
  }

  dimension: dashboard_link {
    type: string
    sql: ${TABLE}."DASHBOARD_LINK" ;;
  }

  dimension_group: most_recent_dashboard_view {
    type: time
    sql: ${TABLE}."MOST_RECENT_DASHBOARD_VIEW" ;;
  }

  dimension: link_to_dashboard {
    group_label: "Link to dashboard"
    label: "Dashboard Name"
    type: string
    sql: ${dashboard_link} ;;
    html: <font color="#0063f3"><u><a href="https://{{rendered_value}}" target="_blank">{{dashboard_name._rendered_value}}</a></font></u>;;
  }

  dimension: last_view {
    group_label: "HTML Formatted Time"
    label: "Last Viewed"
    type: date_time
    sql: convert_timezone('{{ _user_attributes['user_timezone'] }}',${most_recent_dashboard_view_raw}) ;;
    html: {{ rendered_value | date: "%b %d, %Y %r"  }} {{ _user_attributes['user_timezone_label'] }};;
  }

  set: detail {
    fields: [most_recent_dashboard_view_rank, dashboard_name]
  }
}
