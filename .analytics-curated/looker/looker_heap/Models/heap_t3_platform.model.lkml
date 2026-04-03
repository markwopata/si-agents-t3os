connection: "es_snowflake"

include: "/views/heap_company_insight/*.view.lkml"
include: "/views/rental_company_low_product_usage/*.view.lkml"
include: "/views/custom_sql/*.view.lkml"

explore: company_information {
  group_label: "Heap T3 Platform"
  label: "New Companies Current Week"
  case_sensitive: no
}

explore: company_and_user_sessions {
  group_label: "Heap T3 Platform"
  label: "Company and User Sessions"
  case_sensitive: no

  join: company_information {
    type: inner
    relationship: many_to_one
    sql_on: ${company_and_user_sessions.company_name} = ${company_information.company_name} ;;
  }
}

explore: company_last_visit {
  group_label: "Heap T3 Platform"
  label: "Company Last Visit"
  case_sensitive: no
}

explore: visit_history_with_company_info {
  group_label: "Heap T3 Platform"
  label: "Last 90 Company and User Visit History"
  case_sensitive: no
}

explore: rental_companies_low_product_usage {
  group_label: "Heap T3 Platform"
  label: "Low T3 Usage by Rental Company"
  case_sensitive: no

  join: user_info_sessions_last_30_days {
    type: inner
    relationship: many_to_one
    sql_on: ${user_info_sessions_last_30_days.company_id} = ${rental_companies_low_product_usage.company_id} ;;
  }
}

explore: geofence_name_count {
  group_label: "Geofence Name Count"
  label: "Geofence Name Count"
  case_sensitive: no
}

explore: company_avg_page_load {
  group_label: "Heap T3 Platform"
  label: "T3 Analytics | Average Page Load By Company"
  case_sensitive: no
  always_filter: {
    filters: [company_avg_page_load.current_date_range: "7 days ago for 7 days"]
  }
}

explore: company_avg_query_load {
  group_label: "Heap T3 Platform"
  label: "T3 Analytics | Average Query Load By Company"
  case_sensitive: no
  always_filter: {
    filters: [company_avg_query_load.current_date_range: "7 days ago for 7 days"]
  }
}

explore: company_avg_event_load {
  group_label: "Heap T3 Platform"
  label: "T3 Analytics | Average Event Load By Company"
  case_sensitive: no
  always_filter: {
    filters: [company_avg_event_load.current_date_range: "7 days ago for 7 days"]
  }
}


explore: company_dashboard_sessions {
  group_label: "Heap T3 Platform"
  label: "T3 Analytics | Total Dashboard Sessions By Company"
  case_sensitive: no
  always_filter: {
    filters: [company_dashboard_sessions.timeframe_date: "7 days ago for 7 days"]
  }
}

explore: weekly_active_users {
  group_label: "Heap T3 Platform"
  label: "T3 Analytics | Active Users"
  case_sensitive: no
  always_filter: {
    filters: [weekly_active_users.week_start_week: "7 days ago for 7 days"]
  }
}

explore: product_stickiness {
  group_label: "Heap T3 Platform"
  label: "T3 Analytics | Product Stickiness"
  case_sensitive: no
  always_filter: {
    filters: [product_stickiness.week_start_week: "7 days ago for 7 days"]
  }
}
