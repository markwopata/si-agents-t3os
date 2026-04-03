view: coaching_fan_out {
  derived_table: {
    sql:
        WITH violations AS (
          SELECT distinct primary_violation_type as violation
          FROM analytics.monday.driver_coaching_management_board
          WHERE primary_violation_type IS NOT NULL
          UNION
          SELECT distinct secondary_violation_type as violation
          FROM analytics.monday.driver_coaching_management_board
          WHERE secondary_violation_type IS NOT NULL
        )

        SELECT
          v.violation,
          u.user_id,
          dcmb.created_at,
          dcmb.coaching_status,
          dcmb.coaching_severity,
          IFF(dcmb.coaching_status = 'Coaching Complete',
              COALESCE(dcmb.coaching_completed_date, dcmb.coaching_due_date),
              dcmb.coaching_completed_date)
            as coaching_completed_date_helper,
          IFF(v.violation = dcmb.primary_violation_type, 1, 0) as primary_violation_flag,
          IFF(v.violation = dcmb.secondary_violation_type, 1, 0) as secondary_violation_flag,
      FROM analytics.monday.driver_coaching_management_board dcmb
      JOIN es_warehouse.public.users u ON lower(dcmb.employee_email) = lower(u.email_address)
      CROSS JOIN violations v
      ;;
  }

  dimension: key {
    type: string
    sql: CONCAT(${user_id}, ' ', ${created_at}) ;;
  }

  measure: count {
    type: count
  }

  dimension: violation {
    type: string
    sql: ${TABLE}."VIOLATION" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: created_at {
    type: date_time
    sql: ${TABLE}."CREATED_AT" ;;
    convert_tz: no
  }

  dimension: coaching_status {
    type: string
    sql: ${TABLE}."COACHING_STATUS" ;;
  }

  dimension: coaching_severity {
    type: string
    sql: ${TABLE}."COACHING_SEVERITY" ;;
  }

  dimension: coaching_completed_date_helper {
    type: date
    sql: ${TABLE}."COACHING_COMPLETED_DATE_HELPER" ;;
  }

  dimension: primary_violation_flag {
    type: number
    sql: ${TABLE}."PRIMARY_VIOLATION_FLAG" ;;
  }

  dimension: secondary_violation_flag {
    type: number
    sql: ${TABLE}."SECONDARY_VIOLATION_FLAG" ;;
  }

  measure: primary_violations {
    type: sum
    sql: ${primary_violation_flag} ;;
  }

  measure: secondary_violations {
    type: sum
    sql: ${secondary_violation_flag} ;;
  }
}
