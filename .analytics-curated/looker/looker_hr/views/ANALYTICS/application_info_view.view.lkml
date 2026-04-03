view: application_info_view {
  sql_table_name: "GREENHOUSE"."APPLICATION_INFO_VIEW"
    ;;

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
    primary_key: yes
  }

  dimension: application_stage {
    type: string
    sql: ${TABLE}."APPLICATION_STAGE" ;;
  }

  dimension: application_status {
    type: string
    sql: ${TABLE}."APPLICATION_STATUS" ;;
  }

  dimension: application_source {
    type: string
    sql: ${TABLE}."APPLICATION_SOURCE" ;;
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

  dimension: recent_week {
    type: yesno
    sql: ${submitted_date} <previous_day(current_date(),'Monday') ;;
  }

  #dimension_group: submitted {
  #  type: time
  #  timeframes: [
  #    raw,
  #    time,
  #    date,
  #    week,
  #    month,
  #    quarter,
  #    year
  #  ]
  #  sql: CAST(${TABLE}."SUBMITTED_DATE" AS TIMESTAMP_NTZ) ;;
  #}

  dimension_group: submitted {
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
    sql: ${TABLE}."SUBMITTED_DATE"::DATE ;;
  }

  dimension: week_submitted {
    type: number
    sql: Date_part(week,${TABLE}."submitted_date") as week_submitted ;;
  }

  dimension: year_submitted {
    type: number
    sql: Date_part(year,${TABLE}."submitted_date") as year_submitted ;;
  }

  dimension: DDI {
    type:  number
    sql: CASE WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'strong_yes' THEN 4
              WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'yes' THEN 3
              WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'no_decision' THEN 2
              WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'no' THEN 1
              WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'definitely_not' THEN 0
              END ;;
  }

  measure: app_count {
    type: count
    drill_fields: [submitted_date,year_submitted,week_submitted]
  }

  measure: candidate_count {
    type: count
    drill_fields: [candidate_name,job_name,application_status]
  }

  measure: unique_candidate_count {
    type: count_distinct
    sql: ${candidate_name} ;;
    drill_fields: [candidate_name,job_name,application_status]
  }


  #measure: app_count_hires {
  #  type: count
  #  drill_fields: [submitted_date,year_submitted,week_submitted]
  #  filters: [: "EquipmentShare.com"]

  #}


  measure: DDI_count {
    type: count
    drill_fields: [DDI]
  }

  measure: average_DDI {
    type: average
    sql: CASE WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'strong_yes' THEN 4
              WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'yes' THEN 3
              WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'no_decision' THEN 2
              WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'no' THEN 1
              WHEN ${TABLE}."BEH_INTERVIEW_REC" = 'definitely_not' THEN 0
              END ;;
  }

  measure: source_count {
    type: count
    drill_fields: [application_source]
  }

  measure: linkedin {
    type: count
    filters: [application_source: "LinkedIn"]
  }

  measure: indeed {
    type: count
    filters: [application_source: "Indeed"]
  }

  measure: referral {
    type: count
    filters: [application_source: "Employee Referral"]
  }

  measure: glassdoor {
    type: count
    filters: [application_source: "Glassdoor"]
  }

  measure: esdotcom {
    type: count
    filters: [application_source: "EquipmentShare.com"]
  }

  measure: other_not_online {
    type: count_distinct
    sql:
    CASE WHEN ${TABLE}."APPLICATION_SOURCE" in ('Walk-In','Career Fair','Radio/TV Advertisement')
    THEN ${TABLE}."APPLICATION_ID"
    ELSE NULL
    END ;;
  }

  measure: other_online {
    type: count_distinct
    sql:
       CASE WHEN ${TABLE}."APPLICATION_SOURCE" not in ('LinkedIn','Indeed','Employee Referral','Glassdoor','EquipmentShare.com','Walk-In','Career Fair','Radio/TV Advertisement','Other')
       THEN ${TABLE}."APPLICATION_ID"
        ELSE NULL
       END ;;
  }

  measure: last_app_date {
    type: date
    sql: MAX(${submitted_date}) ;;
    convert_tz: no
  }

  measure: quality_applicant {
    sql: CASE WHEN ${TABLE}."BEH_INTERVIEW_REC" ='yes' OR  ${TABLE}."BEH_INTERVIEW_REC" ='strong_yes' THEN 1
      ELSE 0 END;;
    type:  sum
  }



}
