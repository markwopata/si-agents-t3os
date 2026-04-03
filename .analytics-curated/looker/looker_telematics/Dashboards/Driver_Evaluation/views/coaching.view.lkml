view: coaching {
  derived_table: {
    sql: SELECT
          u.user_id,
          dcmb.created_at,
          dcmb.coaching_status,
          dcmb.coaching_severity,
          dcmb.primary_violation_type,
          dcmb.secondary_violation_type,
          dcmb.asset_id,
          dcmb.vehicle_type,
          dcmb.probation_start_date,
          dcmb.probation_end_date,
          dcmb.coaching_due_date,
          IFF(dcmb.coaching_status = 'Coaching Complete',
              COALESCE(dcmb.coaching_completed_date, dcmb.coaching_due_date),
              dcmb.coaching_completed_date) as coaching_completed_date_helper,
          {% if time_interval._parameter_value == "'Monthly'" %}
          date_trunc('month', coaching_completed_date_helper) as coaching_completed_week,
          {% else %}
          date_trunc('week', coaching_completed_date_helper) as coaching_completed_week,
          {% endif %}
          dcmb.coach_name,
          dcmb.manager_email,
          dcmb.notes,
          datediff(day, LAG(coaching_completed_date_helper) OVER(PARTITION BY u.user_id, dcmb.coaching_status
                                                                 ORDER BY coaching_completed_date_helper),
                       coaching_completed_date_helper
                  ) as days_since_last_coaching,
          NTH_VALUE(dcmb.primary_violation_type, 2) OVER(PARTITION BY u.user_id, dcmb.coaching_status
                                                         ORDER BY coaching_completed_date_helper desc
                                                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                    as previous_primary_violation,
          NTH_VALUE(dcmb.secondary_violation_type, 2) OVER(PARTITION BY u.user_id, dcmb.coaching_status
                                                         ORDER BY coaching_completed_date_helper desc
                                                         ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                    as previous_secondary_violation,
          LAST_VALUE(dcmb.primary_violation_type) OVER(PARTITION BY u.user_id, dcmb.coaching_status
                                                       ORDER BY coaching_completed_date_helper
                                                       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                    as latest_primary_violation,
          LAST_VALUE(dcmb.secondary_violation_type) OVER(PARTITION BY u.user_id, dcmb.coaching_status
                                                       ORDER BY coaching_completed_date_helper
                                                       ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING)
                    as latest_secondary_violation
      FROM analytics.monday.driver_coaching_management_board dcmb
      JOIN es_warehouse.public.users u ON lower(dcmb.employee_email) = lower(u.email_address)
      ;;
  }

  dimension: key {
    type: string
    primary_key: yes
    sql:  CONCAT(${user_id}, ' ', ${created_at});;
  }

  measure: count {
    type: count_distinct
    sql: CONCAT(${user_id}, ' ', ${created_at});;
  }

  measure: count_detail {
    type: count
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: created_at {
    type: date_time
    sql: ${TABLE}."CREATED_AT" ;;
  }

  dimension: coaching_status {
    type: string
    sql: ${TABLE}."COACHING_STATUS" ;;
  }

  dimension: coaching_severity {
    type: string
    sql: ${TABLE}."COACHING_SEVERITY" ;;
  }

  dimension: primary_violation_type {
    type: string
    sql: ${TABLE}."PRIMARY_VIOLATION_TYPE" ;;
  }

  dimension: secondary_violation_type {
    type: string
    sql: ${TABLE}."SECONDARY_VIOLATION_TYPE" ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: vehicle_type {
    type: string
    sql: ${TABLE}."VEHICLE_TYPE" ;;
  }

  dimension: probation_start_date {
    type: date
    sql: ${TABLE}."PROBATION_START_DATE" ;;
  }

  dimension: probation_end_date {
    type: date
    sql: ${TABLE}."PROBATION_END_DATE" ;;
  }

  dimension: coaching_due_date {
    type: date
    sql: ${TABLE}."COACHING_DUE_DATE" ;;
  }

  dimension: coaching_completed_date {
    type: date
    sql: ${TABLE}."COACHING_COMPLETED_DATE_HELPER" ;;
  }

  dimension: coaching_completed_week {
    type: date
    sql: ${TABLE}."COACHING_COMPLETED_WEEK" ;;
  }

  dimension: coach_name {
    type: string
    sql: ${TABLE}."COACH_NAME" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: notes {
    type: string
    sql: ${TABLE}."NOTES" ;;
  }

  dimension: days_since_last_coaching {
    type: number
    sql: ${TABLE}."DAYS_SINCE_LAST_COACHING" ;;
  }

  dimension: previous_primary_violation {
    type: string
    sql: ${TABLE}."PREVIOUS_PRIMARY_VIOLATION" ;;
  }

  dimension: latest_primary_violation {
    type: string
    sql: ${TABLE}."LATEST_PRIMARY_VIOLATION" ;;
  }

  dimension: previous_secondary_violation {
    type: string
    sql: ${TABLE}."PREVIOUS_SECONDARY_VIOLATION" ;;
  }

  dimension: latest_secondary_violation {
    type: string
    sql: ${TABLE}."LATEST_SECONDARY_VIOLATION" ;;
  }

  dimension: on_probation {
    type: yesno
    sql: convert_timezone('America/Chicago', current_timestamp)::date BETWEEN ${probation_start_date} AND ${probation_end_date};;
  }

  measure: sent_count {
    group_label: "Coaching Status Counts"
    label: "Sent"
    type: count_distinct
    sql: CONCAT(${user_id}, ' ', ${created_at});;
    filters: [coaching_status: "Sent to GM/Coach"]
  }

  measure: inactive_count {
    group_label: "Coaching Status Counts"
    label: "Inactive"
    type: count_distinct
    sql: CONCAT(${user_id}, ' ', ${created_at});;
    filters: [coaching_status: "Inactive"]
  }

  measure: complete_count {
    group_label: "Coaching Status Counts"
    label: "Complete"
    type: count_distinct
    sql: CONCAT(${user_id}, ' ', ${created_at});;
    filters: [coaching_status: "Coaching Complete"]
  }

  measure: review_count {
    group_label: "Coaching Status Counts"
    label: "Needs Review"
    type: count_distinct
    sql: CONCAT(${user_id}, ' ', ${created_at});;
    filters: [coaching_status: "Needs Further Review"]
  }

  measure: new_count {
    group_label: "Coaching Status Counts"
    label: "New"
    type: count_distinct
    sql: CONCAT(${user_id}, ' ', ${created_at});;
    filters: [coaching_status: "New"]
  }

  measure: other_count {
    group_label: "Coaching Status Counts"
    label: "Other"
    type: count_distinct
    sql: CONCAT(${user_id}, ' ', ${created_at});;
    filters: [coaching_status: "-Sent to GM/Coach, -Inactive, -Coaching Complete, -Needs Further Review, -New"]
  }

  measure: drivers_on_probation_count {
    label: "Drivers On Probation"
    type: count_distinct
    sql: ${user_id} ;;
    filters: [on_probation: "Yes"]
  }

  measure: average_days_between_coaching {
    type: average
    sql: ${days_since_last_coaching} ;;
    filters: [coaching_status: "Coaching Complete"]
  }

  measure: primary_violations {
    type: string
    sql: listagg(distinct ${primary_violation_type}, ', ') ;;
  }

  measure: secondary_violations {
    type: string
    sql: listagg(distinct ${secondary_violation_type}, ', ') ;;
  }

  measure: two_latest_primary_violations_count {
    type: count_distinct
    sql: ${user_id} ;;
    filters: [coaching_status: "Coaching Complete"]
  }

  dimension: previous_same_as_latest {
    type: yesno
    sql: ${previous_primary_violation} = ${latest_primary_violation} ;;
  }

  dimension: previous_violation {
    type: string
    sql:  CONCAT(${previous_primary_violation},
                 IFF(${previous_secondary_violation} IS NOT NULL, CONCAT(' & ', ${previous_secondary_violation}), '')) ;;
  }

  dimension: latest_violation {
    type: string
    sql: CONCAT(${latest_primary_violation},
                IFF(${latest_secondary_violation} IS NOT NULL, CONCAT(' & ', ${latest_secondary_violation}), ''));;
  }

  dimension: previous_same_as_latest_2 {
    type: yesno
    sql: ${previous_primary_violation} = ${latest_primary_violation} OR
         ${previous_primary_violation} = ${latest_secondary_violation} OR
         ${previous_secondary_violation} = ${latest_primary_violation} OR
         ${previous_secondary_violation} = ${latest_secondary_violation};;
  }

  dimension: repeat_offense {
    type: string
    sql: CASE WHEN ${previous_primary_violation} = ${latest_primary_violation} THEN ${latest_primary_violation}
              WHEN ${previous_primary_violation} = ${latest_secondary_violation} THEN ${latest_secondary_violation}
              WHEN ${previous_secondary_violation} = ${latest_primary_violation} THEN ${latest_primary_violation}
              WHEN ${previous_secondary_violation} = ${latest_secondary_violation} THEN ${latest_secondary_violation}
              ELSE null END;;
  }

  parameter: time_interval {
    type: string
    allowed_value: {value: "Weekly"}
    allowed_value: {value: "Monthly"}
  }

  # parameter: exclude_seatbelt {
  #   type: string
  #   allowed_value: { value: "Yes"}
  #   allowed_value: { value: "No"}
  # }

  set: detail {
    fields: [
      coaching_severity,
      primary_violation_type,
      secondary_violation_type,
      asset_id,
      vehicle_type,
      probation_start_date,
      probation_end_date,
      coaching_due_date,
      coaching_completed_date,
      coach_name,
      manager_email,
      notes
    ]
  }
}
