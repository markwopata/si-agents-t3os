view: application_info_view {
    derived_table: {
      sql:SELECT * from analytics.payroll.EE_COMPANY_DIRECTORY_12_MONTH cd left join
            (SELECT * from analytics.greenhouse.job_profiles) jp on
           cd.EMPLOYEE_TITLE=jp.JOB_TITLE
            ;;
    }

  dimension: application_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: application_source {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE" ;;
  }

  dimension: application_stage {
    type: string
    sql: ${TABLE}."APPLICATION_STAGE" ;;
  }

  dimension: application_status {
    type: string
    sql: ${TABLE}."APPLICATION_STATUS" ;;
  }

  dimension: beh_interview_rec {
    type: string
    sql: ${TABLE}."BEH_INTERVIEW_REC" ;;
  }

  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: candidate_name {
    type: string
    sql: ${TABLE}."CANDIDATE_NAME" ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_name {
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }

  dimension_group: last_activity {
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
    sql: CAST(${TABLE}."LAST_ACTIVITY_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: link_to_resume {
    type: string
    sql: ${TABLE}."LINK_TO_RESUME" ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}."LOCATION" ;;
  }

  dimension: rec_submitted_by {
    type: string
    sql: ${TABLE}."REC_SUBMITTED_BY" ;;
  }

  dimension: rec_submitted_by_user_id {
    type: number
    sql: ${TABLE}."REC_SUBMITTED_BY_USER_ID" ;;
  }

  dimension_group: rejection {
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
    sql: CAST(${TABLE}."REJECTION_DATE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rejection_reason {
    type: string
    sql: ${TABLE}."REJECTION_REASON" ;;
  }

  dimension: rejection_type {
    type: string
    sql: ${TABLE}."REJECTION_TYPE" ;;
  }

  dimension_group: submitted {
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
    sql: CAST(${TABLE}."SUBMITTED_DATE" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [job_name, candidate_name]
  }
}
