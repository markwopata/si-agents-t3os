view: application_info_view {
  derived_table: {
    sql: SELECT * FROM ANALYTICS.GREENHOUSE.APPLICATION_INFO_VIEW ai
      LEFT JOIN (SELECT ID, CUSTOM_DISC_CODE FROM ANALYTICS.GREENHOUSE.CANDIDATE) ca on
      ai.CANDIDATE_ID=ca.ID;;
  }

  dimension: application_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: app_greenhouse_link{
    type: string
    sql: CONCAT('https://app.greenhouse.io/people/',${candidate_id},'?application_id=',${application_id});;
    html: <font color="blue "><u><a href="{{ value }}" target="_blank" title="Link to Application">Greenhouse Link</a> ;;

  }
  dimension: application_source {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE" ;;
  }

  dimension: application_stage {
    type: string
    sql: ${TABLE}."APPLICATION_STAGE" ;;
  }

  dimension: application_stage_listed {
    type: string
    sql: CASE
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Application Review' THEN 'A. Application Review'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Recruiter Review' THEN 'B. Recruiter Review'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Hiring Manager Review' THEN 'C. Hiring Manager Review'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Recruiter Phone Screen' THEN 'D. Recruiter Phone Screen'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Business Phone Screen' THEN 'E. Business Phone Screen'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'DISC' THEN 'F. DISC'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Sent to Hiring Manager' THEN 'G. Sent to Hiring Manager'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Face-to-face Interview(s)' THEN 'H. Face-to-face Interview(s)'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Offer Pending Approvals' THEN 'I. Offer Pending Approvals'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Verbal Offer' THEN 'J. Verbal Offer'
          WHEN ${TABLE}."APPLICATION_STAGE" = 'Offer Letter Sent' THEN 'K. Offer Letter Sent'
          END ;;
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

  dimension: disc_code {
    type: string
    sql: ${TABLE}."CUSTOM_DISC_CODE" ;;
  }

  dimension: disc_link {
    type: string
    sql: CASE WHEN ${disc_code} IS NOT NULL THEN CONCAT('https://www.discoveryreport.com/v/', ${disc_code})
      ELSE 'No DISC' END;;
    html: <font color="blue "><u><a href="{{ value }}" target="_blank" title="Link to DISC"> {{rendered_value}}</a> ;;

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
    html: <font color="blue "><u><a href="{{ value }}" target="_blank" title="Link to Resume">Resume Link</a> ;;

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

  dimension: funnel {
    type: string
    sql: CASE
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Application Review' THEN 'Application Review'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Recruiter Review' THEN 'Application Review'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Hiring Manager Review' THEN 'Application Review'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Recruiter Phone Screen' THEN 'Recruiter Phone Screen'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Business Phone Screen' THEN 'Business Phone Screen'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'DISC' THEN 'DISC'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Sent to Hiring Manager' THEN 'Sent to Hiring Manager'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Face to Face' THEN 'Face to Face Interview(s)'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Offer Pending Approvals' THEN 'Offer Pending Approvals'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Verbal Offer' THEN 'Offer Sent'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Offer Letter Sent' THEN 'Offer Sent'
      WHEN ${TABLE}."APPLICATION_STAGE" = 'Hired' THEN ''
                ELSE '' END ;;
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
    drill_fields: [job_name, candidate_name,app_greenhouse_link,disc_link, disc_code]
  }

  measure: candidate_count {
    type: count
    drill_fields: [candidate_name,job_name,application_status]
  }


  measure: unique_applicant_count {
    type: count_distinct
    sql: ${application_id} ;;
    drill_fields: [candidate_name,job_name,application_stage, app_greenhouse_link, link_to_resume, disc_link, disc_code, submitted_date]
  }

  measure: unique_candidate_count {
    type: count_distinct
    sql: ${candidate_id} ;;
    drill_fields: [starts_at*]
  }

  set: starts_at {
    fields: [candidate_name,
      job_name,
      application_stage,
      app_greenhouse_link,
      link_to_resume,
      disc_link,
      disc_code,
      submitted_date,
      offer.starts_date]
  }

  measure: quality_applicant {
    sql: CASE WHEN ${TABLE}."BEH_INTERVIEW_REC" ='yes' OR  ${TABLE}."BEH_INTERVIEW_REC" ='strong_yes' THEN 1
      ELSE 0 END;;
    type:  sum
  }

  measure: unique_referral_count {
    type: count_distinct
    sql: ${application_id} ;;
    drill_fields: [candidate_name,job_name,application_stage, app_greenhouse_link, link_to_resume, disc_link, submitted_date]
    filters: [application_source: "Employee Referral"]
  }

  measure: active_passive_count {
    type: count_distinct
    sql: ${application_id} ;;
    drill_fields: [candidate_name,job_name,application_stage, app_greenhouse_link, link_to_resume, disc_link, submitted_date]
    filters: [application_source: "-Employee Referral"]
  }

}
