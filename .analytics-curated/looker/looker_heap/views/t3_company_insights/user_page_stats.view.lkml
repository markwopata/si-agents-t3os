view: user_page_stats {
    derived_table: {
      sql:
      WITH PAGES AS (
          SELECT
              COMPANY_ID||'-'||ESDB_USER_ID||'-'||DATE||'-'||PAGE_DATA AS REFERENCE_ID
              , COMPANY_ID
              , COMPANY_NAME
              , ESDB_USER_ID
              , EMAIL_ADDRESS
              , USER_COHORT_MONTH
              , COMPANY_COHORT_MONTH
              , DATE
              --, DATE_TRUNC('WEEK', DATE) AS WEEK_START
              --, DATE_TRUNC('MONTH', DATE) AS MONTH_START
              , APPLICATION_CATEGORY
              , PAGE_DATA
              , COUNT(DISTINCT SESSION_ID) AS PAGE_CATEGORY_SESSIONS
              , COUNT(DISTINCT CASE WHEN ACTIVE_SESSION THEN SESSION_ID END) AS PAGE_CATEGORY_ACTIVE_SESSIONS
              , COUNT(DISTINCT PAGEVIEW_METADATA) AS PAGE_CATEGORY_PAGES
              , SUM(PAGEVIEW_DURATION_MINS) AS PAGE_CATEGORY_DURATION_MINS
          FROM ANALYTICS.T3_ANALYTICS.USER_PAGE_STATS
          GROUP BY 1,2,3,4, 5,6,7,8,9, 10
        )
        , PAGES_TO_INCLUDE AS (
        select
        distinct
            PAGE_DATA
        from PAGES
        group by 1
        HAVING COUNT(*) > 7000
        )
SELECT
    P.*
FROM PAGES P
JOIN PAGES_TO_INCLUDE PTI
    ON P.PAGE_DATA = PTI.PAGE_DATA
          ;;
    }
  dimension: REFERENCE_ID {
    label: "Reference ID"
    type: string
    primary_key: yes
    hidden: yes
  }

    dimension: company_id {
      label: "Company ID"
      group_label: "Company/User Info"
      type: string
      sql: ${TABLE}."COMPANY_ID" ;;
    }

   dimension: company_name {
    label: "Company Name"
    group_label: "Company/User Info"
    type: string
    sql: ${TABLE}."COMPANY_NAME" ;;
    drill_fields: [detail*]
  }
     dimension: esdb_user_id {
      label: "User ID"
      group_label: "Company/User Info"
      type: string
      sql: ${TABLE}."ESDB_USER_ID" ;;

    }
   dimension: email_address {
    label: "User Email"
    group_label: "Company/User Info"
    type: string
    sql: ${TABLE}."EMAIL_ADDRESS" ;;
    drill_fields: [detail*]
  }
  dimension: user_cohort_month {
    label: "User Cohort Month"
    group_label: "Company/User Info"
    type: date
    sql: ${TABLE}."USER_COHORT_MONTH" ;;
    drill_fields: [detail*]
  }
  dimension: company_cohort_month {
    label: "Company Cohort Month"
    group_label: "Company/User Info"
    type: date
    sql: ${TABLE}."COMPANY_COHORT_MONTH" ;;
    drill_fields: [detail*]
  }

  dimension_group: date {
    label: "Date"
    group_label: "Date Buckets"
    type: time
    timeframes: [raw, date, week, month, year]
    sql: ${TABLE}."DATE" ;;
    convert_tz: no
    drill_fields: [detail*]
  }

    dimension: application_category {
      label: "Application Category"
      group_label: "Page Detail"
      type: string
      sql: ${TABLE}."APPLICATION_CATEGORY" ;;
      drill_fields: [detail*]
    }
    dimension: page_data {
      label: "Page Category"
      group_label: "Page Detail"
      type: string
      sql: ${TABLE}."PAGE_DATA" ;;
      drill_fields: [detail*]
    }

    # ==== Measures- Page Metrics ====
    measure: page_category_sessions {
      label: "Page Session Count"
      group_label: "Page Metrics"
      type: sum
      sql: ${TABLE}."PAGE_CATEGORY_SESSIONS" ;;
      value_format_name: decimal_0
    }

    measure: page_category_active_sessions {
      label: "Page Active Session Count"
      group_label: "Page Metrics"
      type: sum
      sql: ${TABLE}."PAGE_CATEGORY_ACTIVE_SESSIONS" ;;
      value_format_name: decimal_0
    }

    measure: page_category_pages {
      label: "Nested Page Counts"
      group_label: "Page Metrics"
      type: sum
      sql: ${TABLE}."PAGE_CATEGORY_PAGES" ;;
      value_format_name: decimal_0
    }

    measure: page_category_duration_mins {
      label: "Page Duration (Mins)"
      group_label: "Page Metrics"
      type: sum
      sql: ${TABLE}."PAGE_CATEGORY_DURATION_MINS" ;;
      value_format_name: decimal_2
    }

  # === Measures ===
  measure: count {
    label: "ount"
    group_label: "Summary"
    type: count
    drill_fields: [detail*]
  }
    # === Drill Set ===
  set: detail {
    fields: [
      company_id,
      company_name,
      esdb_user_id,
      email_address,
      user_cohort_month,
      company_cohort_month,
      date_date,
      date_month,
      date_week,
      application_category,
      page_data,
      page_category_sessions,
      page_category_active_sessions,
      page_category_pages,
      page_category_duration_mins
    ]
  }
}
