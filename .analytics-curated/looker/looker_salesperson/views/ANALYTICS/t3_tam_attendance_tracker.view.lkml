view: t3_tam_attendance_tracker {
  derived_table: {
    sql:
      WITH completed AS (
        SELECT
          cd.work_email                                AS email,
          MAX(eh.enrollment_date_complete)             AS esu_completion_date
        FROM analytics.docebo.enrollment_history eh
        JOIN analytics.docebo.enrollments e
          ON eh.course_uidcourse = e.course_uid
        JOIN analytics.docebo.courses c
          ON e.course_id = c.id_course
        JOIN analytics.payroll.company_directory cd
          ON cd.employee_id = TRY_CAST(eh.user_userid AS INTEGER)
        WHERE
          UPPER(c.name) = 'T3 FUNDAMENTALS'
          AND eh.enrollment_status = 'Completed'
          AND UPPER(cd.employee_title) = 'TERRITORY ACCOUNT MANAGER'
          AND cd.work_email IS NOT NULL
        GROUP BY cd.work_email
      ),
      attended AS (
        SELECT
          LOWER(email)         AS email,
          MAX(attended_date)   AS attended_date
        FROM analytics.bi_ops.t_3_tam_referral_attendance
        WHERE email IS NOT NULL
        GROUP BY LOWER(email)
      )
      SELECT
        LOWER(cd.work_email)   AS email,
        cd.first_name,
        cd.last_name,
        cd.employee_id,
        cd.employee_title,
        cd.location,
        comp.esu_completion_date,
        att.attended_date
      FROM analytics.payroll.company_directory cd
      LEFT JOIN completed comp
        ON LOWER(cd.work_email) = comp.email
      LEFT JOIN attended att
        ON LOWER(cd.work_email) = att.email
      WHERE
        cd.employee_title ILIKE '%territory account manager%'
        AND cd.employee_status = 'Active'
    ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: tam_drill_name {
    type: string
    sql: CONCAT(${TABLE}.first_name, ' ', ${TABLE}.last_name) ;;
  }

  dimension: employee_id {
    type: string
    sql: ${TABLE}.employee_id ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}.employee_title ;;
  }

  dimension: employee_location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: esu_completion_date {
    type: date
    sql: ${TABLE}.esu_completion_date ;;
  }

  dimension: t3_referral_attended_date {
    type: string
    sql: ${TABLE}.attended_date ;;
  }

  dimension: tam_status {
    type: string
    sql:
      CASE
        WHEN ${esu_completion_date} IS NULL
          AND ${t3_referral_attended_date} IS NULL THEN 'Missing both'
        WHEN ${esu_completion_date} IS NULL THEN 'Missing ESU date'
        WHEN ${t3_referral_attended_date} IS NULL THEN 'Missing attended date'
        ELSE 'Has both'
      END
    ;;
  }

  set: detail {
    fields: [
      tam_drill_name,
      email,
      employee_id,
      employee_title,
      employee_location,
      esu_completion_date,
      t3_referral_attended_date
    ]
  }

  measure: count_has_both {
    type: count_distinct
    sql: ${email} ;;
    filters: [tam_status: "Has both"]
    drill_fields: [tam_drill_name, email, employee_location]
  }

  measure: count_missing_esu_date {
    type: count_distinct
    sql: ${email} ;;
    filters: [tam_status: "Missing ESU date"]
    drill_fields: [tam_drill_name, email, employee_location]
  }

  measure: count_missing_attended_date {
    type: count_distinct
    sql: ${email} ;;
    filters: [tam_status: "Missing attended date"]
    drill_fields: [tam_drill_name, email, employee_location]
  }

  measure: count_missing_both {
    type: count_distinct
    sql: ${email} ;;
    filters: [tam_status: "Missing both"]
    drill_fields: [tam_drill_name, email, employee_location]
  }

}
