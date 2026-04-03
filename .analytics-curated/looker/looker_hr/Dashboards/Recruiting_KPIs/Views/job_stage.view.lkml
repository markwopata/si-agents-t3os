view: job_stage {
  sql_table_name: "GREENHOUSE"."JOB_STAGE" ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
  }
  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }
  dimension_group: _fivetran_synced {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_FIVETRAN_SYNCED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: active {
    type: yesno
    sql: ${TABLE}."ACTIVE" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: stage_name_listed {
    type: string
    sql: CASE
          WHEN ${TABLE}."NAME" = 'Application Review' THEN 'A. Application Review'
          WHEN ${TABLE}."NAME" = 'Recruiter Review' THEN 'B. Recruiter Review'
          WHEN ${TABLE}."NAME" = 'Hiring Manager Review' THEN 'C. Hiring Manager Review'
          WHEN ${TABLE}."NAME" = 'Recruiter Phone Screen' THEN 'D. Recruiter Phone Screen'
          WHEN ${TABLE}."NAME" = 'Business Phone Screen' THEN 'E. Business Phone Screen'
          WHEN ${TABLE}."NAME" = 'DISC' THEN 'F. DISC'
          WHEN ${TABLE}."NAME" = 'Sent to Hiring Manager' THEN 'G. Sent to Hiring Manager'
          WHEN ${TABLE}."NAME" = 'Face-to-face Interview(s)' THEN 'H. Face-to-face Interview(s)'
          WHEN ${TABLE}."NAME" = 'Offer Pending Approvals' THEN 'I. Offer Pending Approvals'
          WHEN ${TABLE}."NAME" = 'Verbal Offer' THEN 'J. Verbal Offer'
          WHEN ${TABLE}."NAME" = 'Offer Letter Sent' THEN 'K. Offer Letter Sent'
          END ;;
  }
  dimension: priority {
    type: number
    sql: ${TABLE}."PRIORITY" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
    drill_fields: [id, name]
  }
}
