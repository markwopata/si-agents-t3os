view: pageviews {
derived_table: {
  sql:
{% if platform_app._parameter_value == 't3_main' %}
                                 SELECT user_id,
                                        event_id,
                                        session_id,
                                        time,
                                        landing_page,
                                        landing_page_hash,
                                        hash,
                                        path,
                                        title,
                                        device_type,
                                        browser,
                                        'Fleet, ELogs, Timecards Web' AS es_app_name
                                 FROM heap_main_production.heap.pageviews
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

{% elsif platform_app._parameter_value == 'link_app' %}
                                 SELECT user_id,
                                        event_id,
                                        session_id,
                                        time,
                                        landing_page,
                                        landing_page_hash,
                                        hash,
                                        path,
                                        title,
                                        device_type,
                                        browser,
                                        'Link' AS es_app_name
                                 FROM heap_link_production.heap.pageviews
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

{% elsif platform_app._parameter_value == 'rent_app' %}
                                 SELECT user_id,
                                        event_id,
                                        session_id,
                                        time,
                                        landing_page,
                                        landing_page_hash,
                                        hash,
                                        path,
                                        title,
                                        device_type,
                                        browser,
                                        'Rent' AS es_app_name
                                 FROM heap_rent_mobile_production.heap.pageviews
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE())

{% elsif platform_app._parameter_value == 'analytics_app' %}
                                 SELECT user_id,
                                        event_id,
                                        session_id,
                                        time,
                                        landing_page,
                                        landing_page_hash,
                                        hash,
                                        path,
                                        title,
                                        device_type,
                                        browser,
                                        'Analytics' AS es_app_name
                                 FROM heap_t3_analytics_app_production.heap.pageviews
                                 WHERE time >= DATEADD('month', -24, CURRENT_DATE()))

{% elsif platform_app._parameter_value == 'all_apps' %}
select * from analytics.heap_adjunct.pageviews

{% else %}
select * from analytics.heap_adjunct.pageviews
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

  dimension: browser {
    type: string
    sql: ${TABLE}."BROWSER" ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}."DEVICE_TYPE" ;;
  }

  dimension: event_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EVENT_ID" ;;
  }

  dimension: landing_page {
    type: string
    sql: ${TABLE}."LANDING_PAGE" ;;
  }

  dimension: landing_page_hash {
    type: string
    sql: ${TABLE}."LANDING_PAGE_HASH" ;;
  }

  dimension: path {
    type: string
    sql: ${TABLE}."PATH" ;;
  }

  dimension: hash {
    type: string
    sql: ${TABLE}."HASH" ;;
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

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
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

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      time_time,
      heap_users._email,
      session_id,
      device_type,
      landing_page,
      hash

    ]
  }
}
