view: application {
  sql_table_name: "GREENHOUSE"."APPLICATION"
    ;;

  dimension: application_id {
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

  dimension_group: applied {
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
    sql: CAST(${TABLE}."APPLIED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: candidate_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: credited_to_user_id {
    type: number
    sql: ${TABLE}."CREDITED_TO_USER_ID" ;;
  }

  dimension: current_stage_id {
    type: number
    sql: ${TABLE}."CURRENT_STAGE_ID" ;;
  }

  dimension: is_deleted {
    type: yesno
    sql: ${TABLE}."IS_DELETED" ;;
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
    sql: CAST(${TABLE}."LAST_ACTIVITY_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: location_address {
    type: string
    sql: ${TABLE}."LOCATION_ADDRESS" ;;
  }

  dimension: prospect {
    type: yesno
    sql: ${TABLE}."PROSPECT" ;;
  }

  dimension: prospect_owner_id {
    type: number
    sql: ${TABLE}."PROSPECT_OWNER_ID" ;;
  }

  dimension: prospect_pool_id {
    type: number
    sql: ${TABLE}."PROSPECT_POOL_ID" ;;
  }

  dimension: prospect_stage_id {
    type: number
    sql: ${TABLE}."PROSPECT_STAGE_ID" ;;
  }

  dimension_group: rejected {
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
    sql: CAST(${TABLE}."REJECTED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rejected_reason_id {
    type: number
    sql: ${TABLE}."REJECTED_REASON_ID" ;;
  }

  dimension: rejected_app {
    type: yesno
    sql: ${status} = 'rejected';;
  }

  measure: rejected_count {
    type: count
    filters: [rejected_app: "Yes",
      job_is_closed: "No"]
    drill_fields: [      job.job,
      hr_recruiting_pipeline.full_name,
      email_address.email_address,
      applied_date,
      source.source,
      hr_recruiting_pipeline.link_to_application,
      job_stage.job_stage,
      rejection_reason.rejection_reason_type_name,
      disc_master.link_to_disc_pdf]
  }

  dimension: source_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SOURCE_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }


  dimension: application_pending {
    type: yesno
    sql: trim(${job_stage.job_stage}) = 'Application Review'
    OR trim(${job_stage.job_stage}) = 'Reference Check'
    OR ${job_stage.job_stage} is null
    OR trim(${job_stage.job_stage}) = 'Reviewed';;
  }

  dimension: disc_sent {
    type: yesno
    sql: upper(trim(${job_stage.job_stage})) in ('DISC','SEND DISC','DISC ASSESSMENT','Disc') ;;
  }

  dimension: face_to_face {
    type: yesno
    sql: trim(${job_stage.job_stage}) = 'Face to Face' ;;
  }

  dimension: first_phone_interview {
    type: yesno
    sql: (trim(lower(${job_stage.job_stage})) = 'phone interview' or trim(lower(${job_stage.job_stage})) = 'phone screening')  AND ${scorecard.scorecard_id} is NOT null ;;
  }

  dimension: second_phone_interview {
    type: yesno
    sql: trim(${job_stage.job_stage}) = 'Phone Interview 2';;
  }

  dimension: prelim_phone_interview_1 {
    type: yesno
    sql: trim(${job_stage.job_stage}) = 'Preliminary Phone Screen'
    OR ((trim(lower(${job_stage.job_stage})) = 'phone interview' or trim(lower(${job_stage.job_stage})) = 'phone screening') AND ${scorecard.scorecard_id} is null);;
  }

  dimension: prelim_phone_interview_2 {
    type: yesno
    ##sql: trim(${scorecard.interview}) = 'Hiring Manager Phone Screen' ;;
    sql: trim(${interview.name}) = 'Hiring Manager Phone Screen' ;;
  }

  dimension: offer_sent {
    type: yesno
    sql: trim(${job_stage.job_stage}) = 'Offer Sent'
    OR trim(${job_stage.job_stage}) = 'Offer'
    OR trim(${job_stage.job_stage}) = 'OFFER';;
  }

  dimension: offer_accepted {
    type: yesno
    sql: trim(${job_stage.job_stage}) = 'Offer Accepted' ;;
  }

  dimension: job_is_closed {
    type: yesno
    sql: TRIM(LOWER(${job.status})) = 'closed' ;;
  }

  measure: application_pending_count {
    type: count
    filters: [application_pending: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  measure: in_person_interview_count {
    type: count
    filters: [face_to_face: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  measure: first_phone_interview_pending {
    type: count
    #scorecard.phone_interview_completed: "No",
    #first_phone_interview: "Yes",
    filters: [prelim_phone_interview_1: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  measure: first_phone_interview_completed {
    type: count
    #scorecard.phone_interview_completed: "Yes",
    filters: [first_phone_interview: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  measure: second_phone_interview_pending {
    type: count
    filters: [prelim_phone_interview_2: "Yes",
      second_phone_interview: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  measure: second_phone_interview_completed {
    type: count
    filters: [second_phone_interview: "Yes",
      prelim_phone_interview_2: "No",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  measure: offer_sent_count {
    type: count
    filters: [offer_sent: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  measure: offer_accepted_count {
    type: count
    filters: [offer_accepted: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  dimension: completed_disc {
    type: yesno
    sql: ${disc_master.status} = 'completed' ;;
  }

  dimension: pending_disc {
    type: yesno
    sql: upper(TRIM(${job_stage.job_stage})) in ('DISC','SEND DISC','DISC ASSESSMENT')
        --and (${disc_master.status} = 'pending_completion' OR ${disc_master.status} is NULL)
        and (${disc_master.status} != 'completed' OR ${disc_master.status} is NULL)
        ;;
  }

  dimension: pending_disc_already_sent {
    type: yesno
    sql: upper(TRIM(${job_stage.job_stage})) in ('DISC','SEND DISC','DISC ASSESSMENT')
        --and ${disc_master.status} = 'pending_completion'
        and ${disc_master.status} != 'completed' and ${disc_master.status} is NOT NULL
        ;;
  }

  measure: completed_disc_count {
    type: count
    filters: [completed_disc: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*]
  }

  measure: pending_disc_count {
    type: count
    filters: [pending_disc: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*,disc_master.days_since_disc_sent]
  }

  measure: pending_disc_already_sent_count {
    type: count
    filters: [pending_disc_already_sent: "Yes",
      job_is_closed: "No"]
    drill_fields: [detail*,disc_master.days_since_disc_sent]
  }

  measure: count {
    type: count_distinct
    sql: ${application_id} ;;
    filters: [job_is_closed: "No"]
    drill_fields: [detail*]
  }

  dimension: status_formatted {
    type: string
    sql: TRIM(UPPER(${status})) ;;
    html:

    {% if value == 'REJECTED' %}

    <p style="color: black; background-color: rgb(179, 47, 55); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% elsif value == 'ACTIVE' %}

    <p style="color: black; background-color: rgb(80, 200, 120); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% else %}

    <p style="color: black; background-color: rgb(80, 200, 120); font-size:100%; text-align:center">{{ rendered_value }}</p>

    {% endif %}
    ;;
  }

  dimension: submit_manager_priorities_autofill {
    type: string
    html: <font color="blue "><u><a href ="https://docs.google.com/forms/d/e/1FAIpQLSfdljxEsRct1JkDPkqBg_E2tKBwLe2uyfIakhydn4qxCRFmbQ/viewform?usp=pp_url&entry.1536580630={{ application_id._value }}&entry.827249552={{ hr_recruiting_pipeline.candidate_id._value }}&entry.588797165={{ hr_recruiting_pipeline.full_name._value}}&entry.704771946=Yes"target="_blank">Submit Priority</a></font></u> ;;
    sql: ${application_id} ;;
  }

  # dimension: priority_app {
  #   type: string
  #   sql: CASE WHEN ${hr_manager_priorities.priority} in ('Yes','No') THEN ${hr_manager_priorities.priority} ELSE ${submit_manager_priorities_autofill} END ;;
  # }

  # dimension: priority_comments {
  #   type: string
  #   sql: CASE WHEN ${hr_manager_priorities.priority} in ('Yes','No') THEN ${hr_manager_priorities.comments} ELSE ${submit_manager_priorities_autofill} END ;;
  # }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      job.job,
      office.name,
      hr_recruiting_pipeline.candidate_name_link_to_candidate_dashboard,
      email_address.email_address,
      applied_date,
      source.source,
      hr_recruiting_pipeline.link_to_application,
      job_stage.job_stage,
      disc_master.link_to_disc_pdf,
      disc_master.disc_sent_date_date,
      disc_master.disc_completed_date_date,
      candidate_tag.sales_experience_tag,
      candidate_tag.rental_experience_tag,
      hr_manager_priorities.priority_app,
      hr_manager_priorities.priority_comments,
      submit_manager_priorities_autofill,
      greenhouse_ddi_scorecard.average_DDI_score
    ]
  }
}
