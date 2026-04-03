view: user_engagement {
  sql_table_name: analytics.t3_analytics.monthly_t3_user_engagement ;;



  # Dimensions
  dimension: year_month {
    type: string
    sql: ${TABLE}.YEAR_MONTH ;;
    description: "The month for which engagement data is aggregated."
    }


  dimension: primary_key {
    type: string
    sql: ${TABLE}.COMPANY_ID||'-'||${TABLE}.ES_USER_ID||'-'||${TABLE}.YEAR_MONTH ;;
    primary_key: yes
  }

  dimension: uid {
    type: string
    sql: ${TABLE}.UID;;
  }

  dimension_group: month {
    type: time
    timeframes: [month, quarter, year]
    sql:${TABLE}.MONTH;;
    description: "The month for which engagement data is aggregated."
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
  }

  dimension: es_user_id {
    type: string
    sql: ${TABLE}.ES_USER_ID ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.FULL_NAME ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.EMAIL ;;
  }

  dimension: most_frequent_device {
    type: string
    sql: ${TABLE}.MOST_FREQUENT_DEVICE ;;
  }

  dimension: most_frequent_app_or_landing {
    type: string
    sql: ${TABLE}.MOST_FREQUENT_APP_OR_LANDING ;;
  }

  dimension: most_frequent_path_or_app {
    type: string
    sql: ${TABLE}.MOST_FREQUENT_PATH_OR_APP ;;
  }

  dimension_group: user_first_seen {
    type: time
    sql: ${TABLE}.USER_FIRST_SEEN ;;
  }

  dimension_group: company_first_seen {
    type: time
    sql: ${TABLE}.COMPANY_FIRST_SEEN ;;
  }

  dimension: user_timezone {
    type: string
    sql: ${TABLE}.USER_TIMEZONE ;;
  }

  dimension_group: first_session_for_month {
    type: time
    sql: ${TABLE}.FIRST_SESSION_FOR_MONTH ;;
  }

  dimension_group: last_session_for_month {
    type: time
    sql: ${TABLE}.LAST_SESSION_FOR_MONTH ;;
  }

  dimension_group: user_deleted_date {
    type: time
    sql: ${TABLE}.USER_DELETED_DATE ;;
  }

  dimension: top_event_1 {
    type: string
    sql: ${TABLE}.TOP_EVENT_1 ;;
  }

  dimension: top_event_2 {
    type: string
    sql: ${TABLE}.TOP_EVENT_2 ;;
  }

  dimension: top_event_3 {
    type: string
    sql: ${TABLE}.TOP_EVENT_3 ;;
  }

  dimension: top_event_4 {
    type: string
    sql: ${TABLE}.TOP_EVENT_4 ;;
  }

  dimension: top_event_5 {
    type: string
    sql: ${TABLE}.TOP_EVENT_5 ;;
  }

  dimension: monthly_session_totals {
    type: number
    sql: ${TABLE}.MONTHLY_SESSION_TOTALS ;;
    description: "Total number of sessions for the user in the month."
  }

  dimension: monthly_event_totals {
    type: number
    sql: ${TABLE}.MONTHLY_EVENT_TOTALS ;;
    description: "Total number of events for the user in the month."
  }

  dimension: device_frequency {
    type: number
    sql: ${TABLE}.DEVICE_FREQUENCY ;;
  }

  dimension: app_or_landing_frequency {
    type: number
    sql: ${TABLE}.APP_OR_LANDING_FREQUENCY ;;
  }

  dimension: path_or_app_frequency {
    type: number
    sql: ${TABLE}.PATH_OR_APP_FREQUENCY ;;
  }

  dimension: rank {
    type: number
    sql: ${TABLE}.RANK ;;
    description: "Rank of the user based on engagement metrics."
  }

  # New Yes/No dimension to flag power users
  dimension: is_power_user {
    type: yesno
    sql: ${rank} >= 5 ;;
    description: "Flag if the user is a power user (Rank 1)."
  }

  filter: company_filter {
    type: string
    sql: ${company_id} ;;
  }

  filter: month_filter {
    type: string
    sql: ${year_month} ;;
  }


  # Measures

  measure: session_totals {
    label: "Session Totals"
    type: sum
    sql: ${monthly_session_totals};;
  }

  measure: company_session_totals {
    label: "Company Session Totals"
    type: sum_distinct
    sql_distinct_key: ${company_id} ;;
    sql: ${monthly_session_totals};;
  }

   measure: event_totals {
    label: "Event Totals"
    type: sum
    sql: ${monthly_event_totals};;
  }

  measure: company_event_totals {
    label: "Company Event Totals"
    type: sum_distinct
    sql_distinct_key: ${company_id} ;;
    sql: ${monthly_event_totals};;
  }

  measure: avg_sessions {
    label: "Average Sessions per T3 User"
    type: average
    sql: ${monthly_session_totals} ;;
  }

  measure: company_avg_sessions {
    label: "Company Average Sessions per T3 User"
    type: average_distinct
    sql_distinct_key: ${company_id} ;;
    sql: ${monthly_session_totals} ;;
  }

  measure: deleted_users {
    label: "Deleted Users"
    type: number
    sql: count(${es_user_id}) OVER (order by ${user_deleted_date_date} ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) ;;
  }

  measure: T3_user_count {
    label: "T3 User Count"
    type: number
    sql: count(${es_user_id}) OVER (order by ${user_first_seen_date} ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - ${deleted_users};;
    description: "Running total of T3 users minus the deleted users."
  }

  measure: T3_active_user_count {
    label: "T3 Active User Count"
    type: count_distinct
    sql: ${es_user_id};;
    description: "Count of T3 Users with sessions."
  }

  measure: company_deleted_users {
    label: "Deleted Users for Company"
    type: number
    sql: count(${es_user_id}) OVER (partition by ${company_id} order by ${user_deleted_date_date} ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) ;;
  }

  measure: company_T3_user_count {
    label: "T3 User Count for Company"
    type: number
    sql: count(${es_user_id}) OVER (partition by ${company_id} order by ${user_first_seen_date} ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) - ${company_deleted_users};;
  }

  measure: company_T3_active_user_count {
    label: "T3 Active User Count for Company"
    type: count_distinct
    sql_distinct_key: ${company_id} ;;
    sql: ${es_user_id};;
  }

  measure: prcnt_active_T3_users {
    label: "% T3 Active Users"
    type: number
    sql: ((${T3_active_user_count}-${deleted_users}) / NULLIF(${T3_user_count}, 0)) * 100 ;;
    value_format_name: percent_2
    description: "Percentage of active T3 users."
  }

  measure: company_prcnt_active_T3_users {
    label: "% T3 Active Users for Company"
    type: number
    sql: ((${company_T3_active_user_count}-${company_deleted_users}) / NULLIF(${company_T3_user_count}, 0)) * 100 ;;
    value_format_name: percent_2
    description: "Percentage of active T3 users by company."
  }

  measure: avg_events_per_session {
    label: "Average Events per session"
    type: average_distinct
    sql_distinct_key: ${monthly_session_totals} ;;
    sql: ${monthly_event_totals} ;;
    description: "Average events per session."
  }

  measure: prcnt_difference_active_T3_users {
    label: "% Difference of Active Users"
    type: number
    sql: ((${prcnt_active_T3_users} - LAG(${prcnt_active_T3_users})) / NULLIF(LAG(${prcnt_active_T3_users}),0)) * 100 ;;
    value_format_name: percent_2
    description: "Percent change in active T3 users."
  }

  measure: company_prcnt_difference_active_T3_users {
    label: "% Difference of Active Users for Company"
    type: number
    sql: ((${company_prcnt_active_T3_users} - LAG(${company_prcnt_active_T3_users})) / NULLIF(LAG(${company_prcnt_active_T3_users}),0)) * 100 ;;
    value_format_name: percent_2
    description: "Percent change in active T3 users."
  }

  measure: session_date_deltas {
    label: "Date Deltas between sessions"
    type: sum_distinct
    sql_distinct_key: ${month_month} ;;
    sql: DATEDIFF('day',${first_session_for_month_date}, ${last_session_for_month_date}) ;;
    description: "Difference between first and last session dates for the month."
  }

  measure: avg_device_frequency {
    type: average
    sql: ${device_frequency};;
  }

  measure: avg_app_or_landing_frequency {
    type: average
    sql: ${app_or_landing_frequency};;
  }

  measure: avg_path_or_app_frequency {
    type: average
    sql: ${path_or_app_frequency};;
  }

  measure: rank_count {
    label: "User Engagement Rank"
    type: count_distinct
    sql: ${rank};;
    description: "The rank of the user based on engagement metrics."
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      year_month,
      company_id,
      company_name,
      es_user_id,
      monthly_session_totals,
      monthly_event_totals,
      rank
    ]
  }

}
