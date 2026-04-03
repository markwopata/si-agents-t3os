view: voc_responses_retool {
  derived_table: {
    sql: select
                          *
                          from
                          analytics.bi_ops.voc_retool_responses
                            where deleted = false
                            and hidden = false
                            and reviewer is not null
                            and reviewed_status != 'Not Started'
                            order by pk_id desc ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: pk_id {
    type: number
    sql: ${TABLE}."PK_ID" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: submitted_by {
    type: string
    sql: ${TABLE}."SUBMITTED_BY" ;;
  }

  dimension: voc_type {
    type: string
    sql: ${TABLE}."VOC_TYPE" ;;
  }

  dimension: customer_id {
    type: number
    sql: ${TABLE}."CUSTOMER_ID" ;;
  }

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_email {
    type: string
    sql: ${TABLE}."USER_EMAIL" ;;
  }

  dimension: employee_relay {
    type: string
    sql: ${TABLE}."EMPLOYEE_RELAY" ;;
  }

  dimension: non_customer_desc {
    type: string
    sql: ${TABLE}."NON_CUSTOMER_DESC" ;;
  }

  dimension: date_of_conversation {
    type: string
    sql: ${TABLE}."DATE_OF_CONVERSATION" ;;
  }

  dimension: form_of_communication {
    type: string
    sql: ${TABLE}."FORM_OF_COMMUNICATION" ;;
  }

  dimension: feedback_primary_topic {
    type: string
    sql: ${TABLE}."FEEDBACK_PRIMARY_TOPIC" ;;
  }

  dimension: contact_phone_number {
    type: string
    sql: ${TABLE}."CONTACT_PHONE_NUMBER" ;;
  }

  dimension: front_message_id {
    type: string
    sql: ${TABLE}."FRONT_MESSAGE_ID" ;;
  }

  dimension: intercom_conversation_id {
    type: string
    sql: ${TABLE}."INTERCOM_CONVERSATION_ID" ;;
  }

  dimension: conversation_tone {
    type: string
    sql: ${TABLE}."CONVERSATION_TONE" ;;
  }

  dimension: escalation_behavior {
    type: string
    sql: ${TABLE}."ESCALATION_BEHAVIOR" ;;
  }

  dimension: quotes {
    type: string
    sql: ${TABLE}."QUOTES" ;;
  }

  dimension: summary {
    type: string
    sql: ${TABLE}."SUMMARY" ;;
  }

  dimension: who_needs_to_address {
    type: string
    sql: ${TABLE}."WHO_NEEDS_TO_ADDRESS" ;;
  }

  dimension: tam_needed {
    type: string
    sql: ${TABLE}."TAM_NEEDED" ;;
  }

  dimension: person_needed_to_address {
    type: string
    sql: ${TABLE}."PERSON_NEEDED_TO_ADDRESS" ;;
  }

  dimension: branch_needed_to_address {
    type: string
    sql: ${TABLE}."BRANCH_NEEDED_TO_ADDRESS" ;;
  }

  dimension: reviewed_status {
    type: string
    sql: ${TABLE}."REVIEWED_STATUS" ;;
  }

  dimension: reviewer {
    type: string
    sql: ${TABLE}."REVIEWER" ;;
  }

  dimension: reviewer_notes {
    type: string
    sql: ${TABLE}."REVIEWER_NOTES" ;;
  }

  dimension_group: first_reviewed_timestamp {
    type: time
    sql: ${TABLE}."FIRST_REVIEWED_TIMESTAMP" ;;
  }

  dimension_group: time_to_first_review {
    type: time
    sql: ${TABLE}."TIME_TO_FIRST_REVIEW" ;;
  }

  dimension: deprecated_suggestion {
    type: string
    sql: ${TABLE}."DEPRECATED_SUGGESTION" ;;
  }

  dimension: depricated_conversation_link {
    type: string
    sql: ${TABLE}."DEPRICATED_CONVERSATION_LINK" ;;
  }

  dimension: hidden {
    type: yesno
    sql: ${TABLE}."HIDDEN" ;;
  }

  dimension: deleted {
    type: yesno
    sql: ${TABLE}."DELETED" ;;
  }

  dimension: pre_retool_flag {
    type: yesno
    sql: ${TABLE}."PRE_RETOOL_FLAG" ;;
  }

  set: detail {
    fields: [
      pk_id,
      date_created_time,
      submitted_by,
      voc_type,
      customer_id,
      customer_name,
      user_id,
      user_email,
      employee_relay,
      non_customer_desc,
      date_of_conversation,
      form_of_communication,
      feedback_primary_topic,
      contact_phone_number,
      front_message_id,
      intercom_conversation_id,
      conversation_tone,
      escalation_behavior,
      quotes,
      summary,
      who_needs_to_address,
      tam_needed,
      person_needed_to_address,
      branch_needed_to_address,
      reviewed_status,
      reviewer,
      reviewer_notes,
      first_reviewed_timestamp_time,
      time_to_first_review_time,
      deprecated_suggestion,
      depricated_conversation_link,
      hidden,
      deleted,
      pre_retool_flag
    ]
  }
}
