    view: monthly_company_cohort_stats {
      sql_table_name: ANALYTICS.T3_ANALYTICS.COMPANY_COHORT_TRACKER_MONTHLY ;;

      ########################################################################
      # KEYS & DATES
      ########################################################################
      dimension: company_id         { primary_key: no  type: string  sql: ${TABLE}.company_id ;; label: "Company ID" }
      dimension: company_name       { type: string     sql: ${TABLE}.company_name ;; label: "Company Name" }

      dimension_group: month {
        type: time
        timeframes: [raw, month, quarter, year]
        sql: ${TABLE}.month ;;
        label: "Month"
        convert_tz: no
      }

      dimension_group: snapshot_date {
        type: time
        timeframes: [date]
        sql: ${TABLE}.snapshot_date ;;
        label: "Snapshot Date (EoM)"
        convert_tz: no
      }

      dimension: company_month_key {
        type: string
        primary_key: yes
        hidden: yes
        sql: concat(${company_id}, '-', to_char(${month_raw}, 'YYYY-MM-DD')) ;;
        label: "Company-Month Key"
      }

      ########################################################################
      # COHORT / ACTIVITY / META
      ########################################################################
      dimension: cohort             { type: string  sql: ${TABLE}.cohort ;; label: "Cohort" group_label: "Cohort" }
      dimension_group: cohort_start { type: time timeframes:[date, month, year] sql: ${TABLE}.cohort_start ;; label: "Cohort Start" group_label: "Cohort" }
      dimension: previous_cohort    { type: string  sql: ${TABLE}.previous_cohort ;; label: "Previous Cohort" group_label: "Cohort" }
      dimension_group: previous_cohort_start { type: time timeframes:[date, month, year] sql: ${TABLE}.previous_cohort_start ;; label:"Previous Cohort Start" group_label:"Cohort" }

      dimension: converted_this_month { type: yesno sql: ${TABLE}.converted_this_month ;; label: "Converted This Month?" group_label:"Cohort" }
      dimension: reengaged_this_month { type: yesno sql: ${TABLE}.reengaged_this_month ;; label: "Re-engaged This Month?" group_label:"Activity" }
      dimension: activity_flag       { type: string sql: ${TABLE}.activity_flag ;; label: "Activity Status" group_label:"Activity" }
      dimension: af_calc             { type: string sql: ${TABLE}.af_calc ;; label: "Activity (Calculated)" group_label:"Activity" }
      dimension_group: last_activity { type: time timeframes:[date] sql: ${TABLE}.last_activity ;; label: "Last Activity" group_label:"Activity" }
      dimension_group: next_activity { type: time timeframes:[date] sql: ${TABLE}.next_activity ;; label: "Next Activity" group_label:"Activity" }

      dimension: tenure_days   { type: number sql: ${TABLE}.tenure_days ;; label: "Tenure (Days)" group_label:"Cohort" }
      dimension: tenure_months { type: number sql: ${TABLE}.tenure_months ;; label: "Tenure (Months)" group_label:"Cohort" }

      ########################################################################
      # ORG FLAGS
      ########################################################################
      dimension: vip               { type: yesno   sql: ${TABLE}.vip ;; label: "VIP Company?" group_label:"Org" }
      dimension: parent_company_id { type: string  sql: ${TABLE}.parent_company_id ;; label: "Parent Company ID" group_label:"Org" }

      ########################################################################
      # ASSETS (EOM SNAPSHOTS & MONTHLY ADDS)
      ########################################################################
      dimension: customer_assets              { type: number sql: ${TABLE}.customer_assets ;; label: "Assets: Customer (EoM)" group_label:"Assets" }
      dimension: active_trackers              { type: number sql: ${TABLE}.active_trackers ;; label: "Trackers: Active (EoM)" group_label:"Assets" }
      dimension: active_cameras               { type: number sql: ${TABLE}.active_cameras ;; label: "Cameras: Active (EoM)" group_label:"Assets" }
      dimension: own_assets                   { type: number sql: ${TABLE}.own_assets ;; label: "Assets: Own (EoM)" group_label:"Assets" }
      dimension: stolen_lost_damaged_assets   { type: number sql: ${TABLE}.stolen_lost_damaged_assets ;; label: "Assets: Stolen/Lost/Damaged (EoM)" group_label:"Assets" }
      dimension: other_assets                 { type: number sql: ${TABLE}.other_assets ;; label: "Assets: Other (EoM)" group_label:"Assets" }
      dimension: other_asset_trackers         { type: number sql: ${TABLE}.other_asset_trackers ;; label: "Trackers: Other Assets (EoM)" group_label:"Assets" }

      dimension: monthly_assets_added         { type: number sql: ${TABLE}.monthly_assets_added ;; label: "Assets Added (Month)" group_label:"Assets (Adds)" }
      dimension: monthly_trackers_added       { type: number sql: ${TABLE}.monthly_trackers_added ;; label: "Trackers Added (Month)" group_label:"Assets (Adds)" }
      dimension: monthly_cameras_added        { type: number sql: ${TABLE}.monthly_cameras_added ;; label: "Cameras Added (Month)" group_label:"Assets (Adds)" }

      # Weighted rollups (work across companies/month)
      measure: active_tracker_coverage_wavg {
        type: number
        value_format_name: percent_2
        sql: NULLIF(SUM(${active_trackers}),0) / NULLIF(SUM(${customer_assets}),0) ;;
        label: "Active Tracker Coverage (Weighted)"
        group_label: "Assets (Rates)"
      }

      measure: own_asset_ratio_wavg {
        type: number
        value_format_name: percent_2
        sql: NULLIF(SUM(${own_assets}),0) / NULLIF(SUM(${own_assets}) + SUM(${customer_assets}),0) ;;
        label: "Own Asset Ratio (Weighted)"
        group_label: "Assets (Rates)"
      }

      ########################################################################
      # RENTALS (EOM SNAPSHOTS & MONTHLY ADDS)
      ########################################################################
      dimension: rentals_created          { type: number sql: ${TABLE}.rentals_created ;; label: "Rentals: Created (EoM)" group_label:"Rentals (EoM)" }
      dimension: rentals_started          { type: number sql: ${TABLE}.rentals_started ;; label: "Rentals: Started (EoM)" group_label:"Rentals (EoM)" }
      dimension: rentals_ended            { type: number sql: ${TABLE}.rentals_ended ;; label: "Rentals: Ended (EoM)" group_label:"Rentals (EoM)" }
      dimension: rentals_in_progress      { type: number sql: ${TABLE}.rentals_in_progress ;; label: "Rentals: In-Progress (EoM)" group_label:"Rentals (EoM)" }
      dimension: upcoming_rentals         { type: number sql: ${TABLE}.upcoming_rentals ;; label: "Rentals: Upcoming (EoM)" group_label:"Rentals (EoM)" }

      dimension: keypad_rentals           { type: number sql: ${TABLE}.keypad_rentals ;; label: "Keypad Rentals (EoM)" group_label:"Rentals (EoM)" }
      dimension: monthly_rentals_created  { type: number sql: ${TABLE}.monthly_rentals_created ;; label: "Rentals Created (Month)" group_label:"Rentals (Adds)" }
      dimension: monthly_rentals_started  { type: number sql: ${TABLE}.monthly_rentals_started ;; label: "Rentals Started (Month)" group_label:"Rentals (Adds)" }
      dimension: monthly_rentals_ended    { type: number sql: ${TABLE}.monthly_rentals_ended ;; label: "Rentals Ended (Month)" group_label:"Rentals (Adds)" }
      dimension: monthly_keypad_rentals   { type: number sql: ${TABLE}.monthly_keypad_rentals ;; label: "Keypad Rentals (Month)" group_label:"Rentals (Adds)" }

      measure: keypad_rental_penetration_wavg {
        type: number
        value_format_name: percent_2
        sql: SUM(${monthly_keypad_rentals}) / NULLIF(SUM(${monthly_rentals_started}),0) ;;
        label: "Keypad Rental Penetration (Weighted)"
        group_label: "Rentals (Rates)"
      }

      ########################################################################
      # ENGAGEMENT (USERS, SESSIONS, TIME)
      ########################################################################
      dimension: mau                         { type: number sql: ${TABLE}.mau ;; label: "MAU (Users Active This Month)" group_label:"Engagement" }
      dimension: t3_mau                      { type: number sql: ${TABLE}.t3_mau ;; label: "T3 MAU" group_label:"Engagement" }
      dimension: total_users                 { type: number sql: ${TABLE}.total_users ;; label: "Total Users (EoM)" group_label:"Engagement" }
      dimension: monthly_new_users           { type: number sql: ${TABLE}.monthly_new_users ;; label: "New Users (Month)" group_label:"Engagement" }
      dimension: monthly_session_totals      { type: number sql: ${TABLE}.monthly_session_totals ;; label: "Sessions (Month)" group_label:"Engagement" }
      dimension: monthly_active_t3_sessions  { type: number sql: ${TABLE}.monthly_active_t3_sessions ;; label: "Active T3 Sessions (Month)" group_label:"Engagement" }
      dimension: monthly_platform_min_added  { type: number sql: ${TABLE}.monthly_platform_min_added ;; label: "Platform Minutes (Month)" group_label:"Engagement (Time)" }
      dimension: monthly_active_min_added    { type: number sql: ${TABLE}.monthly_active_min_added ;; label: "Active Minutes (Month)" group_label:"Engagement (Time)" }

      # Weighted rates that leadership will care about
      measure: t3_mau_share_wavg {
        type: number
        value_format_name: percent_2
        sql: SUM(${t3_mau}) / NULLIF(SUM(${mau}),0) ;;
        label: "T3 Share of MAU (Weighted)"
        group_label: "Engagement (Rates)"
      }

      measure: user_retention_rate_wavg {
        type: number
        value_format_name: percent_2
        sql: SUM(${mau}) / NULLIF(SUM(${total_users}),0) ;;
        label: "User Retention Rate (Weighted)"
        group_label: "Engagement (Rates)"
        description: "Equivalent to weighted average of COMPANY_USER_RETENTION_RATE."
      }

      measure: t3_user_retention_rate_wavg {
        type: number
        value_format_name: percent_2
        sql: SUM(${t3_mau}) / NULLIF(SUM(${total_users}),0) ;;
        label: "T3 User Retention Rate (Weighted)"
        group_label: "Engagement (Rates)"
      }

      measure: user_activation_rate_wavg {
        type: number
        value_format_name: percent_2
        sql: SUM(${monthly_new_users}) / NULLIF(SUM(${total_users}),0) ;;
        label: "User Activation Rate (Weighted)"
        group_label: "Engagement (Rates)"
      }

      measure: avg_sessions_per_active_user_wavg {
        type: number
        value_format_name: decimal_2
        sql: SUM(${monthly_session_totals}) / NULLIF(SUM(${mau}),0) ;;
        label: "Avg Sessions per Active User (Weighted)"
        group_label: "Engagement (Rates)"
      }

      measure: avg_sessions_per_t3_user_wavg {
        type: number
        value_format_name: decimal_2
        sql: SUM(${monthly_session_totals}) / NULLIF(SUM(${t3_mau}),0) ;;
        label: "Avg Sessions per T3 User (Weighted)"
        group_label: "Engagement (Rates)"
      }

      ########################################################################
      # INVOICES
      ########################################################################
      dimension: invoices                 { type: number sql: ${TABLE}.invoices ;; label: "Invoices (Cumulative)" group_label:"Invoices" }
      dimension: rental_invoices          { type: number sql: ${TABLE}.rental_invoices ;; label: "Invoices: Rental (Cum.)" group_label:"Invoices" }
      dimension: t3_subscription_invoices { type: number sql: ${TABLE}.t3_subscription_invoices ;; label: "Invoices: T3 Subscription (Cum.)" group_label:"Invoices" }
      dimension: t3_other_invoices        { type: number sql: ${TABLE}.t3_other_invoices ;; label: "Invoices: T3 Other (Cum.)" group_label:"Invoices" }

      measure: t3_invoice_mix_share {
        type: number
        value_format_name: percent_2
        sql: (SUM(${t3_subscription_invoices}) + SUM(${t3_other_invoices})) / NULLIF(SUM(${invoices}),0) ;;
        label: "T3 Invoice Mix (Weighted)"
        group_label: "Invoices (Rates)"
      }

      ########################################################################
      # “COMPANY COUNTS” FOR ROLLOPS
      ########################################################################
      measure: companies {
        type: count_distinct
        sql: ${company_id} ;;
        label: "Companies"
        group_label: "Company Counts"
        drill_fields: [company_name, cohort, month_month, mau, total_users]
      }

      measure: active_companies {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [af_calc: "Active"]
        label: "Companies: Active"
        group_label: "Company Counts"
      }

      measure: at_risk_companies {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [af_calc: "At Risk"]
        label: "Companies: At Risk"
        group_label: "Company Counts"
      }

      measure: churned_companies {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [af_calc: "Activity Churn"]
        label: "Companies: Activity Churn"
        group_label: "Company Counts"
      }

      measure: converted_companies {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [converted_this_month: "yes"]
        label: "Companies Converted (Month)"
        group_label: "Company Counts"
      }

      measure: reengaged_companies {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [reengaged_this_month: "yes"]
        label: "Companies Re-engaged (Month)"
        group_label: "Company Counts"
      }

      ########################################################################
      # SIMPLE SUMS
      ########################################################################
      measure: customer_assets_sum              { type: sum sql: ${customer_assets} ;; label: "Assets: Customer (Sum)" group_label:"Sums" }
      measure: active_trackers_sum              { type: sum sql: ${active_trackers} ;; label: "Trackers: Active (Sum)" group_label:"Sums" }
      measure: active_cameras_sum               { type: sum sql: ${active_cameras} ;; label: "Cameras: Active (Sum)" group_label:"Sums" }
      measure: own_assets_sum                   { type: sum sql: ${own_assets} ;; label: "Assets: Own (Sum)" group_label:"Sums" }
      measure: monthly_assets_added_sum         { type: sum sql: ${monthly_assets_added} ;; label: "Assets Added (Sum)" group_label:"Sums" }
      measure: monthly_trackers_added_sum       { type: sum sql: ${monthly_trackers_added} ;; label: "Trackers Added (Sum)" group_label:"Sums" }
      measure: monthly_cameras_added_sum        { type: sum sql: ${monthly_cameras_added} ;; label: "Cameras Added (Sum)" group_label:"Sums" }
      measure: monthly_rentals_created_sum      { type: sum sql: ${monthly_rentals_created} ;; label: "Rentals Created (Sum)" group_label:"Sums" }
      measure: monthly_rentals_started_sum      { type: sum sql: ${monthly_rentals_started} ;; label: "Rentals Started (Sum)" group_label:"Sums" }
      measure: monthly_rentals_ended_sum        { type: sum sql: ${monthly_rentals_ended} ;; label: "Rentals Ended (Sum)" group_label:"Sums" }
      measure: monthly_keypad_rentals_sum       { type: sum sql: ${monthly_keypad_rentals} ;; label: "Keypad Rentals (Sum)" group_label:"Sums" }
      measure: mau_sum                          { type: sum sql: ${mau} ;; label: "MAU (Sum)" group_label:"Sums" }
      measure: t3_mau_sum                       { type: sum sql: ${t3_mau} ;; label: "T3 MAU (Sum)" group_label:"Sums" }
      measure: total_users_sum                  { type: sum sql: ${total_users} ;; label: "Total Users (Sum)" group_label:"Sums" }
      measure: monthly_new_users_sum            { type: sum sql: ${monthly_new_users} ;; label: "New Users (Sum)" group_label:"Sums" }
      measure: monthly_session_totals_sum       { type: sum sql: ${monthly_session_totals} ;; label: "Sessions (Sum)" group_label:"Sums" }
      measure: monthly_active_t3_sessions_sum   { type: sum sql: ${monthly_active_t3_sessions} ;; label: "Active T3 Sessions (Sum)" group_label:"Sums" }
      measure: monthly_platform_min_added_sum   { type: sum sql: ${monthly_platform_min_added} ;; label: "Platform Minutes (Sum)" group_label:"Sums" }
      measure: monthly_active_min_added_sum     { type: sum sql: ${monthly_active_min_added} ;; label: "Active Minutes (Sum)" group_label:"Sums" }
      measure: invoices_sum                     { type: sum sql: ${invoices} ;; label: "Invoices (Sum)" group_label:"Sums" }
      measure: rental_invoices_sum              { type: sum sql: ${rental_invoices} ;; label: "Rental Invoices (Sum)" group_label:"Sums" }
      measure: t3_subscription_invoices_sum     { type: sum sql: ${t3_subscription_invoices} ;; label: "T3 Sub Invoices (Sum)" group_label:"Sums" }
      measure: t3_other_invoices_sum            { type: sum sql: ${t3_other_invoices} ;; label: "T3 Other Invoices (Sum)" group_label:"Sums" }

      ########################################################################
      # QUICK FILTERS / TIERING EXAMPLES (optional)
      ########################################################################
      dimension: activity_bucket {
        type: tier
        style: integer
        tiers: [0, 1] # 0=Inactive/Churn/At Risk, 1=Active
        sql: CASE WHEN ${af_calc} = 'Active' THEN 1 ELSE 0 END ;;
        label: "Activity Bucket (Active vs Not)"
        group_label: "Activity"
      }

      dimension: tenure_bucket_months {
        type: tier
        style: integer
        tiers: [1,3,6,12,24,36]
        sql: ${tenure_months} ;;
        label: "Tenure Bucket (Months)"
        group_label: "Cohort"
      }


    # ======================================================================
    # COHORT COUNTS & CONVERSIONS
    # ======================================================================
    # --- Helper: True conversion (changed cohort this month, not first assignment)
      dimension: is_true_conversion {
        type: yesno
        hidden: yes
        sql:
            CASE
              WHEN ${converted_this_month} AND ${previous_cohort} IS NOT NULL AND ${previous_cohort} <> ${cohort}
              THEN TRUE ELSE FALSE
            END ;;
      }

    # ---------- Monthly counts by cohort (EoM snapshot) ----------
      measure: companies_cohort_hybrid {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [cohort: "Hybrid"]
        label: "Companies in Cohort: Hybrid (EoM)"
        group_label: "Cohorts (Counts)"
      }

      measure: companies_cohort_t3 {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [cohort: "T3"]
        label: "Companies in Cohort: T3 (EoM)"
        group_label: "Cohorts (Counts)"
      }

      measure: companies_cohort_rental {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [cohort: "Rental"]
        label: "Companies in Cohort: Rental (EoM)"
        group_label: "Cohorts (Counts)"
      }

      measure: companies_cohort_new {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [cohort: "NEW"]
        label: "Companies in Cohort: NEW (EoM)"
        group_label: "Cohorts (Counts)"
      }

    # ---------- Entrants to a cohort this month (includes first assignments) ----------
      measure: entrants_to_hybrid {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [converted_this_month: "yes", cohort: "Hybrid"]
        label: "Entrants → Hybrid (Month)"
        group_label: "Cohorts (Entrants)"
      }

      measure: entrants_to_t3 {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [converted_this_month: "yes", cohort: "T3"]
        label: "Entrants → T3 (Month)"
        group_label: "Cohorts (Entrants)"
      }

      measure: entrants_to_rental {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [converted_this_month: "yes", cohort: "Rental"]
        label: "Entrants → Rental (Month)"
        group_label: "Cohorts (Entrants)"
      }

    # ---------- True conversions this month (exclude first assignment / no change) ----------
      measure: conversions_to_hybrid {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [is_true_conversion: "yes", cohort: "Hybrid"]
        label: "Conversions → Hybrid (Month)"
        group_label: "Cohorts (Conversions)"
      }

      measure: conversions_to_t3 {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [is_true_conversion: "yes", cohort: "T3"]
        label: "Conversions → T3 (Month)"
        group_label: "Cohorts (Conversions)"
      }

      measure: conversions_to_rental {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [is_true_conversion: "yes", cohort: "Rental"]
        label: "Conversions → Rental (Month)"
        group_label: "Cohorts (Conversions)"
      }

    # ---------- Eligible populations (EoM) for simple conversion rates ----------
      measure: companies_not_hybrid_eom {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [cohort: "-Hybrid"]
        label: "Companies Not Hybrid (EoM)"
        group_label: "Cohorts (Eligibility)"
      }

      measure: companies_not_t3_eom {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [cohort: "-T3"]
        label: "Companies Not T3 (EoM)"
        group_label: "Cohorts (Eligibility)"
      }

      measure: companies_not_rental_eom {
        type: count_distinct
        sql: ${company_id} ;;
        filters: [cohort: "-Rental"]
        label: "Companies Not Rental (EoM)"
        group_label: "Cohorts (Eligibility)"
      }

    # ---------- Simple conversion rates (directional) ----------
    # Note: Uses EoM “not-in-target” as denominator
      measure: conversion_rate_to_hybrid {
        type: number
        value_format_name: percent_2
        sql:
            SUM(CASE
                  WHEN ${converted_this_month}
                   AND ${previous_cohort} IS NOT NULL
                   AND ${previous_cohort} <> ${cohort}
                   AND ${cohort} = 'Hybrid'
                  THEN 1 ELSE 0
                END)
            /
            NULLIF(COUNT(DISTINCT CASE WHEN ${cohort} <> 'Hybrid' THEN ${company_id} END), 0) ;;
        label: "Conversion Rate → Hybrid (Month)"
        group_label: "Cohorts (Conversion Rates)"
      }

      measure: conversion_rate_to_t3 {
        type: number
        value_format_name: percent_2
        sql:
            SUM(CASE
                  WHEN ${converted_this_month}
                   AND ${previous_cohort} IS NOT NULL
                   AND ${previous_cohort} <> ${cohort}
                   AND ${cohort} = 'T3'
                  THEN 1 ELSE 0
                END)
            /
            NULLIF(COUNT(DISTINCT CASE WHEN ${cohort} <> 'T3' THEN ${company_id} END), 0) ;;
        label: "Conversion Rate → T3 (Month)"
        group_label: "Cohorts (Conversion Rates)"
      }

      measure: conversion_rate_to_rental {
        type: number
        value_format_name: percent_2
        sql:
            SUM(CASE
                  WHEN ${converted_this_month}
                   AND ${previous_cohort} IS NOT NULL
                   AND ${previous_cohort} <> ${cohort}
                   AND ${cohort} = 'Rental'
                  THEN 1 ELSE 0
                END)
            /
            NULLIF(COUNT(DISTINCT CASE WHEN ${cohort} <> 'Rental' THEN ${company_id} END), 0) ;;
        label: "Conversion Rate → Rental (Month)"
        group_label: "Cohorts (Conversion Rates)"
      }

    }
