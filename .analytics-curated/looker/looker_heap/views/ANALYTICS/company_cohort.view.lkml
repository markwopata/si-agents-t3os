view: company_cohort {
  derived_table: {
    sql: SELECT
            T.DATE,
            T.UID,
            T.COMPANY_ID,
            T.COMPANY_NAME,
            T.COHORT,
            T.COHORT_START_DATE,
            T.PREVIOUS_COHORT,
            T.PREVIOUS_COHORT_START_DATE,
            T.CONVERTED,
            IFF(T.CONVERTED = TRUE,1,0) AS CONVERT,
            T.ACTIVITY_FLAG,
            A.FIRST_ACTIVITY_DATE,
            A.LAST_ACTIVITY_DATE,
            T.CUSTOMER_ASSETS,
            T.TRACKERS_INSTALLED,
            T.CAMERAS_INSTALLED,
            T.PERCENT_ASSET_TRACKERS_INSTALLED,
            T.ASSETS_DELTA,
            T.TRACKER_DELTA,
            T.CAMERA_DELTA,
            T.TRACKERS_UNINSTALLED,
            T.CAMERAS_UNINSTALLED,
            T.ASSETS_DELETED,
            T.ASSETS_INACTIVE,
            T.RENTALS_CREATED,
            T.UPCOMING_RENTALS,
            T.RENTALS_IN_PROGRESS,
            T.RENTALS_ENDED,
            T.RENTALS_DELTA,
            T.RENTALS_ENDED_DELTA,
            T.ACTIVE_SESSIONS,
            T.ACTIVE_USERS,
            T.ACTIVE_TIME
          FROM (
              SELECT
                  *,
                  ROW_NUMBER() OVER (PARTITION BY COMPANY_ID, MONTH ORDER BY DATE DESC) AS RN
              FROM ANALYTICS.T3_ANALYTICS.COMPANY_COHORT_TRACKER
          ) T
          LEFT JOIN (
              SELECT
                  COMPANY_ID,
                  MIN(DATE) AS FIRST_ACTIVITY_DATE,
                  MAX(DATE) AS LAST_ACTIVITY_DATE
              FROM ANALYTICS.T3_ANALYTICS.COMPANY_COHORT_TRACKER
              GROUP BY COMPANY_ID
          ) A ON T.COMPANY_ID = A.COMPANY_ID
          WHERE T.RN = 1
          ;;
  }

  ########################
  # Primary Key & Core Identifiers
  ########################
  dimension: uid {
    label: "Unique ID"
    type: string
    primary_key: yes
    sql: ${TABLE}.UID ;;
    description: "Unique identifier for the company-month record."
  }

  dimension_group: date {
    label: "Date"
    type: time
    sql: ${TABLE}.DATE ;;
    description: "The specific date of the cohort record."
  }

  dimension: company_id {
    label: "Company ID"
    type: string
    sql: ${TABLE}.COMPANY_ID ;;
    description: "Unique identifier for the company."
  }

  dimension: company_name {
    label: "Company Name"
    type: string
    sql: ${TABLE}.COMPANY_NAME ;;
    description: "Name of the company."
    drill_fields: [detail*]
  }

  measure: company_count {
    label: "Count of Companies"
    type: count_distinct
    sql: ${company_id} ;;
    description: "Count distinct companies in the current result set."
  }

  ########################
  # Cohort & Activity Tracking
  ########################
  dimension: cohort {
    label: "Cohort"
    type: string
    sql: ${TABLE}.COHORT ;;
    description: "Current cohort classification of the company."
    drill_fields: [detail*]
  }

  dimension_group: cohort_start_date {
    label: "Cohort Start Date"
    type: time
    sql: ${TABLE}.COHORT_START_DATE ;;
    description: "The date the company entered the current cohort."
  }

  dimension: previous_cohort {
    label: "Previous Cohort"
    type: string
    sql: ${TABLE}.PREVIOUS_COHORT ;;
    description: "The previous cohort classification before the current one."
    drill_fields: [detail*]
  }

  dimension_group: previous_cohort_start_date {
    label: "Previous Cohort Start Date"
    type: time
    sql: ${TABLE}.PREVIOUS_COHORT_START_DATE ;;
    description: "The date the company entered the previous cohort."
  }

  dimension: converted {
    label: "Converted to New Cohort?"
    type: yesno
    sql: ${TABLE}.CONVERTED ;;
    description: "Indicates if the company converted from a previous cohort to a new one at this month."
    drill_fields: [detail*]
  }

  measure: converted_count {
    label: "Count Converted to New Cohort."
    type: sum
    sql: ${TABLE}.CONVERT ;;
    description: "The count of companies converted from a previous cohort to a new one this month."
    drill_fields: [detail*]
  }

  dimension: activity_flag {
    label: "Activity Flag"
    type: string
    sql: ${TABLE}.ACTIVITY_FLAG ;;
    description: "Categorizes company activity status (e.g., 'Active', 'At Risk', 'Possible Churn')."
    drill_fields: [detail*]
  }

  dimension: first_activity_date {
    label: "First Activity Date"
    type: date
    sql: ${TABLE}.FIRST_ACTIVITY_DATE ;;
    description: "The earliest date of recorded activity for this company."
  }

  dimension: last_activity_date {
    label: "Last Activity Date"
    type: date
    sql: ${TABLE}.LAST_ACTIVITY_DATE ;;
    description: "The most recent date of recorded activity for this company."
  }

  ########################
  # Asset & Tracker Metrics
  ########################
  dimension: customer_assets {
    type: number
    sql: ${TABLE}.CUSTOMER_ASSETS ;;
    description: "Total number of assets the company currently has."
  }

  measure: assets {
    label: "Assets"
    type: sum
    sql: ${customer_assets} ;;
    value_format: "#,##0"
    description: "Sum of total assets across the selected results."
    drill_fields: [detail*]
  }

  dimension: trackers_installed {
    type: number
    sql: ${TABLE}.TRACKERS_INSTALLED ;;
    description: "Total number of trackers currently installed on assets."
  }

  measure: total_trackers_installed {
    label: "Trackers Installed"
    type: sum
    sql: ${trackers_installed} ;;
    value_format: "#,##0"
    description: "Sum of currently installed trackers across selected results."
    drill_fields: [detail*]
  }

  dimension: cameras_installed {
    type: number
    sql: ${TABLE}.CAMERAS_INSTALLED ;;
    description: "Total number of cameras currently installed."
  }

  measure: total_cameras_installed {
    label: "Cameras Installed"
    type: sum
    sql: ${cameras_installed} ;;
    value_format: "#,##0"
    description: "Sum of currently installed cameras across selected results."
    drill_fields: [detail*]
  }

  measure: devices_installed {
    label: "Devices Installed"
    type: sum
    sql:  ${TABLE}.TOTAL_TRACKERS_INSTALLED + ${TABLE}.TOTAL_CAMERAS_INSTALLED ;;
    value_format: "#,##0"
    drill_fields: [detail*]
  }

  dimension: percent_asset_trackers_installed {
    type: number
    sql: ${TABLE}.PERCENT_ASSET_TRACKERS_INSTALLED ;;
    description: "Percentage of assets that currently have trackers installed."
  }

  measure: percent_trackers_installed {
    label: "% of Assets with Trackers"
    type: number
    sql:  coalesce(${trackers_installed}/case when ${assets} = 0 then null else ${assets}END, 0) ;;
    value_format_name: percent_1
    description: "Percentage of assets with trackers installed across selected companies."
    drill_fields: [detail*]
  }

  dimension: assets_delta {
    type: number
    sql: ${TABLE}.ASSETS_DELTA ;;
    description: "Change in total assets since the previous period."
  }

  measure: total_assets_added {
    label: "Assets Added"
    type: sum
    sql: ${assets_delta} ;;
    value_format: "#,##0"
    description: "Sum of changes in assets (added) across selected results."
    drill_fields: [detail*]
  }

  dimension: tracker_delta {
    type: number
    sql: ${TABLE}.TRACKER_DELTA ;;
    description: "Change in number of trackers installed since the previous period."
  }

  measure: total_trackers_added {
    label: "Trackers Added"
    type: sum
    sql: ${tracker_delta} ;;
    value_format: "#,##0"
    description: "Sum of newly added trackers across selected results."
    drill_fields: [detail*]
  }

  dimension: camera_delta {
    type: number
    sql: ${TABLE}.CAMERA_DELTA ;;
    description: "Change in number of cameras installed since the previous period."
  }

  measure: total_cameras_added {
    label: "Cameras Added"
    type: sum
    sql: ${camera_delta} ;;
    value_format: "#,##0"
    description: "Sum of newly added cameras across selected results."
    drill_fields: [detail*]
  }

  dimension: trackers_uninstalled {
    type: number
    sql: ${TABLE}.TRACKERS_UNINSTALLED ;;
    description: "Number of trackers uninstalled."
  }

  measure: uninstalled_trackers {
    label: "Uninstalled Trackers"
    type: sum
    sql: ${trackers_uninstalled} ;;
    value_format: "#,##0"
    description: "Sum of trackers uninstalled across selected results."
    drill_fields: [detail*]
  }

  dimension: cameras_uninstalled {
    type: number
    sql: ${TABLE}.CAMERAS_UNINSTALLED ;;
    description: "Number of cameras uninstalled."
  }

  measure: uninstalled_cameras {
    label: "Uninstalled Cameras"
    type: sum
    sql: ${cameras_uninstalled} ;;
    value_format: "#,##0"
    description: "Sum of cameras uninstalled across selected results."
    drill_fields: [detail*]
  }

  dimension: assets_deleted {
    type: number
    sql: ${TABLE}.ASSETS_DELETED ;;
    description: "Number of assets deleted."
  }

  measure: deleted_assets {
    label: "Deleted Assets"
    type: sum
    sql: ${assets_deleted} ;;
    value_format: "#,##0"
    description: "Sum of assets deleted across selected results."
    drill_fields: [detail*]
  }

  dimension: assets_inactive {
    type: number
    sql: ${TABLE}.ASSETS_INACTIVE ;;
    description: "Number of assets deleted."
  }

  measure: inactive_assets {
    label: "Inactive Assets"
    type: sum
    sql: ${assets_inactive} ;;
    value_format: "#,##0"
    description: "Sum of assets inactive across selected results."
    drill_fields: [detail*]
  }

  ########################
  # Rental Metrics
  ########################
  dimension: rentals_created {
    type: number
    sql: ${TABLE}.RENTALS_CREATED ;;
    description: "Number of rentals created."
  }

  measure: created_rentals {
    label: "Rentals Created"
    type: sum
    sql: ${rentals_created} ;;
    value_format: "#,##0"
    description: "Sum of rentals created across selected results."
    drill_fields: [detail*]
  }


  dimension: upcoming_rentals {
    type: number
    sql: ${TABLE}.UPCOMING_RENTALS ;;
    description: "Number of upcoming rentals."
  }

  measure: rentals_upcoming {
    label: "Upcoming Rentals"
    type: sum
    sql: ${upcoming_rentals} ;;
    value_format: "#,##0"
    description: "Sum of upcoming rentals across selected results."
    drill_fields: [detail*]
  }

  dimension: rentals_in_progress {
    type: number
    sql: ${TABLE}.RENTALS_IN_PROGRESS ;;
    description: "Number of rentals currently in progress."
  }

  measure: current_rentals_in_progress {
    label: "Rentals in Progress"
    type: sum
    sql: ${rentals_in_progress} ;;
    value_format: "#,##0"
    description: "Sum of rentals currently in progress across selected results."
    drill_fields: [detail*]
  }

  dimension: rentals_ended {
    type: number
    sql: ${TABLE}.RENTALS_ENDED ;;
    description: "Number of rentals ended to date."
  }

  measure: rentals_completed {
    label: "Rentals Completed"
    type: sum
    sql: ${rentals_ended} ;;
    value_format: "#,##0"
    description: "Sum of completed rentals across selected results."
    drill_fields: [detail*]
  }

  dimension: rentals_delta {
    type: number
    sql: ${TABLE}.RENTALS_DELTA ;;
    description: "Change in rentals since the previous period."
  }

  measure: total_rentals_added {
    label: "Rentals Added"
    type: sum
    sql: ${rentals_delta} ;;
    value_format: "#,##0"
    description: "Sum of newly added rentals across selected results."
    drill_fields: [detail*]
  }

  dimension: rentals_ended_delta {
    type: number
    sql: ${TABLE}.RENTALS_ENDED_DELTA ;;
    description: "Change in ended rentals since the previous period."
  }

  measure: total_rentals_ended {
    label: "Rentals Ended"
    type: sum
    sql: ${rentals_ended_delta} ;;
    value_format: "#,##0"
    description: "Sum of newly ended rentals across selected results."
    drill_fields: [detail*]
  }

  ########################
  # Monthly Session Data
  ########################
  dimension: month_active_sessions {
    type: number
    sql: ${TABLE}.MONTH_ACTIVE_SESSIONS ;;
    description: "Number of active sessions in the given month."
  }

  measure: active_sessions {
    label: "Active Sessions"
    type: sum
    sql: ${month_active_sessions} ;;
    value_format: "#,##0"
    description: "Sum of monthly active sessions across selected results."
    drill_fields: [detail*]
  }

  dimension: month_active_users {
    type: number
    sql: ${TABLE}.MONTH_ACTIVE_USERS ;;
    description: "Number of active users in the given month."
  }

  measure: active_users {
    label: "Active Users"
    type: sum
    sql: ${month_active_users} ;;
    value_format: "#,##0"
    description: "Sum of monthly active users across selected results."
    drill_fields: [detail*]
  }

  dimension: month_active_time {
    type: number
    sql: ${TABLE}.MONTH_ACTIVE_TIME ;;
    description: "Total active time (in seconds) in the given month."
  }

  measure: active_time {
    label: "Active Time on T3"
    type: sum
    sql: ${month_active_time} ;;
    value_format: "#,##0"
    description: "Sum of monthly active time across selected results."
    drill_fields: [detail*]
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
  # Detail Set for Drilling
  ########################
  set: detail {
    fields: [
      uid,
      date_date,
      company_id,
      company_name,
      cohort,
      cohort_start_date_date,
      previous_cohort,
      previous_cohort_start_date_date,
      converted,
      activity_flag,
      first_activity_date,
      last_activity_date,
      customer_assets,
      total_trackers_installed,
      total_cameras_installed,
      percent_asset_trackers_installed,
      upcoming_rentals,
      rentals_in_progress,
      month_active_sessions,
      month_active_users,
      month_active_time,
      assets_delta,
      tracker_delta,
      camera_delta
    ]
  }
}
