view: monthly_company_engagement {
  label: "Monthly Company Engagement"

  derived_table: {
    sql: SELECT
           MONTH,
           COMPANY_ID,
           COMPANY_NAME,
           IS_VIP,
           PARENT_COMPANY_ID,
           PARENT_COMPANY_NAME,
           COMPANY_COHORT_DATE,
           TENURE_IN_MONTHS,
           TOTAL_USERS,
           ACTIVE_USERS,
           ROUND(ACTIVE_USERS/NULLIF(TOTAL_USERS,0),2)            AS PRCNT_ACTIVE_USERS,
           NEW_USERS,
           AVG_USER_TENURE,
           MONTHLY_SESSION_TOTALS,
           MONTHLY_ACTIVE_SESSIONS,
           ROUND(MONTHLY_ACTIVE_SESSIONS/NULLIF(MONTHLY_SESSION_TOTALS,0),2)  AS PRCNT_ACTIVE_SESSIONS,
           MONTHLY_TIME_ON_PLATFORM_SECS,
           MONTHLY_ACTIVE_TIME_SECS,
           ROUND(MONTHLY_ACTIVE_TIME_SECS/NULLIF(MONTHLY_TIME_ON_PLATFORM_SECS,0),2) AS PRCNT_SESSION_TIME_ACTIVE,
           AVG_ACTIVE_TIME_SECS_PER_SESSION,
           FIRST_SESSION_FOR_MONTH,
           LAST_SESSION_FOR_MONTH,
           MOST_FREQUENT_SESSION_CATEGORY,
           SESSION_CATEGORY_FREQUENCY,
           ROUND(SESSION_CATEGORY_FREQUENCY/NULLIF(MONTHLY_SESSION_TOTALS,0),2) AS PRCNT_SESSION_CATEGORY_SESSIONS,
           SESSION_CATEGORY_USERS,
           ROUND(SESSION_CATEGORY_USERS/NULLIF(TOTAL_USERS,0),2) AS PRCNT_SESSION_CATEGORY_USERS,
           AVG_SESSION_CATEGORY_ACTIVE_SECS,
           AVG_SESSION_CATEGORY_DURATION_SECS,
           MOST_FREQUENT_PAGE_CATEGORY,
           PAGE_CATEGORY_FREQUENCY,
           PAGE_CATEGORY_USERS,
           ROUND(PAGE_CATEGORY_USERS/NULLIF(TOTAL_USERS,0),2)      AS PRCNT_PAGE_CATEGORY_USERS,
           AVG_PAGE_CATEGORY_DURATION_SECS,
           MOST_FREQUENT_CITY_STATE,
           LOCATION_FREQUENCY,
           LOCATION_USERS,
           ROUND(LOCATION_USERS/NULLIF(TOTAL_USERS,0),2)           AS PRCNT_LOCATION_USERS,
           MOST_FREQUENT_DEVICE_TYPE,
           DEVICE_FREQUENCY,
           DEVICE_USERS,
           ROUND(DEVICE_USERS/NULLIF(TOTAL_USERS,0),2)             AS PRCNT_DEVICE_USERS,
           TOP_EVENT_1,
           TOP_EVENT_2,
           TOP_EVENT_3,
           TOP_EVENT_4,
           TOP_EVENT_5,
           INTERCOM_SESSION_COUNT,
           INTERCOM_SESSION_USER_COUNT,
           CUSTOMER_SUPPORT_SESSION_COUNT,
           MONTHLY_COMPANY_RANK,
          UID
         FROM ANALYTICS.T3_ANALYTICS.MONTHLY_COMPANY_ENGAGEMENT ;;
  }

  ###########################
  # Dimensions: Identifiers #
  ###########################

  dimension: uid {
    type: string
    sql: ${TABLE}.uid;;
    description: "Unique month key combining Company ID, and Month."
    hidden: yes
    primary_key: yes
  }

  dimension_group: month {
    type: time
    timeframes: [ month, quarter, year]
    sql: ${TABLE}."MONTH" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
    label: "Company ID"
    group_label: "Identifiers"
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    label: "Company Name"
    group_label: "Identifiers"
  }

  dimension: is_vip {
    type: yesno
    sql: ${TABLE}."IS_VIP" ;;
    label: "VIP?"
    group_label: "Identifiers"
  }

  dimension: parent_company_id {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_ID" ;;
    label: "Parent Company ID"
    group_label: "Identifiers"
  }

  dimension: parent_company_name {
    type: string
    sql: ${TABLE}."PARENT_COMPANY_NAME" ;;
    label: "Parent Company Name"
    group_label: "Identifiers"
  }

  ################################
  # Dimensions: Cohort & Tenure  #
  ################################

  dimension: company_cohort_date {
    type: date
    sql: ${TABLE}."COMPANY_COHORT_DATE" ;;
    label: "Cohort Date"
    group_label: "Cohort & Tenure"
  }

  dimension: tenure_in_months {
    type: number
    sql: ${TABLE}."TENURE_IN_MONTHS" ;;
    label: "Tenure (Months)"
    group_label: "Cohort & Tenure"
  }

  #################################
  # Measures: User Counts & Rates #
  #################################

  measure: total_users {
    type: sum
    sql: ${TABLE}."TOTAL_USERS" ;;
    label: "Total Users"
    group_label: "User Metrics"
  }

  measure: active_users {
    type: sum
    sql: ${TABLE}."ACTIVE_USERS" ;;
    label: "Active Users"
    group_label: "User Metrics"
  }

  measure: retention_rate {
    type: average
    sql: ${TABLE}."PRCNT_ACTIVE_USERS" ;;
    label: "Retention Rate"
    value_format_name: "percent_2"
    group_label: "User Metrics"
    drill_fields: [ month_month , company_cohort_date, total_users, active_users ]
  }

  measure: new_users {
    type: sum
    sql: ${TABLE}."NEW_USERS" ;;
    label: "New Users"
    group_label: "User Metrics"
  }

  measure: avg_user_tenure {
    type: average
    sql: ${TABLE}."AVG_USER_TENURE" ;;
    label: "Avg. User Tenure (Days)"
    group_label: "User Metrics"
  }

  ###################################
  # Measures: Session Counts & Rates#
  ###################################

  measure: monthly_session_totals {
    type: sum
    sql: ${TABLE}."MONTHLY_SESSION_TOTALS" ;;
    label: "Monthly Sessions"
    group_label: "Session Metrics"
    drill_fields: [ month_month, first_session_for_month, last_session_for_month ]
  }

  measure: monthly_active_sessions {
    type: sum
    sql: ${TABLE}."MONTHLY_ACTIVE_SESSIONS" ;;
    label: "Active Sessions"
    group_label: "Session Metrics"
  }

  measure: pct_active_sessions {
    type: average
    sql: ${TABLE}."PRCNT_ACTIVE_SESSIONS" ;;
    label: "% Active Sessions"
    value_format_name: "percent_2"
    group_label: "Session Metrics"
  }

  measure: monthly_time_on_platform_secs {
    type: sum
    sql: ${TABLE}."MONTHLY_TIME_ON_PLATFORM_SECS" ;;
    label: "Total Time on Platform (s)"
    group_label: "Session Metrics"
  }

  measure: monthly_active_time_secs {
    type: sum
    sql: ${TABLE}."MONTHLY_ACTIVE_TIME_SECS" ;;
    label: "Active Time (s)"
    group_label: "Session Metrics"
  }

  measure: pct_time_active {
    type: average
    sql: ${TABLE}."PRCNT_SESSION_TIME_ACTIVE" ;;
    label: "% Time Active"
    value_format_name: "percent_2"
    group_label: "Session Metrics"
  }

  measure: avg_active_time_per_session {
    type: average
    sql: ${TABLE}."AVG_ACTIVE_TIME_SECS_PER_SESSION" ;;
    label: "Avg. Time per Session (s)"
    group_label: "Session Metrics"
  }

  #########################################
  # Dimensions: Session Window & Buckets #
  #########################################

  dimension: first_session_for_month {
    type: date
    sql: ${TABLE}."FIRST_SESSION_FOR_MONTH" ;;
    label: "First Session"
    group_label: "Session Window"
  }

  dimension: last_session_for_month {
    type: date
    sql: ${TABLE}."LAST_SESSION_FOR_MONTH" ;;
    label: "Last Session"
    group_label: "Session Window"
  }

  dimension: session_weekday {
    type: string
    sql: TO_CHAR(${TABLE}."FIRST_SESSION_FOR_MONTH",'DY') ;;
    label: "Session Weekday"
    group_label: "Session Window"
  }

  measure: time_on_platform_bucket {
    type: number
    sql:
      CASE
        WHEN ${monthly_active_time_secs} < 600 THEN '<10m'
        WHEN ${monthly_active_time_secs} < 3600 THEN '10m–1h'
        ELSE '1h+' END ;;
    label: "Time Bucket"
    group_label: "Session Window"
  }

  #########################################
  # Categories: Sessions, Pages, Devices  #
  #########################################

  dimension: most_frequent_session_category {
    type: string
    sql: ${TABLE}."MOST_FREQUENT_SESSION_CATEGORY" ;;
    label: "Top Session Category"
    group_label: "Categories"
  }

  measure: session_category_frequency {
    type: sum
    sql: ${TABLE}."SESSION_CATEGORY_FREQUENCY" ;;
    label: "Session Category Count"
    group_label: "Categories"
    drill_fields: [ month_month, most_frequent_session_category, session_category_users ]
  }

  measure: pct_session_category_sessions {
    type: average
    sql: ${TABLE}."PRCNT_SESSION_CATEGORY_SESSIONS" ;;
    label: "% Category Sessions"
    value_format_name: "percent_2"
    group_label: "Categories"
  }

  measure: session_category_users {
    type: sum
    sql: ${TABLE}."SESSION_CATEGORY_USERS" ;;
    label: "Category Users"
    group_label: "Categories"
  }

  measure: pct_session_category_users {
    type: average
    sql: ${TABLE}."PRCNT_SESSION_CATEGORY_USERS" ;;
    label: "% Category Users"
    value_format_name: "percent_2"
    group_label: "Categories"
  }

  dimension: most_frequent_page_category {
    type: string
    sql: ${TABLE}."MOST_FREQUENT_PAGE_CATEGORY" ;;
    label: "Top Page Category"
    group_label: "Pages"
  }

  measure: page_category_frequency {
    type: sum
    sql: ${TABLE}."PAGE_CATEGORY_FREQUENCY" ;;
    label: "Page Category Count"
    group_label: "Pages"
  }

  measure: pct_page_category_users {
    type: average
    sql: ${TABLE}."PRCNT_PAGE_CATEGORY_USERS" ;;
    label: "% Page Category Users"
    value_format_name: "percent_2"
    group_label: "Pages"
  }

  dimension: most_frequent_device_type {
    type: string
    sql: ${TABLE}."MOST_FREQUENT_DEVICE_TYPE" ;;
    label: "Top Device Type"
    group_label: "Device"
  }

  measure: device_users {
    type: sum
    sql: ${TABLE}."DEVICE_USERS" ;;
    label: "Device Users"
    group_label: "Device"
  }

  measure: pct_device_users {
    type: average
    sql: ${TABLE}."PRCNT_DEVICE_USERS" ;;
    label: "% Device Users"
    value_format_name: "percent_2"
    group_label: "Device"
  }

  ####################################
  # Support Conversations & Ranking  #
  ####################################

  measure: intercom_session_count {
    type: sum
    sql: ${TABLE}."INTERCOM_SESSION_COUNT" ;;
    label: "Intercom Sessions"
    group_label: "Support"
  }

  measure: customer_support_session_count {
    type: sum
    sql: ${TABLE}."CUSTOMER_SUPPORT_SESSION_COUNT" ;;
    label: "Support Sessions"
    group_label: "Support"
  }

  measure: monthly_company_rank {
    type: number
    sql: ${TABLE}."MONTHLY_COMPANY_RANK" ;;
    label: "Company Rank"
    group_label: "Ranking"
  }
}
