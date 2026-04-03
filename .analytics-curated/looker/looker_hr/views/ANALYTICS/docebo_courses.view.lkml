view: docebo_courses {
  sql_table_name: "PUBLIC"."DOCEBO_COURSES"
    ;;

  dimension: _file {
    type: string
    sql: ${TABLE}."_FILE" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: _line {
    type: number
    sql: ${TABLE}."_LINE" ;;
  }

  dimension_group: _modified {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: CAST(${TABLE}."_MODIFIED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: are_you_a_manager_ {
    type: string
    sql: ${TABLE}."ARE_YOU_A_MANAGER_" ;;
  }

  dimension_group: completion {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."COMPLETION_DATE" ;;
  }

  dimension: course_category {
    type: string
    sql: ${TABLE}."COURSE_CATEGORY" ;;
  }

  dimension_group: course_creation {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."COURSE_CREATION_DATE" ;;
  }

  dimension: course_duration {
    type: number
    sql: ${TABLE}."COURSE_DURATION" ;;
  }

  dimension: course_e_signature {
    type: string
    sql: ${TABLE}."COURSE_E_SIGNATURE" ;;
  }

  dimension_group: course_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."COURSE_END_DATE" ;;
  }

  dimension_group: course_first_access {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."COURSE_FIRST_ACCESS_DATE" ;;
  }

  dimension: course_has_expired {
    type: string
    sql: ${TABLE}."COURSE_HAS_EXPIRED" ;;
  }

  dimension: course_internal_id {
    type: number
    sql: ${TABLE}."COURSE_INTERNAL_ID" ;;
  }

  dimension_group: course_last_access {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."COURSE_LAST_ACCESS_DATE" ;;
  }

  dimension: course_name {
    type: string
    sql: ${TABLE}."COURSE_NAME" ;;
  }

  dimension: course_progress_ {
    type: number
    sql: ${TABLE}."COURSE_PROGRESS_" ;;
  }

  dimension: course_status {
    type: string
    sql: ${TABLE}."COURSE_STATUS" ;;
  }

  dimension: course_type {
    type: string
    sql: ${TABLE}."COURSE_TYPE" ;;
  }

  dimension: course_unique_id {
    type: string
    sql: ${TABLE}."COURSE_UNIQUE_ID" ;;
  }

  dimension: credits_ceus_ {
    type: number
    sql: ${TABLE}."CREDITS_CEUS_" ;;
  }

  dimension: deactivated {
    type: string
    sql: ${TABLE}."DEACTIVATED" ;;
  }

  dimension: department_code {
    type: number
    sql: ${TABLE}."DEPARTMENT_CODE" ;;
  }

  dimension: department_name {
    type: string
    sql: ${TABLE}."DEPARTMENT_NAME" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: email_validation_status {
    type: string
    sql: ${TABLE}."EMAIL_VALIDATION_STATUS" ;;
  }

  dimension: employee_number {
    type: number
    sql: ${TABLE}."EMPLOYEE_NUMBER" ;;
  }

  dimension: employee_title {
    type: string
    sql: ${TABLE}."EMPLOYEE_TITLE" ;;
  }

  dimension_group: enrollment {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."ENROLLMENT_DATE" ;;
  }

  dimension_group: enrollment_end {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."ENROLLMENT_END_DATE" ;;
  }

  dimension_group: enrollment_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."ENROLLMENT_START_DATE" ;;
  }

  dimension: enrollment_status {
    type: string
    sql: ${TABLE}."ENROLLMENT_STATUS" ;;
  }

  dimension: final_score {
    type: number
    sql: ${TABLE}."FINAL_SCORE" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: full_name {
    type: string
    sql: ${TABLE}."FULL_NAME" ;;
  }

  dimension_group: hire {
    type: time
    timeframes: [
      raw,
      date,
      week,
      month,
      quarter,
      year
    ]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."HIRE_DATE" ;;
  }

  dimension: hourly_salary {
    type: string
    sql: ${TABLE}."HOURLY_SALARY" ;;
  }

  dimension: initial_score {
    type: number
    sql: ${TABLE}."INITIAL_SCORE" ;;
  }

  dimension: language {
    type: string
    sql: ${TABLE}."LANGUAGE" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension: manager {
    type: string
    sql: ${TABLE}."MANAGER" ;;
  }

  dimension: manager_email {
    type: string
    sql: ${TABLE}."MANAGER_EMAIL" ;;
  }

  dimension: manager_employee_number {
    type: number
    sql: ${TABLE}."MANAGER_EMPLOYEE_NUMBER" ;;
  }

  dimension: market_address {
    type: string
    sql: ${TABLE}."MARKET_ADDRESS" ;;
  }

  dimension: number_of_actions {
    type: number
    sql: ${TABLE}."NUMBER_OF_ACTIONS" ;;
  }

  dimension: number_of_sessions {
    type: number
    sql: ${TABLE}."NUMBER_OF_SESSIONS" ;;
  }

  dimension: rate_type {
    type: string
    sql: ${TABLE}."RATE_TYPE" ;;
  }

  dimension: training_material_time {
    type: number
    sql: ${TABLE}."TRAINING_MATERIAL_TIME" ;;
  }

  dimension: user_course_level {
    type: string
    sql: ${TABLE}."USER_COURSE_LEVEL" ;;
  }

  dimension_group: user_creation {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."USER_CREATION_DATE" ;;
  }

  dimension_group: user_last_access {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}."USER_LAST_ACCESS_DATE" ;;
  }

  dimension: user_level {
    type: string
    sql: ${TABLE}."USER_LEVEL" ;;
  }

  dimension: user_unique_id {
    type: number
    sql: ${TABLE}."USER_UNIQUE_ID" ;;
  }

  dimension: username {
    type: string
    sql: ${TABLE}."USERNAME" ;;
  }

  dimension: work_location {
    type: string
    sql: ${TABLE}."WORK_LOCATION" ;;
  }



  measure: count_completions {
    type: number
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: count(${completion_date}) ;;
     }

  measure: average_final_score {
    type: average
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
       sql: ${final_score}/100 ;;
     }

  measure: average_number_actions {
    type: average
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: ${number_of_actions} ;;
     }

  measure: average_number_sessions {
    type: average
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: ${number_of_sessions} ;;
     }

  measure: average_training_material_time {
    type: average
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: ${training_material_time} ;;
     }

  measure: training_completion_rate {
    type: average
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: ${course_progress_}/100 ;;
     }

  dimension: pass_fail {
    type: number
       sql: case when ${final_score} >= 80 then 1 else 0 end ;;
  }

  measure: pass_rate {
    type: number
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: sum(${pass_fail})/count(${pass_fail}) ;;
     }

  dimension: days_to_completion{
    type: number
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: DATEDIFF( day, ${enrollment_start_date}, ${completion_date}) ;;
  }

  measure: average_time_to_completion{
    type: average
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: ${days_to_completion} ;;
    }

  measure: total_actions {
    type: sum
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: ${number_of_actions} ;;

  }

  measure: total_sessions {
    type: sum
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: ${number_of_sessions} ;;
    }



  measure: total_training_material_time {
    type: sum
    link: {
      label: "Detail"
      url: "
      {% if docebo_courses.full_name._is_filtered %}
      https://equipmentshare.looker.com/dashboards/338?Employee%20Name={{ docebo_courses.full_name._filterable_value | url_encode }}
      &Employee%20Number={{ ukg_employee_details.employee_id._filterable_value | url_encode }}
      &Employee%20Title={{ ukg_employee_details.employee_title._filterable_value | url_encode }}
      &Location%20Name={{ ukg_employee_details.location._filterable_value | url_encode }}
      &Manager={{ ukg_employee_details.direct_manager_name._filterable_value | url_encode }}
      &Course%20Name={{ docebo_courses.course_name._filterable_value | url_encode }}
      &Course%20Category={{ docebo_courses.course_category._filterable_value | url_encode }}
      &Employee%20Type={{ ukg_employee_details.employee_type._filterable_value | url_encode }}
      &Enrollment%20Status={{ docebo_courses.enrollment_status._filterable_value | url_encode }}
      &Course%20Type={{ docebo_courses.course_type._filterable_value | url_encode }}
      {% else %}
      https://equipmentshare.looker.com/dashboards/338?
      {% endif %}"
    }
    sql: ${training_material_time}/3600 ;;
      }






}
