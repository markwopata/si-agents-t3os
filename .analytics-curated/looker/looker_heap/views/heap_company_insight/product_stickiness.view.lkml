
view: product_stickiness {
  derived_table: {
    sql:
      WITH daily_activity AS (
          SELECT
              pageview_time_local::DATE AS activity_date,
              DATE_TRUNC('week', pageview_time_local) AS week_start,
              DATE_TRUNC('month', pageview_time_local) AS month_start,
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
              a.heap_user_id,
              a.session_id
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
      ),
      weekly_metrics AS (
          SELECT
              week_start,
              product,
              mimic_users,
              COUNT(DISTINCT heap_user_id) AS weekly_active_users,
              COUNT(DISTINCT session_id) AS weekly_sessions
          FROM daily_activity
          WHERE product != 'N/A'
          GROUP BY 1, 2, 3
      ),
      monthly_metrics AS (
          SELECT
              month_start,
              product,
              mimic_users,
              COUNT(DISTINCT heap_user_id) AS monthly_active_users,
              COUNT(DISTINCT session_id) AS monthly_sessions
          FROM daily_activity
          WHERE product != 'N/A'
          GROUP BY 1, 2, 3
      )
      SELECT
          w.week_start,
          m.month_start,
          w.product,
          w.mimic_users,
          w.weekly_active_users,
          w.weekly_sessions,
          m.monthly_active_users,
          m.monthly_sessions
      FROM weekly_metrics AS w
      JOIN monthly_metrics AS m
          ON w.product = m.product
          AND w.mimic_users = m.mimic_users
          AND m.month_start = DATE_TRUNC('month', w.week_start)
    ;;
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

  dimension_group: month_start {
    type: time
    timeframes: [month]
    sql: ${TABLE}."MONTH_START" ;;
  }

  measure: weekly_active_users {
    type: sum
    sql: ${TABLE}."WEEKLY_ACTIVE_USERS" ;;
  }

  measure: weekly_sessions {
    type: sum
    sql: ${TABLE}."WEEKLY_SESSIONS" ;;
  }

  measure: monthly_active_users {
    type: sum
    sql: ${TABLE}."MONTHLY_ACTIVE_USERS" ;;
  }

  measure: monthly_sessions {
    type: sum
    sql: ${TABLE}."MONTHLY_SESSIONS" ;;
  }

  measure: stickiness {
    type: number
    sql: ${weekly_active_users} / NULLIF(${monthly_active_users}, 0) ;;
    value_format: "0.0%"
  }

  set: detail {
    fields: [
        product,
        weekly_active_users,
        weekly_sessions,
        monthly_active_users,
        monthly_sessions
    ]
  }
}
