view: docebo_historical_enrollment {

    sql_table_name:"ANALYTICS"."DOCEBO"."ENROLLMENT_HISTORY";;

    dimension: unique_record {
      type: string
      primary_key: yes
      sql: CONCAT(CONCAT(${course_uid}, '_'), ${user_id}) ;;
    }

    dimension: user_id {
      label: "User ID"
      type: string
      sql: ${TABLE}."USER_USERID";;
    }

    dimension: firstname {
      type: string
      sql:  ${TABLE}."USER_FIRSTNAME" ;;
    }

    dimension: lastname {
      type: string
      sql:  ${TABLE}."USER_LASTNAME" ;;
    }

    dimension: user_email {
      label: "Email"
      type: string
      sql: ${TABLE}."USER_EMAIL" ;;
    }

    dimension: level {
      type: string
      sql:  ${TABLE}."ENROLLMENT_LEVEL" ;;
    }

    dimension: course_uid {
      type: string
      sql:  ${TABLE}."COURSE_UIDCOURSE" ;;
    }

    dimension: course_name {
      type: string
      sql: ${TABLE}."COURSE_NAME" ;;
    }

    dimension: course_type {
      type: string
      sql:  ${TABLE}."COURSE_COURSE_TYPE" ;;
    }

    dimension: course_begin {
      type: date
      sql: ${TABLE}."COURSE_DATE_BEGIN" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: course_end {
      type: date
      sql: ${TABLE}."COURSE_DATE_END" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: course_status {
      type: string
      sql: ${TABLE}."COURSE_STATUS" ;;
    }

    dimension: course_expired {
      type: string
      sql: ${TABLE}."COURSE_EXPIRED" ;;
    }

    dimension: enrollment_begin {
      type: date
      sql:  ${TABLE}."ENROLLMENT_DATE_BEGIN_VALIDITY" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: enrollment_end {
      type: date
      sql: ${TABLE}."ENROLLMENT_DATE_EXPIRE_VALIDITY" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: enrollment_complete_date {
      type: date
      sql: ${TABLE}."ENROLLMENT_DATE_COMPLETE" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: enrollment_subscription_date {
      type: date
      sql:${TABLE}."ENROLLMENT_DATE_INSCR" ;;
      html: {{ rendered_value | date: "%b %d, %Y"  }};;
    }

    dimension: enrollment_status  {
      type: string
      sql: ${TABLE}."ENROLLMENT_STATUS" ;;
    }

    dimension: session_count {
      type: number
      sql: CAST(${TABLE}."ENROLLMENT_NUMBER_OF_SESSIONS" as INTEGER) ;;
    }

  dimension: course_category {
    type: string
    sql: ${TABLE}."COURSE_COURSESCATEGORY_TRANSLATION" ;;
  }

  dimension: overdue {
    type:  yesno
    sql:  ${end_date_date} < CURRENT_DATE() and ${enrollment_status} != 'Completed' ;;
  }

  ####. added for MoM comparision - 2022-07-10 BES ####
  dimension_group: current_date_advanced {
    type: duration
    intervals: [day, month, hour]
    sql_start: ${start_date} ;;
    sql_end: CURRENT_DATE() ;;
  }

  dimension: start_date {
    type: date
    sql: min(${course_begin}) ;;
  }

  dimension_group: end_date {
    type: time
    timeframes: [date, month, year]
    sql: COALESCE(COALESCE(${enrollment_end}, ${course_end}), CURRENT_DATE()) ;;
  }

  dimension: overdue_at_date {
    type: yesno
    sql:${end_date_date} >= ${enrollment_complete_date} ;;
  }
  ####################################################

  dimension_group: since_course_expire {
    type: duration
    intervals: [day, hour]
    sql_start: COALESCE(${enrollment_end}, ${course_end});;
    sql_end: CURRENT_DATE();;
  }

  measure: days_overdue {
    type: average
    sql: CASE WHEN ${overdue} THEN ${days_since_course_expire} ELSE 0 END ;;
  }

  measure: completed_count {
    type:  count
    filters: [enrollment_status: "Completed"]
    drill_fields: [enrollment_details*]
  }

  measure: subscribed_count {
    type:  count
    filters: [enrollment_status: "Subscribed"]
    drill_fields: [enrollment_details*]
  }

  measure: in_progress_count {
    type:  count
    filters: [enrollment_status: "In Progress"]
    drill_fields: [enrollment_details*]
  }

  measure: overdue_count {
    type: sum
    filters: [overdue: "yes"]
    drill_fields: [enrollment_details*, days_overdue]
    sql: CASE WHEN ${overdue} THEN 1 ELSE 0 END;;
  }

  measure: course_count {
    type: count
    drill_fields: [enrollment_details*]
  }

  measure: percent_complete {
    type: percent_of_total
    drill_fields: [user_details*]
    sql: ${completed_count} ;;
  }

  set: enrollment_details {
    fields: [user_id, firstname, lastname, company_directory.employee_title, docebo_users.market_name, market_region_xwalk_with_extensions.district, user_email, docebo_users.manager_email, course_name, enrollment_status, docebo_enrollments.self_enrolled]
  }

  set: user_details {
    fields: [user_id, firstname, lastname, company_directory.employee_title, docebo_users.market_name, market_region_xwalk_with_extensions.district, user_email, docebo_users.manager_email, percent_complete, course_count, completed_count, overdue_count]
  }

}
