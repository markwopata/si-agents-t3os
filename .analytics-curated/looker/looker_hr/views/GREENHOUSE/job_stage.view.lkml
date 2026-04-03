view: job_stage {
  sql_table_name: "GREENHOUSE"."JOB_STAGE"
    ;;
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

  dimension_group: created {
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
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: job_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension: job_stage {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [id, job_stage, job.job, job.id, interview.count]
  }

  dimension: application_pending {
    type: yesno
    sql: ${job_stage} = 'Application Review' ;;
  }

  dimension: disc_sent {
    type: yesno
    sql: ${job_stage} = 'DISC' ;;
  }

  dimension: face_to_face {
    type: yesno
    sql: ${job_stage} = 'Face to Face' ;;
  }

  dimension: first_phone_interview {
    type: yesno
    sql: ${job_stage} = 'Phone Interview' ;;
  }

  dimension: second_phone_interview {
    type: yesno
    sql: ${job_stage} = 'Phone Interview 2' ;;
  }

  dimension: offer {
    type: yesno
    sql: ${job_stage} = 'Offer' ;;
  }

  measure: application_pending_count {
    type: count
    filters: [application_pending: "Yes"]
    drill_fields: [detail*]
  }

  measure: in_person_interview_count {
    type: count
    filters: [face_to_face: "Yes"]
    drill_fields: [detail*]
  }

  measure: first_phone_interview_pending {
    type: count
    filters: [first_phone_interview: "Yes",
      scorecard.phone_interview_completed: "No"]
    drill_fields: [detail*]
  }

  measure: first_phone_interview_completed {
    type: count
    filters: [first_phone_interview: "Yes",
      scorecard.phone_interview_completed: "Yes"]
    drill_fields: [detail*]
  }

  measure: second_phone_interview_pending {
    type: count
    filters: [second_phone_interview: "Yes",
      scorecard.phone_interview_completed: "No"]
    drill_fields: [detail*]
  }

  measure: second_phone_interview_completed {
    type: count
    filters: [second_phone_interview: "Yes",
      scorecard.phone_interview_completed: "Yes"]
    drill_fields: [detail*]
  }

  measure: offer_sent {
    type: count
    filters: [offer: "Yes"]
    drill_fields: [detail*]
  }

  set: detail {
    fields: [
      job.job,
      hr_recruiting_pipeline.full_name,
      email_address.email_address,
      application.applied_date,
      source.source,
      hr_recruiting_pipeline.link_to_application,
      job_stage.job_stage
    ]
  }
}
