view: stages_info_view {
  sql_table_name: "GREENHOUSE"."STAGES_INFO_VIEW"
    ;;

  dimension_group: application_review_date {
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
    sql: CAST(${TABLE}."APPLICATION_REVIEW_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: application_review_time {
    type: number
    sql: ${TABLE}."APPLICATION_REVIEW_TIME" ;;
  }

  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension_group: completed_date {
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
    sql: CAST(${TABLE}."COMPLETED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: completed_time {
    type: number
    sql: ${TABLE}."COMPLETED_TIME" ;;
  }

  dimension_group: date_applied {
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
    sql: CAST(${TABLE}."DATE_APPLIED" AS TIMESTAMP_NTZ) ;;
  }

  dimension_group: disc_date {
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
    sql: CAST(${TABLE}."DISC_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: disc_time {
    type: number
    sql: ${TABLE}."DISC_TIME" ;;
  }

  dimension_group: face_to_face_date {
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
    sql: CAST(${TABLE}."FACE_TO_FACE_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: face_to_face_time {
    type: number
    sql: ${TABLE}."FACE_TO_FACE_TIME" ;;
  }

  dimension_group: hr_phone_screen_date {
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
    sql: CAST(${TABLE}."HR_PHONE_SCREEN_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: hr_phone_screen_time {
    type: number
    sql: ${TABLE}."HR_PHONE_SCREEN_TIME" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension_group: manager_phone_screen_date {
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
    sql: CAST(${TABLE}."MANAGER_PHONE_SCREEN_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: manager_phone_screen_time {
    type: number
    sql: ${TABLE}."MANAGER_PHONE_SCREEN_TIME" ;;
  }

  dimension_group: offer_date {
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
    sql: CAST(${TABLE}."OFFER_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: offer_time {
    type: number
    sql: ${TABLE}."OFFER_TIME" ;;
  }

  measure: count {
    type: count
    drill_fields: [job_name]
  }

  measure: application_review_time_average {
    type: average
    sql:  ${application_review_time} ;;
    drill_fields: [application_info_view.candidate_name, application_info_view.job_name, application_info_view.application_stage, application_review_time]
  }

  measure: DISC_time_average {
    type: average
    sql: ${disc_time} ;;
    drill_fields: [application_info_view.candidate_name, application_info_view.job_name, application_info_view.application_stage, disc_time]
  }


  measure: hr_phone_screen_time_average {
    type: average
    sql:  ${hr_phone_screen_time};;
    drill_fields: [application_info_view.candidate_name, application_info_view.job_name, application_info_view.application_stage, hr_phone_screen_time]
  }

  measure: manager_phone_screen_average {
    type: average
    sql:  ${manager_phone_screen_time} ;;
    drill_fields: [application_info_view.candidate_name, application_info_view.job_name, application_info_view.application_stage, manager_phone_screen_time]
  }

  measure: face_to_face_time_average {
    type: average
    sql:  ${face_to_face_time} ;;
    drill_fields: [application_info_view.candidate_name, application_info_view.job_name, application_info_view.application_stage, face_to_face_time]
  }

  measure: offer_time_average {
    type: average
    sql:  ${offer_time} ;;
    drill_fields: [application_info_view.candidate_name, application_info_view.job_name, application_info_view.application_stage, offer_time]
  }



}
