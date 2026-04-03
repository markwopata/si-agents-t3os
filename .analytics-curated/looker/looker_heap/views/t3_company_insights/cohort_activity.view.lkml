# =====================================
# File: vw_monthly_company_cohort_activity.view.lkml
# =====================================


view: vw_monthly_company_cohort_activity {
  sql_table_name: ANALYTICS.T3_ANALYTICS.VW_MONTHLY_COMPANY_COHORT_ACTIVITY ;;
  label: "Monthly Company Cohort Activity"
  view_label: "Cohorts (Monthly View)"

    # ----- Keys -----
    dimension: company_month_key {
      label: "Company-Month Key"
      group_label: "Keys"
      primary_key: yes
      hidden: yes
      type: string
      sql: ${TABLE}.COMPANY_ID || '-' || TO_VARCHAR(${TABLE}.REPORT_MONTH) ;;
    }

    dimension_group: report_month {
      label: "Report Month"
      group_label: "Time"
      type: time
      timeframes: [raw, month, year, month_name]
      sql: ${TABLE}.REPORT_MONTH ;;
      datatype: date
    }

    dimension: company_id {
      label: "Company ID"
      group_label: "Company"
      type: string
      sql: ${TABLE}.COMPANY_ID ;;
    }

    dimension: company_name {
      label: "Company Name"
      group_label: "Company"
      type: string
      sql: ${TABLE}.COMPANY_NAME ;;
    }

    # Cohort filter baked as a reusable flag
    dimension: support_cohort_flag {
      label: "Support Cohort (Hybrid/New/T3)"
      group_label: "Support Dashboard"
      type: yesno
      sql: ${TABLE}.COHORT IN ('Hybrid','New','T3') ;;
      description: "Use this to filter the CS dashboard to Hybrid/New/T3 cohorts."
    }

    # ----- Cohort & Health -----
    dimension: cohort {
      label: "Cohort"
      group_label: "Cohort & Health"
      type: string
      sql: ${TABLE}.COHORT ;;
    }

    dimension: activity_flag {
      label: "Activity Flag"
      group_label: "Cohort & Health"
      type: string
      sql: ${TABLE}.ACTIVITY_FLAG ;;
      description: "Month-end activity status (Active/Watchlist/At Risk/Activity Churn/Re-engaged)."
    }

    dimension: converted {
      label: "Converted (Any Time This Month)"
      group_label: "Cohort & Health"
      type: yesno
      sql: ${TABLE}.CONVERTED ;;
    }

    dimension: reengaged_month {
      label: "Re-engaged (Any Time This Month)"
      group_label: "Cohort & Health"
      type: yesno
      sql: ${TABLE}.REENGAGED_MONTH ;;
    }

    dimension: cohort_start {
      label: "Cohort Start"
      group_label: "Cohort & Health"
      type: date
      sql: ${TABLE}.COHORT_START ;;
    }

    dimension: previous_cohort {
      label: "Previous Cohort"
      group_label: "Cohort & Health"
      type: string
      sql: ${TABLE}.PREVIOUS_COHORT ;;
    }

    dimension: previous_cohort_start {
      label: "Previous Cohort Start"
      group_label: "Cohort & Health"
      type: date
      sql: ${TABLE}.PREVIOUS_COHORT_START ;;
    }

    dimension: company_start {
      label: "Company Start Date"
      group_label: "Company"
      type: date
      sql: ${TABLE}.COMPANY_START ;;
    }

    dimension: company_tenure_months {
      label: "Company Tenure (Months)"
      group_label: "Company"
      type: number
      sql: ${TABLE}.COMPANY_TENURE_MONTHS ;;
    }

    # ----- Company metadata -----
    dimension: group_rollup_id {
      label: "Group Rollup ID"
      group_label: "Company"
      type: string
      sql: ${TABLE}.GROUP_ROLLUP_ID ;;
    }

    dimension: company_group_name {
      label: "Company Group Name"
      group_label: "Company"
      type: string
      sql: ${TABLE}.COMPANY_GROUP_NAME ;;
    }

    dimension: parent_company_id {
      label: "Parent Company ID"
      group_label: "Company"
      type: string
      sql: ${TABLE}.PARENT_COMPANY_ID ;;
    }

    dimension: company_is_invoiced_flag {
      label: "Invoiced Company"
      group_label: "Company Flags"
      type: yesno
      sql: ${TABLE}.COMPANY_IS_INVOICED_FLAG ;;
    }

    dimension: company_is_es_employee_created_account_flag {
      label: "Employee-Created Account"
      group_label: "Company Flags"
      type: yesno
      sql: ${TABLE}.COMPANY_IS_ES_EMPLOYEE_CREATED_ACCOUNT_FLAG ;;
    }

    dimension: national_account_flag {
      label: "National Account"
      group_label: "Company Flags"
      type: yesno
      sql: ${TABLE}.NATIONAL_ACCOUNT_FLAG ;;
    }

    dimension: parent_company_flag {
      label: "Parent Company"
      group_label: "Company Flags"
      type: yesno
      sql: ${TABLE}.PARENT_COMPANY_FLAG ;;
    }

    # ----- Assets (Month-end snapshot) -----
    dimension: customer_assets {
      label: "Customer Assets (Snapshot)"
      group_label: "Assets"
      type: number
      sql: ${TABLE}.CUSTOMER_ASSETS ;;
      value_format_name: decimal_0
    }

    dimension: active_trackers {
      label: "Active Trackers (Snapshot)"
      group_label: "Assets"
      type: number
      sql: ${TABLE}.ACTIVE_TRACKERS ;;
      value_format_name: decimal_0
    }

    dimension: active_cameras {
      label: "Active Cameras (Snapshot)"
      group_label: "Assets"
      type: number
      sql: ${TABLE}.ACTIVE_CAMERAS ;;
      value_format_name: decimal_0
    }

    dimension: own_assets {
      label: "Own Assets (Snapshot)"
      group_label: "Assets"
      type: number
      sql: ${TABLE}.OWN_ASSETS ;;
      value_format_name: decimal_0
    }

    dimension: stolen_lost_damaged_assets {
      label: "Stolen/Lost/Damaged Assets (Snapshot)"
      group_label: "Assets"
      type: number
      sql: ${TABLE}.STOLEN_LOST_DAMAGED_ASSETS ;;
      value_format_name: decimal_0
    }

    # Ratios (weighted, avoids avg-of-ratios trap)
    measure: tracker_coverage_weighted {
      label: "Tracker Coverage (Weighted)"
      group_label: "Assets"
      type: number
      value_format_name: percent_2
      sql: SUM(${TABLE}.ACTIVE_TRACKERS) / NULLIF(SUM(${TABLE}.CUSTOMER_ASSETS), 0) ;;
      description: "Weighted tracker coverage = sum(active_trackers) / sum(customer_assets)."
    }

    measure: own_asset_ratio_weighted {
      label: "Own Asset Ratio (Weighted)"
      group_label: "Assets"
      type: number
      value_format_name: percent_2
      sql: SUM(${TABLE}.OWN_ASSETS) / NULLIF(SUM(${TABLE}.OWN_ASSETS) + SUM(${TABLE}.CUSTOMER_ASSETS), 0) ;;
    }

    # ----- Rentals & Invoices (Cumulative as-of month end) -----
    dimension: rentals_created_cume {
      label: "Rentals Created (Cumulative)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      sql: ${TABLE}.RENTALS_CREATED ;;
      value_format_name: decimal_0
    }

    dimension: rentals_started_cume {
      label: "Rentals Started (Cumulative)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      sql: ${TABLE}.RENTALS_STARTED ;;
      value_format_name: decimal_0
    }

    dimension: completed_rentals_cume {
      label: "Completed Rentals (Cumulative)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      sql: ${TABLE}.COMPLETED_RENTALS ;;
      value_format_name: decimal_0
    }

    # State snapshots
    dimension: upcoming_rentals {
      label: "Upcoming Rentals (Snapshot)"
      group_label: "Rentals State (Snapshot)"
      type: number
      sql: ${TABLE}.UPCOMING_RENTALS ;;
      value_format_name: decimal_0
    }

    dimension: rentals_in_progress {
      label: "Rentals In Progress (Snapshot)"
      group_label: "Rentals State (Snapshot)"
      type: number
      sql: ${TABLE}.RENTALS_IN_PROGRESS ;;
      value_format_name: decimal_0
    }

    dimension: keypad_rentals_cume {
      label: "Keypad Rentals (Cumulative)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      sql: ${TABLE}.KEYPAD_RENTALS ;;
      value_format_name: decimal_0
    }

    measure: keypad_penetration_weighted_cume {
      label: "Keypad Penetration (Cumulative, Weighted)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      value_format_name: percent_2
      sql: SUM(${TABLE}.KEYPAD_RENTALS) / NULLIF(SUM(${TABLE}.RENTALS_STARTED), 0) ;;
      description: "Cumulative penetration as-of month end (weighted)."
    }

    dimension: invoices_cume {
      label: "Invoices (Cumulative)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      sql: ${TABLE}.INVOICES ;;
      value_format_name: decimal_0
    }

    dimension: rental_invoices_cume {
      label: "Rental Invoices (Cumulative)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      sql: ${TABLE}.RENTAL_INVOICES ;;
      value_format_name: decimal_0
    }

    dimension: t3_subscription_invoices_cume {
      label: "T3 Subscription Invoices (Cumulative)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      sql: ${TABLE}.T3_SUBSCRIPTION_INVOICES ;;
      value_format_name: decimal_0
    }

    dimension: t3_other_invoices_cume {
      label: "T3 Other Invoices (Cumulative)"
      group_label: "Rentals & Invoices (Cumulative)"
      type: number
      sql: ${TABLE}.T3_OTHER_INVOICES ;;
      value_format_name: decimal_0
    }

    # ----- Engagement (Monthly from FCT) -----
    dimension: total_users {
      label: "Total Users (Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.TOTAL_USERS ;;
      value_format_name: decimal_0
    }

    dimension: monthly_new_users {
      label: "New Users (Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_NEW_USERS ;;
      value_format_name: decimal_0
    }

    dimension: mau {
      label: "MAU"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MAU ;;
      value_format_name: decimal_0
    }

    dimension: t3_mau {
      label: "T3 MAU"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.T3_MAU ;;
      value_format_name: decimal_0
    }

    dimension: monthly_session_totals {
      label: "Sessions (Monthly Total)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_SESSION_TOTALS ;;
      value_format_name: decimal_0
    }

    dimension: monthly_active_sessions {
      label: "Active Sessions (Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_ACTIVE_SESSIONS ;;
      value_format_name: decimal_0
    }

    dimension: monthly_active_t3_sessions {
      label: "Active T3 Sessions (Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_ACTIVE_T3_SESSIONS ;;
      value_format_name: decimal_0
    }

    measure: t3_active_sessions_per_t3_mau {
      label: "Active T3 Sessions per T3 MAU"
      group_label: "Engagement (Monthly)"
      type: number
      value_format_name: decimal_2
      sql: SUM(${TABLE}.MONTHLY_ACTIVE_T3_SESSIONS) / NULLIF(SUM(${TABLE}.T3_MAU), 0) ;;
      description: "Primary intensity metric: monthly active T3 sessions per T3 MAU."
    }

    dimension: monthly_active_time_mins {
      label: "Active Time (Minutes, Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_ACTIVE_TIME_MINS ;;
      value_format_name: decimal_2
    }

    dimension: monthly_time_on_platform_mins {
      label: "Time on Platform (Minutes, Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_TIME_ON_PLATFORM_MINS ;;
      value_format_name: decimal_2
    }

    measure: active_time_share {
      label: "Active Time Share"
      group_label: "Engagement (Monthly)"
      type: number
      value_format_name: percent_2
      sql: SUM(${TABLE}.MONTHLY_ACTIVE_TIME_MINS) / NULLIF(SUM(${TABLE}.MONTHLY_TIME_ON_PLATFORM_MINS), 0) ;;
    }

    dimension: monthly_hva_event_count {
      label: "HVA Events (Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_HVA_EVENT_COUNT ;;
      value_format_name: decimal_0
    }

    dimension: monthly_hva_session_count {
      label: "HVA Sessions (Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_HVA_SESSION_COUNT ;;
      value_format_name: decimal_0
    }

    dimension: monthly_hva_user_count {
      label: "HVA Users (Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_HVA_USER_COUNT ;;
      value_format_name: decimal_0
    }

    # ----- Engagement KPIs -----
    dimension: company_user_retention_rate {
      label: "User Retention Rate"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.COMPANY_USER_RETENTION_RATE ;;
      value_format_name: percent_2
    }

    dimension: company_t3_user_retention_rate {
      label: "T3 User Retention Rate"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.COMPANY_T3_USER_RETENTION_RATE ;;
      value_format_name: percent_2
    }

    dimension: company_user_activation_rate {
      label: "User Activation Rate"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.COMPANY_USER_ACTIVATION_RATE ;;
      value_format_name: percent_2
    }

    dimension: avg_sessions_per_active_user {
      label: "Avg Sessions per Active User"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.AVG_SESSIONS_PER_ACTIVE_USER ;;
      value_format_name: decimal_2
    }

    dimension: avg_sessions_per_t3_user {
      label: "Avg Sessions per T3 User"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.AVG_SESSIONS_PER_T3_USER ;;
      value_format_name: decimal_2
    }

    dimension: monthly_hva_event_rate {
      label: "HVA Event Rate"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.MONTHLY_HVA_EVENT_RATE ;;
      value_format_name: percent_2
    }

    dimension: monthly_hva_session_rate {
      label: "HVA Session Rate"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.MONTHLY_HVA_SESSION_RATE ;;
      value_format_name: percent_2
    }

    dimension: monthly_hva_user_rate {
      label: "HVA User Rate"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.MONTHLY_HVA_USER_RATE ;;
      value_format_name: percent_2
    }

    dimension: monthly_hva_events_per_active_user {
      label: "HVA Events per Active User"
      group_label: "Engagement KPIs"
      type: number
      sql: ${TABLE}.MONTHLY_HVA_EVENTS_PER_ACTIVE_USER ;;
      value_format_name: decimal_2
    }

    dimension: monthly_cumulative_hva_event_count {
      label: "Cumulative HVA Events (Monthly)"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_CUMULATIVE_HVA_EVENT_COUNT ;;
      value_format_name: decimal_0
    }

    dimension: monthly_engagement_rank {
      label: "Monthly Engagement Rank"
      group_label: "Engagement (Monthly)"
      type: number
      sql: ${TABLE}.MONTHLY_ENGAGEMENT_RANK ;;
      value_format_name: decimal_0
    }

    dimension: activity_churn_last12mo {
      label: "Activity Churn (Last 12 Months)"
      group_label: "Cohort & Health"
      type: number
      sql: ${TABLE}.ACTIVITY_CHURN_LAST12MO ;;
      value_format_name: decimal_0
    }

    # ----- Industry -----
    dimension: sic_code { label: "SIC Code" group_label: "Industry" type: string sql: ${TABLE}.SIC_CODE ;; }
    dimension: sic_descr { label: "SIC Description" group_label: "Industry" type: string sql: ${TABLE}.SIC_DESCR ;; }
    dimension: sic_division_descr { label: "SIC Division" group_label: "Industry" type: string sql: ${TABLE}.SIC_DIVISION_DESCR ;; }
    dimension: sic_major_group_descr { label: "SIC Major Group" group_label: "Industry" type: string sql: ${TABLE}.SIC_MAJOR_GROUP_DESCR ;; }
    dimension: naics_code { label: "NAICS Code" group_label: "Industry" type: string sql: ${TABLE}.NAICS_CODE ;; }
    dimension: naics_descr { label: "NAICS Description" group_label: "Industry" type: string sql: ${TABLE}.NAICS_DESCR ;; }
    dimension: dnb_industry_code { label: "D&B Industry Code" group_label: "Industry" type: string sql: ${TABLE}.DNB_INDUSTRY_CODE ;; }
    dimension: dnb_industry_descr { label: "D&B Industry Description" group_label: "Industry" type: string sql: ${TABLE}.DNB_INDUSTRY_DESCR ;; }
    dimension: es_classification { label: "ES Classification" group_label: "Industry" type: string sql: ${TABLE}.ES_CLASSIFICATION ;; }
    dimension: es_classification_detailed { label: "ES Classification (Detailed)" group_label: "Industry" type: string sql: ${TABLE}.ES_CLASSIFICATION_DETAILED ;; }

    # ----- Core measures for dashboard tiles -----
    measure: companies {
      label: "Companies"
      group_label: "Support Dashboard"
      type: count_distinct
      sql: ${company_id} ;;
      drill_fields: [company_id, company_name, cohort, activity_flag, report_month_raw]
    }

    # Activity flag mix — counts + percentages (no lonely numbers)
    measure: pct_companies_active {
      label: "% Companies Active"
      group_label: "Support Dashboard"
      type: number
      value_format_name: percent_2
      sql: COUNT(DISTINCT CASE WHEN ${TABLE}.ACTIVITY_FLAG = 'Active' THEN ${TABLE}.COMPANY_ID END)
        / NULLIF(COUNT(DISTINCT ${TABLE}.COMPANY_ID), 0) ;;
    }

    measure: pct_companies_watchlist {
      label: "% Companies Watchlist"
      group_label: "Support Dashboard"
      type: number
      value_format_name: percent_2
      sql: COUNT(DISTINCT CASE WHEN ${TABLE}.ACTIVITY_FLAG = 'Watchlist' THEN ${TABLE}.COMPANY_ID END)
        / NULLIF(COUNT(DISTINCT ${TABLE}.COMPANY_ID), 0) ;;
    }

    measure: pct_companies_at_risk {
      label: "% Companies At Risk"
      group_label: "Support Dashboard"
      type: number
      value_format_name: percent_2
      sql: COUNT(DISTINCT CASE WHEN ${TABLE}.ACTIVITY_FLAG = 'At Risk' THEN ${TABLE}.COMPANY_ID END)
        / NULLIF(COUNT(DISTINCT ${TABLE}.COMPANY_ID), 0) ;;
    }

    measure: pct_companies_activity_churn {
      label: "% Companies Activity Churn"
      group_label: "Support Dashboard"
      type: number
      value_format_name: percent_2
      sql: COUNT(DISTINCT CASE WHEN ${TABLE}.ACTIVITY_FLAG = 'Activity Churn' THEN ${TABLE}.COMPANY_ID END)
        / NULLIF(COUNT(DISTINCT ${TABLE}.COMPANY_ID), 0) ;;
    }

    measure: pct_companies_reengaged {
      label: "% Companies Re-engaged (This Month)"
      group_label: "Support Dashboard"
      type: number
      value_format_name: percent_2
      sql: COUNT(DISTINCT CASE WHEN ${TABLE}.REENGAGED_MONTH = TRUE THEN ${TABLE}.COMPANY_ID END)
        / NULLIF(COUNT(DISTINCT ${TABLE}.COMPANY_ID), 0) ;;
    }
  }
