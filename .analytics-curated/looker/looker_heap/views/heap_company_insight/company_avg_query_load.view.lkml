
view: company_avg_query_load {
  derived_table: {
    sql: SELECT
          'query_load' AS event,
          user_id,
          session_id,
          pageview_id,
          country,
          region,
          browser,
          browser_type,
          platform_type_os_,
          analytics_app_version,
          dashboard_section,
          dashboard_name,
          device_type,
          time,
          fetch_elapsed_milliseconds,
          path,
          domain,
          query
          -- ROUND(AVG(fetch_elapsed_milliseconds) / 1000) AS avg_query_load,
          -- ROUND(AVG(fetch_elapsed_milliseconds) / 1000) >= 5 AS avg_over_four_sec
      FROM
          HEAP_T3_PLATFORM_PRODUCTION.HEAP.CUSTOM_EVENTS_ANALYTICS_DASHBOARD_LOAD_VIEW AS e
          JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u ON e.user_id = u.heap_user_id
      WHERE
          HEAP_USER_ID IS NOT NULL
          AND MIMIC_USER_FLAG = FALSE
          AND u.customer_support_user_flag = FALSE
          AND u.actor_usage_flag = FALSE
          AND COMPANY_ID <> 1854;;
  }

  dimension_group: timeframe {
    type: time
    timeframes: [raw, date, week, month, day_of_week, quarter, year]
    sql: ${TABLE}.time ;;
  }

  dimension: dashboard_section {
    type: string
    sql: ${TABLE}."DASHBOARD_SECTION" ;;
  }

  dimension: dashboard_name {
    type: string
    sql: ${TABLE}."DASHBOARD_NAME" ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}."DEVICE_TYPE" ;;
  }

  dimension: user_id {
    type: string
    primary_key: yes
    sql:  ${TABLE}."USER_ID" ;;
  }

  dimension: session_id {
    type: string
    hidden: yes
    sql:  ${TABLE}."SESSION_ID" ;;
  }

  dimension: pageview_id {
    type: string
    hidden: yes
    sql:  ${TABLE}."PAGEVIEW_ID" ;;
  }

  dimension: country {
    type: string
    sql:  ${TABLE}."COUNTRY" ;;
  }

  dimension: region {
    type: string
    sql:  ${TABLE}."REGION" ;;
  }

  dimension: browser {
    type: string
    sql:  ${TABLE}."BROWSER" ;;
  }

  dimension: browser_type {
    type: string
    sql:  ${TABLE}."BROWSER_TYPE" ;;
  }

  dimension: platform_type_os {
    type: string
    sql:  ${TABLE}."PLATFORM_TYPE_OS_" ;;
  }

  dimension: analytics_app_version {
    type: string
    sql:  ${TABLE}."ANALYTICS_APP_VERSION" ;;
  }

  dimension: path {
    type: string
    sql: ${TABLE}."PATH" ;;
  }

  dimension: domain {
    type: string
    sql: ${TABLE}."DOMAIN" ;;
  }

  dimension: query {
    type: string
    sql: ${TABLE}."QUERY" ;;
  }

  dimension: duration {
    type: number
    value_format: "#.##"
    hidden: yes
    sql: (${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000;;
  }

  dimension: duration_distribution {
    type: string
    sql:
      CASE
        WHEN ${duration} < 1 THEN '0 – 1 (sec)'
        WHEN ${duration} BETWEEN 1 AND 5 THEN '1 – 5 (sec)'
        WHEN ${duration} BETWEEN 5 AND 10 THEN '5 - 10 (sec)'
        ELSE '> 10 (sec)'
      END
    ;;
    order_by_field: duration_distribution_ordering
  }


  dimension: duration_distribution_ordering {
    type: number
    sql: CASE WHEN ${duration_distribution} = '0 – 1 (sec)' THEN 1
            WHEN ${duration_distribution} = '1 – 5 (sec)' THEN 2
            WHEN ${duration_distribution} = '5 - 10 (sec)' THEN 3
            ELSE 4 END ;;
    hidden: yes
    description: "This dimension is used to force sort the duration_distribution dimension."
  }

  measure: total_users {
    type: count_distinct
    hidden: yes
    sql: ${TABLE}."USER_ID" ;;
    filters: [period_filtered_measures: "this"]
  }

  measure: total_sessions {
    type: count_distinct
    hidden: yes
    sql: ${TABLE}."SESSION_ID" ;;
    filters: [period_filtered_measures: "this"]
  }

  measure: total_sessions_per_users {
    type: number
    hidden: yes
    value_format: "#.##"
    sql: ${total_sessions}/ NULLIF(${total_users},0) ;;
  }

  measure: total_query_load_sec {
    type: sum
    label: "Total Query Load (sec)"
    value_format: "#.##"
    sql: (${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000 ;;
    filters: [period_filtered_measures: "this"]
  }

  measure: total_query_load_events {
    type: count
    filters: [period_filtered_measures: "this"]
  }

  measure: total_query_load_events_pop {
    type: count
  }

  measure: avg_query_load_sec {
    type: average
    label: "Average Query Load (sec)"
    value_format: "#.##"
    sql: (${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000 ;;
    filters: [period_filtered_measures: "this"]

    link: {
      label: "Triage Duration Distribution Buckets"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.duration_distribution,
      company_avg_query_load.total_users,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &sorts=company_avg_query_load.duration_distribution"
    }

    link: {
      label: "Triage Top Dashboard Sections"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.dashboard_section,
      company_avg_query_load.dashboard_name,
      company_avg_query_load.high_query_load_users,
      company_avg_query_load.slow_query_percentage,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p99_query_load_sec,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &f[company_avg_query_load.query_load_greater_than_n]=>1
      &sorts=company_avg_query_load.high_query_load_users desc, company_avg_query_load.slow_query_percentage desc, company_avg_query_load.p95_query_load_sec desc, company_avg_query_load.total_query_load_events desc"
    }
  }

  measure: avg_greater_than_n {
    type: yesno
    label: "Average Greater Than Four Sec"
    sql: (${avg_query_load_sec}) >= 5 ;;
    html:
    {% if value == 'No' %}
    <p style="color: black; background-color: lightgreen;">{{ value }}</p>
    {% else %}
    <p style="color: white; background-color: red;">{{ value }}</p>
    {% endif %}
    ;;
  }

  measure: p90_query_load_sec {
    type: percentile
    label: "P90 Query Load (sec)"
    percentile: 90
    value_format: "#.##"
    sql: (${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000 ;;
    filters: [period_filtered_measures: "this"]

    link: {
      label: "Triage Duration Distribution Buckets"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.duration_distribution,
      company_avg_query_load.total_users,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &sorts=company_avg_query_load.duration_distribution"
    }

    link: {
      label: "Triage Top Dashboard Sections"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.dashboard_section,
      company_avg_query_load.dashboard_name,
      company_avg_query_load.high_query_load_users,
      company_avg_query_load.slow_query_percentage,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p99_query_load_sec,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &f[company_avg_query_load.query_load_greater_than_n]=>1
      &sorts=company_avg_query_load.high_query_load_users desc, company_avg_query_load.slow_query_percentage desc, company_avg_query_load.p95_query_load_sec desc, company_avg_query_load.total_query_load_events desc"
    }
  }

  measure: p95_query_load_sec {
    type: percentile
    label: "P95 Query Load (sec)"
    percentile: 95
    value_format: "#.##"
    sql: (${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000 ;;
    filters: [period_filtered_measures: "this"]

    link: {
      label: "Triage Duration Distribution Buckets"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.duration_distribution,
      company_avg_query_load.total_users,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &sorts=company_avg_query_load.duration_distribution"
    }

    link: {
      label: "Triage Top Dashboard Sections"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.dashboard_section,
      company_avg_query_load.dashboard_name,
      company_avg_query_load.high_query_load_users,
      company_avg_query_load.slow_query_percentage,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p99_query_load_sec,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &f[company_avg_query_load.query_load_greater_than_n]=>1
      &sorts=company_avg_query_load.high_query_load_users desc, company_avg_query_load.slow_query_percentage desc, company_avg_query_load.p95_query_load_sec desc, company_avg_query_load.total_query_load_events desc"
    }
  }

  # measure: p95_query_load_sec_previous_period {
  #   type: period_over_period
  #   description: "Query load over the previous period"
  #   based_on: p95_query_load_sec
  #   based_on_time: timeframe_date
  #   period: date
  #   kind: previous
  #   label: "P95 Query Load Previous Period"
  #   value_format: "#.##"
  # }

  measure: p99_query_load_sec {
    type: percentile
    label: "P99 Query Load (sec)"
    percentile: 99
    value_format: "#.##"
    sql: (${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000 ;;
    filters: [period_filtered_measures: "this"]

    link: {
      label: "Triage Duration Distribution Buckets"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.duration_distribution,
      company_avg_query_load.total_users,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &sorts=company_avg_query_load.duration_distribution"
    }

    link: {
      label: "Triage Top Dashboard Sections"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.dashboard_section,
      company_avg_query_load.dashboard_name,
      company_avg_query_load.high_query_load_users,
      company_avg_query_load.slow_query_percentage,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p99_query_load_sec,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &f[company_avg_query_load.query_load_greater_than_n]=>1
      &sorts=company_avg_query_load.high_query_load_users desc, company_avg_query_load.slow_query_percentage desc, company_avg_query_load.p95_query_load_sec desc, company_avg_query_load.total_query_load_events desc"
    }
  }

  measure: query_load_greater_than_n {
    type: sum
    label: "Count Query Load ≥ 5 sec"
    sql: CASE
          WHEN ((${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000) >= 5 THEN 1
          ELSE NULL
        END ;;
    filters: [period_filtered_measures: "this"]
  }

  measure: pop_query_load_greater_than_n {
    type: sum
    label: "Count Query Load ≥ 5 sec"
    sql: CASE
          WHEN ((${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000) >= 5 THEN 1
          ELSE NULL
        END ;;
    hidden: yes
  }

  measure: prev_query_load_greater_than_n {
    type: sum
    label: "Count Query Load ≥ 5 sec - Previous Period"
    sql: CASE
          WHEN ((${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000) >= 5 THEN 1
          ELSE NULL
        END ;;
    filters: [period_filtered_measures: "last"]
  }

  measure: query_load_lower_than_n {
    type: sum
    label: "Count Query Load < 5 sec"
    sql: CASE
          WHEN ((${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000) < 5 THEN 1
          ELSE NULL
        END ;;
    filters: [period_filtered_measures: "this"]
  }

  measure: pop_query_load_lower_than_n {
    type: sum
    label: "Count Query Load < 5 sec"
    sql: CASE
          WHEN ((${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000) < 5 THEN 1
          ELSE NULL
        END ;;
    hidden: yes
  }

  measure: prev_query_load_lower_than_n {
    type: sum
    label: "Count Query Load < 5 sec - Previous Period"
    sql: CASE
          WHEN ((${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000) < 5 THEN 1
          ELSE NULL
        END ;;
    filters: [period_filtered_measures: "last"]
  }

  measure: high_query_load_users {
    type: count_distinct
    label: "Impacted Users with Query Load ≥ 5 sec"
    sql: CASE
          WHEN ((${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000) >= 5 THEN ${user_id}
          ELSE NULL
        END ;;
    filters: [period_filtered_measures: "this"]

    link: {
      label: "Triage Duration Distribution Buckets"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.duration_distribution,
      company_avg_query_load.total_users,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &sorts=company_avg_query_load.duration_distribution"
    }

    link: {
      label: "Triage Top Dashboard Sections"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.dashboard_section,
      company_avg_query_load.dashboard_name,
      company_avg_query_load.high_query_load_users,
      company_avg_query_load.slow_query_percentage,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p99_query_load_sec,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &f[company_avg_query_load.query_load_greater_than_n]=>1
      &sorts=company_avg_query_load.high_query_load_users desc, company_avg_query_load.slow_query_percentage desc, company_avg_query_load.p95_query_load_sec desc, company_avg_query_load.total_query_load_events desc"
    }
  }

  measure: slow_query_percentage {
    type: number
    value_format_name: percent_2
    sql: COALESCE((${query_load_greater_than_n}) / NULLIF(${query_load_greater_than_n} + ${query_load_lower_than_n}, 0), 0) ;;

    link: {
      label: "Triage Duration Distribution Buckets"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.duration_distribution,
      company_avg_query_load.total_users,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &sorts=company_avg_query_load.duration_distribution"
    }

    link: {
      label: "Triage Top Dashboard Sections"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.dashboard_section,
      company_avg_query_load.dashboard_name,
      company_avg_query_load.high_query_load_users,
      company_avg_query_load.slow_query_percentage,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p99_query_load_sec,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &f[company_avg_query_load.query_load_greater_than_n]=>1
      &sorts=company_avg_query_load.high_query_load_users desc, company_avg_query_load.slow_query_percentage desc, company_avg_query_load.p95_query_load_sec desc, company_avg_query_load.total_query_load_events desc"
    }

    link: {
      label: "Show time series "
      url: "
      {% assign vis_config = '{
      \"type\": \"looker_line\",
      \"stacking\": \"\",
      \"show_value_labels\": false,
      \"label_density\": 25,
      \"legend_position\": \"center\",
      \"x_axis_gridlines\": true,
      \"y_axis_gridlines\": true,
      \"show_view_names\": false,
      \"limit_displayed_rows\": false,
      \"y_axis_combined\": true,
      \"show_y_axis_labels\": true,
      \"show_y_axis_ticks\": true,
      \"y_axis_tick_density\": \"default\",
      \"y_axis_tick_density_custom\": 5,
      \"show_x_axis_label\": false,
      \"show_x_axis_ticks\": true,
      \"x_axis_scale\": \"auto\",
      \"y_axis_scale_mode\": \"linear\",
      \"show_null_points\": true,
      \"show_null_labels\": false,
      \"show_totals_labels\": false,
      \"show_silhouette\": false,
      \"interpolation\": \"linear\",
      \"series_types\": {},
      \"colors\": [\"palette: EquipmentShare\"],
      \"series_colors\": {},
      \"x_axis_datetime_tick_count\": null,
      \"trend_lines\": [
      {
      \"color\" : \"#000000\",
      \"label_position\" : \"left\",
      \"period\" : 7,
      \"regression_type\" : \"average\",
      \"series_index\" : 1,
      \"show_label\" : true,
      \"label_type\" : \"string\",
      \"label\" : \"7 day moving average\"
      }
     ]
    }' %}
      https://equipmentshare.looker.com/explore/heap_t3_platform/company_avg_query_load?fields=company_avg_query_load.date_in_period_date,company_avg_query_load.slow_query_percentage&sorts=company_avg_query_load.date_in_period_date&f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]=after%20last%20quarter
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}&vis_config={{ vis_config | encode_uri }}&toggle=dat,pik,vis&limit=5000"
    }
  }

  measure: previous_slow_query_percentage {
    type: number
    value_format_name: percent_2
    sql: COALESCE((${prev_query_load_greater_than_n}) / NULLIF(${prev_query_load_greater_than_n} + ${prev_query_load_lower_than_n}, 0), 0) ;;

    link: {
      label: "Triage Duration Distribution Buckets"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.duration_distribution,
      company_avg_query_load.total_users,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &sorts=company_avg_query_load.duration_distribution"
    }

    link: {
      label: "Triage Top Dashboard Sections"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.dashboard_section,
      company_avg_query_load.dashboard_name,
      company_avg_query_load.high_query_load_users,
      company_avg_query_load.slow_query_percentage,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p99_query_load_sec,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &f[company_avg_query_load.query_load_greater_than_n]=>1
      &sorts=company_avg_query_load.high_query_load_users desc, company_avg_query_load.slow_query_percentage desc, company_avg_query_load.p95_query_load_sec desc, company_avg_query_load.total_query_load_events desc"
    }

    link: {
      label: "View daily trend"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.date_in_period_date,company_avg_query_load.slow_query_percentage&sorts=company_avg_query_load.date_in_period_date"
    }
  }

  measure: full_slow_query_percentage {
    type: number
    value_format_name: percent_2
    sql: COALESCE((${pop_query_load_greater_than_n}) / NULLIF(${pop_query_load_greater_than_n} + ${pop_query_load_lower_than_n}, 0), 0) ;;
  }

  measure: last_year_slow_query_percentage {
    type: number
    value_format_name: percent_2
    sql: COALESCE((${pop_query_load_greater_than_n}) / NULLIF(${pop_query_load_greater_than_n} + ${pop_query_load_lower_than_n}, 0), 0) ;;
  }



  filter: current_date_range {
    type: date
    label: "1. Current Date Range"
    description: "Select the current date range you are interested in. Make sure any other filter on Event Date covers this period, or is removed."
    sql: ${period} IS NOT NULL ;;
  }

  parameter: compare_to {
    description: "Select the templated previous period you would like to compare to. Must be used with Current Date Range filter"
    label: "2. Compare To:"
    type: unquoted
    allowed_value: {
      label: "Previous Period"
      value: "Period"
    }
    allowed_value: {
      label: "Previous Week"
      value: "Week"
    }
    allowed_value: {
      label: "Previous Month"
      value: "Month"
    }
    allowed_value: {
      label: "Previous Quarter"
      value: "Quarter"
    }
    allowed_value: {
      label: "Previous Year"
      value: "Year"
    }
    default_value: "Period"
  }

  ## ------------------ HIDDEN HELPER DIMENSIONS  ------------------ ##

  dimension: days_in_period {
    hidden:  yes
    view_label: "_PoP"
    description: "Gives the number of days in the current period date range"
    type: number
    sql: DATEDIFF(DAY, DATE({% date_start current_date_range %}), DATE({% date_end current_date_range %})) ;;
  }

  dimension: period_2_start {
    hidden:  yes
    view_label: "_PoP"
    description: "Calculates the start of the previous period"
    type: date
    sql:
            {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -${days_in_period}, DATE({% date_start current_date_range %}))
            {% else %}
            DATEADD({% parameter compare_to %}, -1, DATE({% date_start current_date_range %}))
            {% endif %};;
  }

  dimension: period_2_end {
    hidden:  yes
    view_label: "_PoP"
    description: "Calculates the end of the previous period"
    type: date
    sql:
            {% if compare_to._parameter_value == "Period" %}
            DATEADD(DAY, -1, DATE({% date_start current_date_range %}))
            {% else %}
            DATEADD({% parameter compare_to %}, -1, DATEADD(DAY, -1, DATE({% date_end current_date_range %})))
            {% endif %};;
  }

  dimension: day_in_period {
    hidden: yes
    description: "Gives the number of days since the start of each period. Use this to align the event dates onto the same axis, the axes will read 1,2,3, etc."
    type: number
    sql:
        {% if current_date_range._is_filtered %}
            CASE
            WHEN {% condition current_date_range %} ${timeframe_raw} {% endcondition %}
            THEN DATEDIFF(DAY, DATE({% date_start current_date_range %}), ${timeframe_date}) + 1
            WHEN ${timeframe_date} between ${period_2_start} and ${period_2_end}
            THEN DATEDIFF(DAY, ${period_2_start}, ${timeframe_date}) + 1
            END
        {% else %} NULL
        {% endif %}
        ;;
  }

  dimension: order_for_period {
    hidden: yes
    type: number
    sql:
            {% if current_date_range._is_filtered %}
                CASE
                WHEN {% condition current_date_range %} ${timeframe_raw} {% endcondition %}
                THEN 1
                WHEN ${timeframe_date} between ${period_2_start} and ${period_2_end}
                THEN 2
                END
            {% else %}
                NULL
            {% endif %}
            ;;
  }

  ## ------- HIDING FIELDS  FROM ORIGINAL VIEW FILE  -------- ##

  dimension_group: created {hidden: yes}
  dimension: ytd_only {hidden:yes}
  dimension: mtd_only {hidden:yes}
  dimension: wtd_only {hidden:yes}

  ## ------------------ DIMENSIONS TO PLOT ------------------ ##

  dimension_group: date_in_period {
    description: "Use this as your grouping dimension when comparing periods. Aligns the previous periods onto the current period"
    label: "Current Period"
    type: time
    sql: DATEADD(DAY, ${day_in_period} - 1, DATE({% date_start current_date_range %})) ;;
    timeframes: [
      date,
      month,
      week,
      month_name,
      month_num,
      quarter,
      year]
  }

  dimension: period {
    label: "Period"
    description: "Pivot me! Returns the period the metric covers, i.e. either the 'This Period' or 'Previous Period'"
    type: string
    order_by_field: order_for_period
    sql:
            {% if current_date_range._is_filtered %}
                CASE
                WHEN {% condition current_date_range %} ${timeframe_raw} {% endcondition %}
                THEN 'This {% parameter compare_to %}'
                WHEN ${timeframe_date} between ${period_2_start} and ${period_2_end}
                THEN 'Last {% parameter compare_to %}'
                END
            {% else %}
                NULL
            {% endif %}
            ;;
  }

  ## ---------------------- TO CREATE FILTERED MEASURES ---------------------------- ##

  dimension: period_filtered_measures {
    hidden: yes
    description: "We just use this for the filtered measures"
    type: string
    sql:
            {% if current_date_range._is_filtered %}
                CASE
                WHEN {% condition current_date_range %} ${timeframe_raw} {% endcondition %} THEN 'this'
                WHEN ${timeframe_date} between ${period_2_start} and ${period_2_end} THEN 'last' END
            {% else %} NULL {% endif %} ;;
  }

  # Filtered measures

  measure: current_period_load {
    type: percentile
    label: "P95 Query Load (sec) Current Period"
    percentile: 95
    value_format: "#.##"
    sql: (${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000 ;;
    filters: [period_filtered_measures: "this"]

    link: {
      label: "Triage Duration Distribution Buckets"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.duration_distribution,
      company_avg_query_load.total_users,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &sorts=company_avg_query_load.duration_distribution"
    }

    link: {
      label: "Triage Top Dashboard Sections"
      url: "/explore/heap_t3_platform/company_avg_query_load?fields=
      company_avg_query_load.dashboard_section,
      company_avg_query_load.dashboard_name,
      company_avg_query_load.high_query_load_users,
      company_avg_query_load.slow_query_percentage,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p95_query_load_sec,
      company_avg_query_load.p99_query_load_sec,
      company_avg_query_load.total_query_load_events
      &f[company_avg_query_load.date_in_period_date]={{ row['company_avg_query_load.date_in_period_date'] | url_encode }}
      &f[company_avg_query_load.current_date_range]={{ _filters['company_avg_query_load.current_date_range'] | url_encode }}
      &f[company_avg_query_load.device_type]={{ _filters['company_avg_query_load.device_type'] | url_encode }}
      &f[company_avg_query_load.browser_type]={{ _filters['company_avg_query_load.browser_type'] | url_encode }}
      &f[company_avg_query_load.region]={{ _filters['company_avg_query_load.region'] | url_encode }}
      &f[company_avg_query_load.query_load_greater_than_n]=>1
      &sorts=company_avg_query_load.high_query_load_users desc, company_avg_query_load.slow_query_percentage desc, company_avg_query_load.p95_query_load_sec desc, company_avg_query_load.total_query_load_events desc"
    }
  }

  measure: previous_period_load {
    type: percentile
    label: "P95 Query Load (sec) - Previous Period"
    percentile: 95
    value_format: "#.##"
    sql: (${TABLE}."FETCH_ELAPSED_MILLISECONDS")/1000 ;;
    filters: [period_filtered_measures: "last"]
  }

  measure: load_pop_percentage_change {
    label: "Total query period-over-period % change"
    type: number
    sql: CASE WHEN ${current_period_load} = 0
                THEN NULL
                ELSE (1.0 * ${current_period_load} / NULLIF(${previous_period_load} ,0)) - 1 END ;;
    value_format_name: percent_2
  }

  measure: load_pop_change {
    label: "Total query period-over-period Δ change"
    type: number
    sql: CASE WHEN ${current_period_load} = 0
                THEN NULL
                ELSE (${current_period_load} - NULLIF(${previous_period_load} ,0)) END ;;
    value_format: "#.##"
  }

  measure: slow_query_percentage_pop_change {
    label: "Slow query percentage period-over-period Δ change"
    type: number
    sql: CASE WHEN ${slow_query_percentage} = 0
                THEN NULL
                ELSE (${slow_query_percentage} - NULLIF(${previous_slow_query_percentage} ,0)) END ;;
    value_format_name: percent_2
  }



  set: detail {
    fields: [
        dashboard_section,
  dashboard_name,
  device_type,
  total_query_load_sec
    ]
  }

  set: spike_drill_fields {
    fields: [
      timeframe_date,
      dashboard_section,
      dashboard_name,
      high_query_load_users,
      slow_query_percentage,
      p95_query_load_sec,
      p99_query_load_sec,
      total_query_load_events
    ]
  }
}
