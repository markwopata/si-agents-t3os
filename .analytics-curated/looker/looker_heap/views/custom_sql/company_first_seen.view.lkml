view: company_first_seen {
  derived_table: {
    sql:
{% if platform_app._parameter_value == 't3_main' %}
SELECT
         hu.company_id,
         s.es_app_name,
        {% if time_scale._parameter_value == 'day' %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'week' %}
         DATE_TRUNC('week', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('week', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'month' %}
         DATE_TRUNC('month', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('month', MAX(s.time::date)) AS last_session,
        {% else %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% endif %}
         COUNT(DISTINCT s.session_id)   AS total_sessions
  FROM heap_main_production.heap.users hu
       INNER JOIN heap_main_production.heap.sessions s
                  ON hu.user_id = s.user_id
 GROUP BY hu.company_id, s.es_app_name

{% elsif platform_app._parameter_value == 'link_app' %}
SELECT
         hu.company_id,
         s.es_app_name,
        {% if time_scale._parameter_value == 'day' %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'week' %}
         DATE_TRUNC('week', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('week', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'month' %}
         DATE_TRUNC('month', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('month', MAX(s.time::date)) AS last_session,
        {% else %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% endif %}
         COUNT(DISTINCT s.session_id)   AS total_sessions
  FROM heap_link_production.heap.users hu
       INNER JOIN heap_link_production.heap.sessions s
                  ON hu.user_id = s.user_id
 GROUP BY hu.company_id, s.es_app_name

{% elsif platform_app._parameter_value == 'rent_app' %}
SELECT
         hu.company_id,
         s.es_app_name,
        {% if time_scale._parameter_value == 'day' %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'week' %}
         DATE_TRUNC('week', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('week', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'month' %}
         DATE_TRUNC('month', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('month', MAX(s.time::date)) AS last_session,
        {% else %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% endif %}
         COUNT(DISTINCT s.session_id)   AS total_sessions
  FROM heap_rent_mobile_production.heap.users hu
       INNER JOIN heap_rent_mobile_production.heap.sessions s
                  ON hu.user_id = s.user_id
 GROUP BY hu.company_id, s.es_app_name

{% elsif platform_app._parameter_value == 'analytics_app' %}
SELECT
         hu.company_id,
         s.es_app_name,
        {% if time_scale._parameter_value == 'day' %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'week' %}
         DATE_TRUNC('week', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('week', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'month' %}
         DATE_TRUNC('month', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('month', MAX(s.time::date)) AS last_session,
        {% else %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% endif %}
         COUNT(DISTINCT s.session_id)   AS total_sessions
  FROM heap_t3_analytics_app_production.heap.users hu
       INNER JOIN heap_t3_analytics_app_production.heap.sessions s
                  ON hu.user_id = s.user_id
 GROUP BY hu.company_id, s.es_app_name

{% elsif platform_app._parameter_value == 'all_apps' %}
SELECT
         hu.company_id,
         s.es_app_name,
        {% if time_scale._parameter_value == 'day' %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'week' %}
         DATE_TRUNC('week', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('week', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'month' %}
         DATE_TRUNC('month', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('month', MAX(s.time::date)) AS last_session,
        {% else %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% endif %}
         COUNT(DISTINCT s.session_id)   AS total_sessions
  FROM analytics.heap_adjunct.heap_users hu
       INNER JOIN analytics.heap_adjunct.sessions s
                  ON hu.user_id = s.user_id
 GROUP BY hu.company_id, s.es_app_name

{% else %}
  SELECT
         hu.company_id,
         s.es_app_name,
        {% if time_scale._parameter_value == 'day' %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'week' %}
         DATE_TRUNC('week', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('week', MAX(s.time::date)) AS last_session,
        {% elsif time_scale._parameter_value == 'month' %}
         DATE_TRUNC('month', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('month', MAX(s.time::date)) AS last_session,
        {% else %}
         DATE_TRUNC('day', MIN(s.time::date)) AS first_session,
         DATE_TRUNC('day', MAX(s.time::date)) AS last_session,
        {% endif %}
         COUNT(DISTINCT s.session_id)   AS total_sessions
    FROM analytics.heap_adjunct.sessions s
         INNER JOIN analytics.heap_adjunct.heap_users hu
                    ON hu.user_id = s.user_id
   GROUP BY hu.company_id, s.es_app_name
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

  dimension: pkey {
    type: string
    primary_key: yes
    hidden: yes
    sql: ${company_id}||${es_app_name} ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: first_session {
    type: time
    # convert_tz: no
    timeframes: [raw, time, date, week, month, year, day_of_week_index]
    sql: ${TABLE}."FIRST_SESSION" ;;
  }

  dimension_group: last_session {
    type: time
    # convert_tz: no
    timeframes: [raw, time, date, week, month, year, day_of_week_index]
    sql: ${TABLE}."LAST_SESSION" ;;
  }

  dimension: sessions {
    type: number
    sql: ${TABLE}."TOTAL_SESSIONS" ;;
  }

  dimension: es_app_name {
    type: string
    sql: ${TABLE}."ES_APP_NAME" ;;
  }

  measure: first_session_min {
    # convert_tz: no
    sql: MIN(${first_session_date}) ;;
  }

  measure: last_session_max {
    # convert_tz: no
    sql: MAX(${last_session_date}) ;;
  }

  measure: total_sessions {
    type: sum
    sql: ${sessions} ;;
    # drill_fields: [companies.name_with_id, sessions.es_app_name, sessions.count]
  }

  measure: count_companies {
    type: count_distinct
    sql: ${company_id} ;;
    drill_fields: [companies.name_with_id, es_app_name, first_session_date]
  }

  # measure: count_users {
  #   type: count_distinct
  #   sql: ${user_id} ;;
  #   drill_fields: [heap_users.email, first_session_date, sessions.es_app_name, sessions.count]
  # }
}
