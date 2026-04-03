view: homepage_visits_by_company {
  derived_table: {
    sql: select
          apl.dashboard_name as dashboard,
          count(event_id) as ttl_visits
      from
        heap_t3_platform_production.heap.users u
        join heap_t3_platform_production.heap.analytics_looker_event_dashboard_loaded apl on apl.user_id = u.user_id
      where
          u.company_id = {{ _user_attributes['company_id'] }}
          and apl.dashboard_name is not null
          AND apl.dashboard_name not in ('Home')
          and apl._app_name = 'Analytics'
          AND apl.time >= dateadd(day,-30,current_timestamp::date)::timestamp
          and u.mimic_user = 'No'
      group by
          apl.dashboard_name
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: dashboard {
    type: string
    sql: ${TABLE}."DASHBOARD" ;;
  }

  dimension: ttl_visits {
    type: number
    sql: ${TABLE}."TTL_VISITS" ;;
  }

  measure: total_visits {
    type: sum
    sql: ${ttl_visits} ;;
  }

  set: detail {
    fields: [dashboard, total_visits]
  }
}
