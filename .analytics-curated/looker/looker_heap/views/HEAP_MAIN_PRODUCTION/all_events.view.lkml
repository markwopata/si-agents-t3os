view: all_events {
derived_table: {
  sql:
{% if platform_app._parameter_value == 't3_main' %}
                                 SELECT event_id,
                                        time,
                                        user_id,
                                        session_id,
                                        event_table_name,
                                        'Fleet, ELogs, Timecards Web' as es_app_name
                                 FROM heap_main_production.heap.all_events
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

{% elsif platform_app._parameter_value == 'link_app' %}
                                 SELECT event_id,
                                        time,
                                        user_id,
                                        session_id,
                                        event_table_name,
                                        'Link' as es_app_name
                                 FROM heap_link_production.heap.all_events
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

{% elsif platform_app._parameter_value == 'rent_app' %}
                                 SELECT event_id,
                                        time,
                                        user_id,
                                        session_id,
                                        event_table_name,
                                        'Rent' as es_app_name
                                 FROM heap_rent_mobile_production.heap.all_events
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

{% elsif platform_app._parameter_value == 'analytics_app' %}
                                 SELECT event_id,
                                        time,
                                        user_id,
                                        session_id,
                                        event_table_name,
                                        'Analytics' as es_app_name
                                 FROM heap_t3_analytics_app_production.heap.all_events
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

{% elsif platform_app._parameter_value == 'all_apps' %}
select * from analytics.heap_adjunct.all_events

{% else %}
select * from analytics.heap_adjunct.all_events
{% endif %}
  ;;
}

  parameter: platform_app {
    type: unquoted
    default_value: "all_apps"
    allowed_value: {
      label: "Fleet, ELogs, Timecards Web"
      value: "t3_main"
    }
    allowed_value: {
      label: "Link"
      value: "link_app"
    }
    allowed_value: {
      label: "Rent"
      value: "rent_app"
    }
    allowed_value: {
      label: "Analytics"
      value: "analytics_app"
    }
    allowed_value: {
      label: "All Apps"
      value: "all_apps"
    }
  }

  dimension: event_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension: event_table_name {
    type: string
    sql: ${TABLE}."EVENT_TABLE_NAME" ;;
  }

  dimension: session_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension_group: time {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week_index,
      day_of_week,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."TIME" ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: es_app_name {
    type: string
    sql: ${TABLE}."ES_APP_NAME" ;;
  }

  dimension: is_value_action {
    type: yesno
    sql: ${event_table_name} not in ('pageviews', 'sessions') ;;
  }

  # - - - - - MEASURES - - - - -

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: value_action_count {
    type: count
    filters: [is_value_action: "yes"]
    drill_fields: [heap_users._email, event_table_name, count]
  }

  measure: session_length {
    type: number
    sql: timediff('minutes', min(${time_time}), max(${time_time})) ;;
  }

  measure: count_users {
    type: number
    sql: COUNT(DISTINCT ${user_id})  ;;
    drill_fields: [heap_users._email, companies.company_name, value_action_count]
  }


  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      event_table_name,
      count
    ]
  }
}
