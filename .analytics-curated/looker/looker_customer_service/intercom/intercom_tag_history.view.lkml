
view: intercom_tag_history {
  derived_table: {
    sql: select distinct
    t.name as tag_name,
      iff(hsc.property_t_3_subscriber_status LIKE '%VIP%', TRUE, FALSE) as vip_customer,
      ch.*
      from
       ANALYTICS.INTERCOM.CONVERSATION_HISTORY ch
        left join ANALYTICS.INTERCOM.CONVERSATION_TAG_HISTORY cth on (ch.id = cth.conversation_id)
        left join ANALYTICS.INTERCOM.TAG t on (t.id = cth.tag_id)
        LEFT JOIN (
                      SELECT id, email
                      FROM ANALYTICS.INTERCOM.CONTACT_HISTORY
                      QUALIFY ROW_NUMBER() OVER (PARTITION BY id ORDER BY updated_at DESC) = 1
                  ) ct ON ct.id = ch.source_author_id
        LEFT JOIN es_warehouse.public.users u ON u.email_address = ct.email
        LEFT JOIN analytics.hubspot_customer_success.company hsc on u.company_id = try_cast(property_es_admin_id as int)
;;
  }

  dimension: conversation_link {
    label: "Link to Conversation"
    type: string
    sql: ${TABLE}."ID";;
    html: <font color="#0063f3"><u><a href="https://app.intercom.com/a/inbox/cc3wvy5y/inbox/search/conversation/{{ id._filterable_value }}?filters=&query={{ id._filterable_value }}&view=List" target="_blank">Click For Conversation</a></font></u>;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  measure: count_distinct_coversation_id {
    label: "Total Conversations"
    type: count_distinct
    sql: ${TABLE}."ID" ;;
  }

  dimension: tag_name {
    type: string
    sql: ${TABLE}."TAG_NAME" ;;
  }

  dimension: vip_customer {
    type: yesno
    sql: ${TABLE}."VIP_CUSTOMER" ;;
  }

  dimension: id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ID" ;;
  }

  dimension_group: updated_at {
    type: time
    sql: ${TABLE}."UPDATED_AT" ;;
  }

  dimension_group: created_at {
    group_label: "Coversation Date"
    label: "Conversation"
    type: time
    sql: ${TABLE}."CREATED_AT" ;;
    html: {{ rendered_value | date: "%b %d, %Y" }} ;;
  }

  dimension: open {
    type: yesno
    sql: ${TABLE}."OPEN" ;;
  }

  dimension: state {
    type: string
    sql: ${TABLE}."STATE" ;;
  }

  dimension: read {
    type: yesno
    sql: ${TABLE}."READ" ;;
  }

  dimension_group: waiting_since {
    type: time
    sql: ${TABLE}."WAITING_SINCE" ;;
  }

  dimension_group: snoozed_until {
    type: time
    sql: ${TABLE}."SNOOZED_UNTIL" ;;
  }

  dimension: priority {
    type: string
    sql: ${TABLE}."PRIORITY" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: source_type {
    type: string
    sql: ${TABLE}."SOURCE_TYPE" ;;
  }

  dimension: source_id {
    type: string
    sql: ${TABLE}."SOURCE_ID" ;;
  }

  dimension: source_delivered_as {
    type: string
    sql: ${TABLE}."SOURCE_DELIVERED_AS" ;;
  }

  dimension: source_subject {
    type: string
    sql: ${TABLE}."SOURCE_SUBJECT" ;;
  }

  dimension: source_body {
    type: string
    sql: ${TABLE}."SOURCE_BODY" ;;
  }

  dimension: source_url {
    type: string
    sql: ${TABLE}."SOURCE_URL" ;;
  }

  dimension: source_author_type {
    type: string
    sql: ${TABLE}."SOURCE_AUTHOR_TYPE" ;;
  }

  dimension: source_author_id {
    type: string
    sql: ${TABLE}."SOURCE_AUTHOR_ID" ;;
  }

  dimension: team_assignee_id {
    type: string
    sql: ${TABLE}."TEAM_ASSIGNEE_ID" ;;
  }

  dimension: first_contact_reply_type {
    type: string
    sql: ${TABLE}."FIRST_CONTACT_REPLY_TYPE" ;;
  }

  dimension: first_contact_reply_url {
    type: string
    sql: ${TABLE}."FIRST_CONTACT_REPLY_URL" ;;
  }

  dimension_group: first_contact_reply_created_at {
    type: time
    sql: ${TABLE}."FIRST_CONTACT_REPLY_CREATED_AT" ;;
  }

  dimension: sla_name {
    type: string
    sql: ${TABLE}."SLA_NAME" ;;
  }

  dimension: sla_status {
    type: string
    sql: ${TABLE}."SLA_STATUS" ;;
  }

  dimension: conversation_rating_remark {
    type: string
    sql: ${TABLE}."CONVERSATION_RATING_REMARK" ;;
  }

  dimension_group: conversation_rating_created_at {
    type: time
    sql: ${TABLE}."CONVERSATION_RATING_CREATED_AT" ;;
  }

  dimension: conversation_rating_teammate_id {
    type: string
    sql: ${TABLE}."CONVERSATION_RATING_TEAMMATE_ID" ;;
  }

  dimension: conversation_rating_value {
    type: number
    sql: ${TABLE}."CONVERSATION_RATING_VALUE" ;;
  }

  dimension: statistics_time_to_assignment {
    type: number
    sql: ${TABLE}."STATISTICS_TIME_TO_ASSIGNMENT" ;;
  }

  dimension: statistics_time_to_admin_reply {
    type: number
    sql: ${TABLE}."STATISTICS_TIME_TO_ADMIN_REPLY" ;;
  }

  dimension: statistics_time_to_first_close {
    type: number
    sql: ${TABLE}."STATISTICS_TIME_TO_FIRST_CLOSE" ;;
  }

  dimension: statistics_time_to_last_close {
    type: number
    sql: ${TABLE}."STATISTICS_TIME_TO_LAST_CLOSE" ;;
  }

  dimension: statistics_median_time_to_reply {
    type: number
    sql: ${TABLE}."STATISTICS_MEDIAN_TIME_TO_REPLY" ;;
  }

  dimension_group: statistics_first_contact_reply_at {
    type: time
    sql: ${TABLE}."STATISTICS_FIRST_CONTACT_REPLY_AT" ;;
  }

  dimension_group: statistics_first_assignment_at {
    type: time
    sql: ${TABLE}."STATISTICS_FIRST_ASSIGNMENT_AT" ;;
  }

  dimension_group: statistics_first_admin_reply_at {
    type: time
    sql: ${TABLE}."STATISTICS_FIRST_ADMIN_REPLY_AT" ;;
  }

  dimension_group: statistics_first_close_at {
    type: time
    sql: ${TABLE}."STATISTICS_FIRST_CLOSE_AT" ;;
  }

  dimension_group: statistics_last_assignment_at {
    type: time
    sql: ${TABLE}."STATISTICS_LAST_ASSIGNMENT_AT" ;;
  }

  dimension_group: statistics_last_assignment_admin_reply_at {
    type: time
    sql: ${TABLE}."STATISTICS_LAST_ASSIGNMENT_ADMIN_REPLY_AT" ;;
  }

  dimension_group: statistics_last_contact_reply_at {
    type: time
    sql: ${TABLE}."STATISTICS_LAST_CONTACT_REPLY_AT" ;;
  }

  dimension_group: statistics_last_admin_reply_at {
    type: time
    sql: ${TABLE}."STATISTICS_LAST_ADMIN_REPLY_AT" ;;
  }

  dimension_group: statistics_last_close_at {
    type: time
    sql: ${TABLE}."STATISTICS_LAST_CLOSE_AT" ;;
  }

  dimension: statistics_last_closed_by_id {
    type: string
    sql: ${TABLE}."STATISTICS_LAST_CLOSED_BY_ID" ;;
  }

  dimension: statistics_count_reopens {
    type: number
    sql: ${TABLE}."STATISTICS_COUNT_REOPENS" ;;
  }

  dimension: statistics_count_assignments {
    type: number
    sql: ${TABLE}."STATISTICS_COUNT_ASSIGNMENTS" ;;
  }

  dimension: statistics_count_conversation_parts {
    type: number
    sql: ${TABLE}."STATISTICS_COUNT_CONVERSATION_PARTS" ;;
  }

  dimension: _fivetran_deleted {
    type: yesno
    sql: ${TABLE}."_FIVETRAN_DELETED" ;;
  }

  dimension: assignee_id {
    type: string
    sql: ${TABLE}."ASSIGNEE_ID" ;;
  }

  dimension_group: _fivetran_synced {
    type: time
    sql: ${TABLE}."_FIVETRAN_SYNCED" ;;
  }

  dimension: custom_type {
    type: string
    sql: ${TABLE}."CUSTOM_TYPE" ;;
  }

  dimension: custom_language {
    type: string
    sql: ${TABLE}."CUSTOM_LANGUAGE" ;;
  }

  dimension: custom_cx_score_explanation {
    type: string
    sql: ${TABLE}."CUSTOM_CX_SCORE_EXPLANATION" ;;
  }

  dimension: custom_cx_score_rating {
    type: number
    sql: ${TABLE}."CUSTOM_CX_SCORE_RATING" ;;
  }

  set: detail {
    fields: [
        tag_name,
  id,
  updated_at_time,
  created_at_time,
  open,
  state,
  read,
  waiting_since_time,
  snoozed_until_time,
  priority,
  title,
  source_type,
  source_id,
  source_delivered_as,
  source_subject,
  source_body,
  source_url,
  source_author_type,
  source_author_id,
  team_assignee_id,
  first_contact_reply_type,
  first_contact_reply_url,
  first_contact_reply_created_at_time,
  sla_name,
  sla_status,
  conversation_rating_remark,
  conversation_rating_created_at_time,
  conversation_rating_teammate_id,
  conversation_rating_value,
  statistics_time_to_assignment,
  statistics_time_to_admin_reply,
  statistics_time_to_first_close,
  statistics_time_to_last_close,
  statistics_median_time_to_reply,
  statistics_first_contact_reply_at_time,
  statistics_first_assignment_at_time,
  statistics_first_admin_reply_at_time,
  statistics_first_close_at_time,
  statistics_last_assignment_at_time,
  statistics_last_assignment_admin_reply_at_time,
  statistics_last_contact_reply_at_time,
  statistics_last_admin_reply_at_time,
  statistics_last_close_at_time,
  statistics_last_closed_by_id,
  statistics_count_reopens,
  statistics_count_assignments,
  statistics_count_conversation_parts,
  _fivetran_deleted,
  assignee_id,
  _fivetran_synced_time,
  custom_type,
  custom_language
    ]
  }

  measure: chat_volume {
    group_label: "Intercom"
    type: count_distinct
    sql: ${id} ;;
  }

  measure: avg_first_response {
    group_label: "Intercom"
    type: number
    sql: avg(${statistics_time_to_admin_reply}) ;;
    value_format_name: decimal_2
  }

  measure: avg_first_close {
    group_label: "Intercom"
    type: number
    sql: avg(${statistics_time_to_first_close}) ;;
    value_format_name: decimal_2
  }

  measure: avg_last_close {
    group_label: "Intercom"
    type: number
    sql: avg(${statistics_time_to_last_close}) ;;
    value_format_name: decimal_2
  }

  measure: CSAT {
    group_label: "Intercom"
    description: "Customer Satisfaction Score"
    type: number
    sql: avg(${custom_cx_score_rating}) ;;
    value_format_name: decimal_2
  }
}
