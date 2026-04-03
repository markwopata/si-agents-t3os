
view: weekly_active_users {
  derived_table: {
    sql:
      SELECT
          DATE_TRUNC('week', pageview_time_local) AS week_start,
          CASE
              WHEN application_category = 'Fleet'
              AND application_surface = 'Map Page' THEN 'Map'
              WHEN application_category = 'Fleet'
              AND application_surface = 'Rentals Page' THEN 'Rentals'
              WHEN application_category = 'Fleet'
              AND application_surface ILIKE '%service%' THEN 'Service'
              WHEN application_category = 'Fleet'
              AND application_surface = 'Billing Page' THEN 'Billing'
              WHEN application_category IN ('Link ', 'E-Logs', 'Analytics', 'Time Cards') THEN application_category
              ELSE 'N/A'
          END AS product,
          a.mimic_user_flag AS mimic_users,
          COUNT(DISTINCT a.heap_user_id) AS active_users,
          COUNT(DISTINCT a.session_id) AS sessions
      FROM
          ANALYTICS.T3_ANALYTICS.FCT_HEAP_PAGEVIEWS AS a
          JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u
          ON a.heap_user_id = u.heap_user_id
      WHERE
          a.HEAP_USER_ID IS NOT NULL
          AND u.customer_support_user_flag = FALSE
          AND COMPANY_ID <> 1854
          AND application_category IN (
              'Link ',
              'Fleet',
              'E-Logs',
              'Analytics',
              'Time Cards'
          )
      GROUP BY
          1,
          2,
          3
      HAVING
          product != 'N/A';;

      # UNION ALL

      # SELECT
      #   'Analytics' AS product,
      #   DATE(a.time) AS event_date,
      #   COUNT(DISTINCT a.user_id) AS weekly_active_users
      # FROM
      #     HEAP_T3_PLATFORM_PRODUCTION.HEAP.ANALYTICS_BROWSER_LOAD_APP AS a
      #     JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.ANALYTICS_BROWSER_LOAD_APP AS b
      #     ON a.user_id = b.user_id
      #     AND b.time <= a.time
      #     AND b.time >= a.time - INTERVAL '7 DAY'
      #     JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u
      #     ON a.user_id = u.heap_user_id
      # WHERE
      #     HEAP_USER_ID IS NOT NULL
      #     AND MIMIC_USER_FLAG = FALSE
      #     AND u.customer_support_user_flag = FALSE
      #     AND u.actor_usage_flag = FALSE
      #     AND COMPANY_ID <> 1854
      # GROUP BY 1, 2

      # UNION ALL

      # SELECT
      #   CASE
      #     WHEN a.hash ILIKE '%#/assets%'    THEN 'Map'
      #     WHEN a.hash ILIKE '%#/rentals%'   THEN 'Rentals'
      #     WHEN a.hash ILIKE '%#/service%'   THEN 'Service'
      #     WHEN a.hash ILIKE '%#/billing%'   THEN 'Billing'
      #     WHEN a.hash ILIKE '%#/resources%' THEN 'Assets'
      #   END AS product,
      #   DATE(a.time) AS event_date,
      #   COUNT(DISTINCT a.user_id) AS daily_users,
      #   COUNT(DISTINCT a.session_id) AS daily_sessions
      # FROM
      #     HEAP_T3_PLATFORM_PRODUCTION.HEAP.FLEET_WEB_APP_PAGEVIEW_ANY AS a
      #     JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u
      #     ON a.user_id = u.heap_user_id
      # WHERE
      #     HEAP_USER_ID IS NOT NULL
      #     AND MIMIC_USER_FLAG = FALSE
      #     AND u.customer_support_user_flag = FALSE
      #     AND u.actor_usage_flag = FALSE
      #     AND COMPANY_ID <> 1854
      # GROUP BY 1, 2

      # UNION ALL

      # SELECT
      #   'Analytics' AS product,
      #   DATE(a.time) AS event_date,
      #   COUNT(DISTINCT a.user_id) AS daily_users,
      #   COUNT(DISTINCT a.session_id) AS daily_sessions

      # FROM
      #     HEAP_T3_PLATFORM_PRODUCTION.HEAP.ANALYTICS_BROWSER_LOAD_APP AS a
      #     JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u
      #     ON a.user_id = u.heap_user_id
      # WHERE
      #     HEAP_USER_ID IS NOT NULL
      #     AND MIMIC_USER_FLAG = FALSE
      #     AND u.customer_support_user_flag = FALSE
      #     AND u.actor_usage_flag = FALSE
      #     AND COMPANY_ID <> 1854
      # GROUP BY 1, 2

      # UNION ALL

      # SELECT
      #   'Link Mobile' AS product,
      #   DATE(a.time) AS event_date,
      #   COUNT(DISTINCT a.user_id) AS n_users
      # FROM
      #     HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_MOBILE_APP_LOAD_APP AS a
      #     JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.LINKAPP_MOBILE_APP_LOAD_APP AS b
      #     ON a.user_id = b.user_id
      #     AND b.time <= a.time
      #     AND b.time >= a.time - INTERVAL '7 DAY'
      #     JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u
      #     ON a.user_id = u.heap_user_id
      # WHERE
      #     HEAP_USER_ID IS NOT NULL
      #     AND MIMIC_USER_FLAG = FALSE
      #     AND u.customer_support_user_flag = FALSE
      #     AND u.actor_usage_flag = FALSE
      #     AND COMPANY_ID <> 1854
      # GROUP BY 1, 2

      # UNION ALL

      # SELECT
      #   'E-logs' AS product,
      #   DATE(a.time) AS event_date,
      #   COUNT(DISTINCT a.user_id) AS n_users
      # FROM
      #     HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_BROWSER_LOAD_APP AS a
      #     JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_BROWSER_LOAD_APP AS b
      #     ON a.user_id = b.user_id
      #     AND b.time <= a.time
      #     AND b.time >= a.time - INTERVAL '7 DAY'
      #     JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u
      #     ON a.user_id = u.heap_user_id
      # WHERE
      #     HEAP_USER_ID IS NOT NULL
      #     AND MIMIC_USER_FLAG = FALSE
      #     AND u.customer_support_user_flag = FALSE
      #     AND u.actor_usage_flag = FALSE
      #     AND COMPANY_ID <> 1854
      # GROUP BY 1, 2

      # UNION ALL

      # SELECT
      #   'Time Tracking' AS product,
      #   DATE(a.time) AS event_date,
      #   COUNT(DISTINCT a.user_id) AS n_users
      # FROM
      #     HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_BROWSER_LOAD_APP AS a
      #     JOIN HEAP_T3_PLATFORM_PRODUCTION.HEAP.E_LOGS_BROWSER_LOAD_APP AS b
      #     ON a.user_id = b.user_id
      #     AND b.time <= a.time
      #     AND b.time >= a.time - INTERVAL '7 DAY'
      #     JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u
      #     ON a.user_id = u.heap_user_id
      # WHERE
      #     HEAP_USER_ID IS NOT NULL
      #     AND MIMIC_USER_FLAG = FALSE
      #     AND u.customer_support_user_flag = FALSE
      #     AND u.actor_usage_flag = FALSE
      #     AND COMPANY_ID <> 1854
      # GROUP BY 1, 2
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: product {
    type: string
    sql: ${TABLE}."PRODUCT" ;;
  }

  dimension: mimic_users {
    type: yesno
    sql: ${TABLE}."MIMIC_USERS" ;;
  }

  dimension_group: week_start {
    type: time
    timeframes: [week]
    sql: ${TABLE}."WEEK_START" ;;
  }

  measure: active_users {
    type: sum
    sql: ${TABLE}."ACTIVE_USERS" ;;
  }

  measure: sessions {
    type: sum
    sql: ${TABLE}."SESSIONS" ;;
  }

  set: detail {
    fields: [
        product,
        active_users
    ]
  }
}
