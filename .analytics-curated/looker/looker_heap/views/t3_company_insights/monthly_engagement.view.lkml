# =====================================
# File: fct_monthly_company_engagement.view.lkml
# =====================================


view: fct_monthly_company_engagement {
  sql_table_name: ANALYTICS.T3_ANALYTICS.FCT_MONTHLY_COMPANY_ENGAGEMENT ;;
  label: "Monthly Company Engagement"
  view_label: "Engagement (Monthly Fact)"


  dimension: uid { primary_key: yes sql: ${TABLE}.UID ;; }
  dimension_group: engagement_month { label: "Engagement Month" type: time timeframes: [raw, date, month, quarter, year] sql: ${TABLE}.ENGAGEMENT_MONTH ;; }


  dimension: company_id { label: "Company ID" type: number sql: ${TABLE}.COMPANY_ID ;; }
  dimension: company_name { label: "Company Name" sql: ${TABLE}.COMPANY_NAME ;; }
  dimension: group_rollup_id { label: "Company Group Rollup ID" type: number sql: ${TABLE}.GROUP_ROLLUP_ID ;; }
  dimension: company_group_name { label: "Company Group Name" sql: ${TABLE}.COMPANY_GROUP_NAME ;; }
  dimension: company_is_invoiced_flag { label: "Company is Invoiced?" type: yesno sql: ${TABLE}.COMPANY_IS_INVOICED_FLAG ;; }
  dimension: national_account_flag { label: "National Account?" type: yesno sql: ${TABLE}.NATIONAL_ACCOUNT_FLAG ;; }
  dimension: parent_company_id { label: "Parent Company ID" type: number sql: ${TABLE}.PARENT_COMPANY_ID ;; }


# Counts
  measure: monthly_sessions { label: "Sessions (Monthly)" type: sum sql: ${TABLE}.MONTHLY_SESSION_COUNT ;; }
  measure: monthly_active_sessions { label: "Active Sessions (Monthly)" type: sum sql: ${TABLE}.MONTHLY_ACTIVE_SESSION_COUNT ;; }
  measure: monthly_t3_sessions { label: "T3 Sessions (Monthly)" type: sum sql: ${TABLE}.MONTHLY_T3_SESSION_COUNT ;; }
  measure: monthly_active_t3_sessions { label: "Active T3 Sessions (Monthly)" type: sum sql: ${TABLE}.MONTHLY_ACTIVE_T3_SESSION_COUNT ;; }
  measure: monthly_session_time_secs { label: "Time on Platform (sec, Monthly)" type: sum sql: ${TABLE}.MONTHLY_SESSION_TIME_SECS ;; }
  measure: monthly_active_time_secs { label: "Active Time (sec, Monthly)" type: sum sql: ${TABLE}.MONTHLY_ACTIVE_TIME_SECS ;; }
  measure: monthly_event_count { label: "Events (Monthly)" type: sum sql: ${TABLE}.MONTHLY_EVENT_COUNT ;; }
  measure: monthly_pageviews_from_sessions { label: "Pageviews from Sessions (Monthly)" type: sum sql: ${TABLE}.MONTHLY_PAGEVIEWS_FROM_SESSIONS ;; }
  measure: monthly_active_users { label: "Active Users (MAU)" type: sum sql: ${TABLE}.MONTHLY_ACTIVE_USERS ;; }
  measure: monthly_t3_users { label: "T3 Active Users (MAU)" type: sum sql: ${TABLE}.MONTHLY_T3_USERS ;; }
  measure: total_users { label: "Total Users" type: max sql: ${TABLE}.TOTAL_USERS ;; }


# Precomputed rates (already normalized per row)
  measure: active_user_rate { label: "Active User Rate" type: average sql: ${TABLE}.ACTIVE_USER_RATE ;; value_format_name: percent_2 }
  measure: t3_user_rate { label: "T3 User Rate" type: average sql: ${TABLE}.T3_USER_RATE ;; value_format_name: percent_2 }
  measure: active_session_rate { label: "Active Session Rate" type: average sql: ${TABLE}.ACTIVE_SESSION_RATE ;; value_format_name: percent_2 }
  measure: hva_session_rate { label: "HVA Session Rate" type: average sql: ${TABLE}.HVA_SESSION_RATE ;; value_format_name: percent_2 }
  measure: hva_events_per_active_user { label: "HVA Events per Active User" type: average sql: ${TABLE}.HVA_EVENTS_PER_ACTIVE_USER ;; }


  set: kpis_default { fields: [engagement_month_month, company_id, company_name, monthly_active_users, monthly_sessions, active_user_rate, active_session_rate] }
}
