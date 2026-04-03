
view: company_dashboard_sessions {
  derived_table: {
    sql: SELECT
          u.company_id AS company_id,
          u.company_name AS company_name,
          device_type,
          --_APP_NAME AS app_name,
          --dashboard_section,
          time,
          session_id,
          listagg(distinct coalesce(_APP_NAME, 'Not Assigned'), ', ') AS app_names,
          listagg(distinct coalesce(DASHBOARD_SECTION, 'Not Assigned'), ', ') AS dashboard_section
          --COUNT(DISTINCT session_id) AS dashboard_sections_visits
      FROM
          HEAP_T3_PLATFORM_PRODUCTION.HEAP.ANALYTICS_PAGE_LOAD_DASHBOARD AS e
          JOIN ANALYTICS.T3_ANALYTICS.HEAP_USER_IDENTITY_RESOLUTION AS u ON e.user_id = u.heap_user_id
      WHERE
          HEAP_USER_ID IS NOT NULL
          AND MIMIC_USER_FLAG = FALSE
          AND u.customer_support_user_flag = FALSE
          AND u.actor_usage_flag = FALSE
          AND COMPANY_ID <> 1854
      GROUP BY
      1,
      2,
      3,
      4,
      5;;
  }

  dimension_group: timeframe {
    type: time
    timeframes: [date, week, month]
    sql: ${TABLE}.time ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
  }

  dimension: app_names {
    hidden: yes
    type: string
    sql: ${TABLE}."APP_NAMES" ;;
  }

  dimension: dashboard_section {
    type: string
    sql: ${TABLE}."DASHBOARD_SECTION" ;;
  }

  dimension: session_id {
    type: number
    hidden: yes
    sql: ${TABLE}."SESSION_ID" ;;
  }

  dimension: device_type {
    type: string
    sql: ${TABLE}."DEVICE_TYPE" ;;
  }

  measure: list_app_names {
    type: list
    list_field: app_names
  }

  measure: list_dashboard_sections {
    type: list
    list_field: dashboard_section
  }

  measure: total_dashboard_sections_visits {
    type: count_distinct
    sql: ${TABLE}."SESSION_ID" ;;
  }

  set: detail {
    fields: [
        company_id,
  company_name,
  app_names,
  dashboard_section,
  total_dashboard_sections_visits
    ]
  }
}
