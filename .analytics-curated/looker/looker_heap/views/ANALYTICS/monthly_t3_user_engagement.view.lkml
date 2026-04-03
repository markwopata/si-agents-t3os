view: monthly_t3_user_engagement {
  derived_table: {
    sql: SELECT * FROM ANALYTICS.T3_ANALYTICS.MONTHLY_T3_USER_ENGAGEMENT where MONTH::DATE >= '2023-01-01';;
  }

  ########################
  # Primary Key
  ########################
  # Creating a unique ID from company_id, es_user_id, and month

  dimension_group: month {
    type: time
    sql: ${TABLE}.month ;;
    label: "Month"
    description: "The month of the user engagement data."
  }

  dimension: us_uid {
    primary_key: yes
    type: string
    sql: ${company_id} || '-' || ${es_user_id} || '-' || CAST(${month_date} AS STRING) ;;
    label: "Unique User-Month ID"
    description: "Unique key combining Company ID, ES User ID, and Month."
    hidden: yes
  }

  dimension: uid {
    type: string
    sql: ${TABLE}.uid;;
    description: "Unique month key combining Company ID, and Month."
    hidden: yes
  }

  dimension: year_month {
    type: string
    sql: ${TABLE}.month_year ;;
    label: "Month Year"
    description: "Year-Month in YYYY-MM format."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  ########################
  # Company & User Info
  ########################
  dimension: company_id {
    type: string
    sql: ${TABLE}.company_id ;;
    label: "Company ID"
    description: "Unique identifier of the company."
  }

  dimension: company_name {
    type: string
    sql: ${TABLE}.company_name ;;
    label: "Company Name"
    description: "Name of the company."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: es_user_id {
    type: string
    sql: ${TABLE}.es_user_id ;;
    label: "ES User ID"
    description: "EquipmentShare user ID."
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}.full_name ;;
    label: "User Full Name"
    description: "Full name of the user."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
    label: "User Email"
    description: "Email address of the user."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  ########################
  # Engagement Metrics
  ########################
  dimension: monthly_session_totals {
    type: number
    sql: ${TABLE}.monthly_session_totals ;;
    label: "Monthly Session Totals"
    description: "Total number of sessions the user had in the given month."
  }

   dimension: monthly_active_sessions {
    type: number
    sql: ${TABLE}.monthly_active_sessions ;;
    label: "Monthly Active Sessions"
    description: "Number of sessions considered active in the given month."
  }

   dimension: monthly_event_totals {
    type: number
    sql: ${TABLE}.monthly_event_totals ;;
    label: "Monthly Event Totals"
    description: "Total number of events triggered by the user in the given month."
  }

  dimension: monthly_time_on_platform {
    type: number
    sql: ${TABLE}.monthly_time_on_platform ;;
    label: "Monthly Time on Platform"
    description: "Total time (in seconds) the user spent on the platform in the month (session durations)."
  }

  dimension: monthly_active_time {
    type: number
    sql: ${TABLE}.monthly_active_time ;;
    label: "Monthly Active Time"
    description: "Total active time (in seconds) within sessions for the user in the month."
  }

  dimension: avg_active_time_per_session {
    type: number
    sql: ${TABLE}.avg_active_time_per_session ;;
    label: "Avg Active Time/Session"
    description: "Average active time per session in the given month."
  }

  dimension: monthly_avg_events_per_session {
    type: number
    sql: ${TABLE}.monthly_avg_events_per_session ;;
    label: "Monthly Avg Events per Session"
    description: "Average number of events triggered per session during the month."
  }

  dimension: intercom_session_count {
    type: number
    sql: ${TABLE}.intercom_session_count ;;
    label: "Intercom Session Count"
    description: "Number of sessions involving Intercom during the month."
  }

  dimension: mimic_session_count {
    type: number
    sql: ${TABLE}.mimic_session_count ;;
    label: "Mimic Session Count"
    description: "Number of mimic sessions for the user in the given month."
  }


  ########################
  # Measures
  ########################
  measure: total_sessions {
    type: sum
    sql: ${monthly_session_totals} ;;
    label: "Total Sessions"
    description: "Sum of monthly sessions over the chosen filters."
    drill_fields: [user_engagement_details*, month_month]
  }

  measure: total_events {
    type: sum
    sql: ${monthly_event_totals} ;;
    label: "Total Events"
    description: "Sum of monthly event totals over the chosen filters."
    drill_fields: [user_engagement_details*, month_month]
  }

  measure: total_active_time {
    type: sum
    sql: ${monthly_active_time} ;;
    label: "Total Active Time"
    description: "Sum of monthly active time over the chosen filters."
    drill_fields: [user_engagement_details*, month_month]
  }

  measure: total_active_sessions {
    type: sum
    sql: ${monthly_active_sessions};;
    label: "Total Active Sessions"
    drill_fields: [user_engagement_details*, month_month]
  }

  measure: total_time_on_platform {
    type: sum
    sql: ${monthly_time_on_platform};;
    label: "Total Time on Platform"
    drill_fields: [user_engagement_details*, month_month]
  }

  measure: avg_events_per_session {
    type: max
    sql: ${monthly_avg_events_per_session};;
    label: "User Monthly Avg Events/Session"
    description: "Pre-aggregated. Consider storing raw and re-aggregating if needed."
  }

  measure: total_intercom_session_count {
    type: sum
    sql: ${intercom_session_count};;
    label: "Total Intercom Session Count"
    drill_fields: [user_engagement_details*, month_month]
  }

  measure: total_mimic_session_count {
    type: sum
    sql: ${mimic_session_count};;
    label: "Total Mimic Session Count"
    drill_fields: [user_engagement_details*, month_month]
  }

  # A ratio measure: Active time per event across selected users/months
  measure: active_time_per_event {
    type: number
    sql: CASE WHEN ${total_events}=0 THEN NULL ELSE ${total_active_time}/${total_events} END ;;
    label: "Active Time per Event"
    description: "Average active time per event triggered, over the selected users/months."
  }

  # Event Engagement: Top 5 Events (Already aggregated in table)
  dimension: top_event_1 {
    type: string
    sql: ${TABLE}.top_event_1 ;;
    description: "Most frequently engaged event this month."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: top_event_1_count {
    type: sum
    sql: ${TABLE}.top_event_1_count ;;
    label: "Top Event #1 Count"
    description: "How many times the top event was triggered."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: top_event_2 {
    type: string
    sql: ${TABLE}.top_event_2 ;;
    description: "2nd most frequently engaged event this month."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: top_event_2_count {
    type: sum
    sql: ${TABLE}.top_event_2_count ;;
    label: "Top Event #2 Count"
    description: "How many times the top event was triggered."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: top_event_3 {
    type: string
    sql: ${TABLE}.top_event_3 ;;
    description: "3rd most frequently engaged event this month."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: top_event_3_count {
    type: sum
    sql: ${TABLE}.top_event_3_count ;;
    label: "Top Event #3 Count"
    description: "How many times the top event was triggered."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: top_event_4 {
    type: string
    sql: ${TABLE}.top_event_4 ;;
    description: "4th most frequently engaged event this month."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: top_event_4_count {
    type: sum
    sql: ${TABLE}.top_event_4_count ;;
    label: "Top Event #4 Count"
    description: "How many times the top event was triggered."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: top_event_5 {
    type: string
    sql: ${TABLE}.top_event_5 ;;
    description: "5th most frequently engaged event this month."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: top_event_5_count {
    type: sum
    sql: ${TABLE}.top_event_5_count ;;
    label: "Top Event #5 Count"
    description: "How many times the top event was triggered."
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  # Adoption: Most Frequent Landing Page, Device, Location
  dimension: most_frequent_app_or_landing_page {
    type: string
    sql: ${TABLE}.most_frequent_app_or_landing_page ;;
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: app_or_landing_page_frequency {
    type: sum
    sql: ${TABLE}.app_or_landing_page_frequency ;;
    label: "Most Frequent App or Landing Page Count"
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: most_frequent_device {
    type: string
    sql: ${TABLE}.most_frequent_device ;;
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: device_frequency {
    type: sum
    sql: ${TABLE}.device_frequency ;;
    label: "Device Frequency"
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: most_frequent_location {
    type: string
    sql: ${TABLE}.most_frequent_location ;;
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: location_frequency {
    type: sum
    sql: ${TABLE}.location_frequency ;;
    label: "Location Frequency"
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: months_with_session {
    type: sum
    sql: ${TABLE}.months_with_session ;;
    label: "Months with Session"
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: monthly_user_rank {
    type: number
    sql: ${TABLE}.monthly_user_rank ;;
    label: "Monthly User Rank"
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  measure: tenure_in_months {
    type: number
    sql: ${TABLE}.tenure_in_months ;;
    drill_fields: [user_engagement_details*, month_date, month_year]
  }

  dimension: is_vip_customer {
    type: yesno
    sql:
    CASE WHEN ${TABLE}.COMPANY_ID IN (50, 8935, 2968, 7978, 5437, 5658, 24008, 11674, 60574, 10924)
         THEN TRUE
         ELSE FALSE
    END
  ;;
  }


  ########################
  # Drilling and Sets
  ########################
  set: user_engagement_details {
    fields: [
      company_id,
      company_name,
      es_user_id,
      full_name,
      email,
      monthly_session_totals,
      monthly_active_time,
      monthly_event_totals,
      most_frequent_app_or_landing_page,
      most_frequent_device,
      most_frequent_location
    ]
  }

  # Add a measure with drill fields
  measure: total_sessions_with_drill {
    type: sum
    sql: ${monthly_session_totals} ;;
    label: "Total Sessions (With Drill)"
    description: "Sum of monthly sessions with the ability to drill into user details."
    drill_fields: [user_engagement_details*, month_month]
  }

  # Month-over-month differences can be performed via table calculations in Explores.
  # All raw fields needed are included to facilitate MoM comparisons (e.g., by comparing ${month} to previous month).
}
