view: sessions {
  derived_table: {
    sql:
    {% if platform_app._parameter_value == 't3_main' %}
                                 SELECT user_id,
                                        event_id,
                                        session_id,
                                        time,
                                        'Fleet, ELogs, Timecards Web' AS es_app_name
                                 FROM heap_main_production.heap.sessions
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

    {% elsif platform_app._parameter_value == 'link_app' %}
                                 SELECT user_id,
                                        event_id,
                                        session_id,
                                        time,
                                        'Link' AS es_app_name
                                 FROM heap_link_production.heap.sessions
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

    {% elsif platform_app._parameter_value == 'rent_app' %}
                                 SELECT user_id,
                                        event_id,
                                        session_id,
                                        time,
                                        'Rent' AS es_app_name
                                 FROM heap_rent_mobile_production.heap.sessions
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

    {% elsif platform_app._parameter_value == 'analytics_app' %}
                                 SELECT user_id,
                                        event_id,
                                        session_id,
                                        time,
                                        'Analytics' AS es_app_name
                                 FROM heap_t3_analytics_app_production.heap.sessions
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

    {% elsif platform_app._parameter_value == 'all_apps' %}
    select * from analytics.heap_adjunct.sessions

    {% else %}
    select * from analytics.heap_adjunct.sessions
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

  parameter: time_scale {
    type: unquoted
    default_value: "week"
    allowed_value: {
      label: "Day"
      value: "day"
    }
    allowed_value: {
      label: "Week"
      value: "week"
    }
    allowed_value: {
      label: "Month"
      value: "month"
    }
  }

  dimension: session_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension: event_id {
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension_group: time {
    type: time
    convert_tz: no
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
    sql:
    {% if time_scale._parameter_value == 'day' %}
    ${TABLE}."TIME"
    {% elsif time_scale._parameter_value == 'week' %}
    date_trunc('week', ${TABLE}."TIME")
    {% elsif time_scale._parameter_value == 'month' %}
    date_trunc('month', ${TABLE}."TIME")
    {% else %}
    ${TABLE}."TIME"
    {% endif %}
    ;;
  }

  dimension: dynamic_date {
    type: date
    label_from_parameter: time_scale
    sql: ${time_date} ;;
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


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_last_30 {
    type: count
    filters: [time_date: "last 30 days"]
  }

  measure: count_60_31 {
    type: count
    filters: [time_date: "60 days ago for 29 days"]
  }

  measure: count_90_61 {
    type: count
    filters: [time_date: "90 days ago for 29 days"]
  }

  measure: count_last_60 {
    type: count
    filters: [time_date: "60 days ago"]
  }

  measure: count_last_90 {
    type: count
    filters: [time_date: "90 days ago"]
  }

  measure: most_recent_session {
    type: string
    sql: MAX(${time_date}) ;;
    html: {{rendered_value | date: "%b %-d, %Y" }};;
  }

  measure: first_session {
    type: string
    sql: MIN(${time_date}) ;;
    html: {{rendered_value | date: "%b %-d, %Y" }};;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      time_date,
      heap_users.email,
      count

    ]
  }
}
