view: completed_contacts {
  derived_table: {
    sql:
SELECT cc.*,
       d.disposition_name  AS primary_disposition_name,
       d2.disposition_name AS secondary_disposition_name
  FROM analytics.cxone_api.completed_contacts cc
           LEFT OUTER JOIN analytics.cxone_api.dispositions d
                           ON cc.primary_disposition_id = d.disposition_id
           LEFT OUTER JOIN analytics.cxone_api.dispositions d2
                           ON cc.secondary_disposition_id = d2.disposition_id
;;
  }

  dimension: _es_batch_number {
    description: "Incrementing number representing an execution of the Jenkins job."
    type: number
    sql: ${TABLE}."_ES_BATCH_NUMBER" ;;
  }

  dimension: _es_date_created {
    description: "Date that the record was pulled from the API"
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."_ES_DATE_CREATED"::timestamp) ;;
  }

  dimension: _es_date_updated {
    description: "Date that the record was refreshed with data from the API.
    Doesn't necessarily mean that new data was added to it, just that it already existed in Snowflake and was pulled from the API again."
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."_ES_DATE_UPDATED"::timestamp) ;;
  }

  dimension: abandon_seconds {
    type: number
    sql: ${TABLE}."ABANDON_SECONDS" ;;
  }

  dimension: abandoned {
    type: yesno
    sql: ${TABLE}."ABANDONED" ;;
  }

  dimension: acw_seconds {
    type: number
    sql: ${TABLE}."ACW_SECONDS" ;;
  }

  dimension: agent_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."AGENT_ID" ;;
  }

  dimension: agent_seconds {
    type: number
    sql: ${TABLE}."AGENT_SECONDS" ;;
  }

  dimension: analytics_processed_date {
    type: string
    sql: convert_timezone('America/Chicago', ${TABLE}."ANALYTICS_PROCESSED_DATE"::timestamp) ;;
  }

  dimension: callback_time {
    type: number
    sql: ${TABLE}."CALLBACK_TIME" ;;
  }

  dimension: campaign_id {
    type: number
    sql: ${TABLE}."CAMPAIGN_ID" ;;
  }

  dimension: campaign_name {
    type: string
    sql: ${TABLE}."CAMPAIGN_NAME" ;;
  }

  dimension: conf_seconds {
    type: number
    sql: ${TABLE}."CONF_SECONDS" ;;
  }

  dimension: contact_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CONTACT_ID" ;;
  }

  # This time is America/Chicago. I think it would be set to the agent's timezone if "use agent timezone" is set on the agent record
  dimension_group: contact_start {
    type: time
    timeframes: [
      raw,
      time,
      date,
      day_of_week_index,
      week,
      month,
      quarter,
      year
    ]
    sql: CONVERT_TIMEZONE('America/Chicago', ${TABLE}."CONTACT_START"::timestamp) ;;
  }

  dimension: date_acw_warehoused {
    type: string
    sql: ${TABLE}."DATE_ACW_WAREHOUSED"::timestamp ;;
  }

  dimension: date_contact_warehoused {
    type: string
    sql: ${TABLE}."DATE_CONTACT_WAREHOUSED"::timestamp ;;
  }

  dimension: disposition_notes {
    type: string
    sql: ${TABLE}."DISPOSITION_NOTES" ;;
  }

  dimension: first_name {
    type: string
    sql: ${TABLE}."FIRST_NAME" ;;
  }

  dimension: from_addr {
    type: string
    sql: ${TABLE}."FROM_ADDR" ;;
  }

  dimension: hold_count {
    type: number
    sql: ${TABLE}."HOLD_COUNT" ;;
  }

  dimension: hold_seconds {
    type: number
    sql: ${TABLE}."HOLD_SECONDS" ;;
  }

  dimension: in_queue_seconds {
    type: number
    sql: ${TABLE}."IN_QUEUE_SECONDS" ;;
  }

  dimension: is_analytics_processed {
    type: yesno
    sql: ${TABLE}."IS_ANALYTICS_PROCESSED" ;;
  }

  dimension: is_logged {
    type: yesno
    sql: ${TABLE}."IS_LOGGED" ;;
  }

  dimension: is_outbound {
    type: yesno
    sql: ${TABLE}."IS_OUTBOUND" ;;
  }

  dimension: is_refused {
    type: yesno
    sql: ${TABLE}."IS_REFUSED" ;;
  }

  dimension: is_short_abandon {
    type: yesno
    sql: ${TABLE}."IS_SHORT_ABANDON" ;;
  }

  dimension: is_takeover {
    type: yesno
    sql: ${TABLE}."IS_TAKEOVER" ;;
  }

  dimension: last_name {
    type: string
    sql: ${TABLE}."LAST_NAME" ;;
  }

  dimension: last_update_time {
    type: string
    sql: ${TABLE}."LAST_UPDATE_TIME"::timestamp ;;
  }

  dimension: master_contact_id {
    type: number
    sql: ${TABLE}."MASTER_CONTACT_ID" ;;
  }

  dimension: media_sub_type_id {
    type: string
    sql: ${TABLE}."MEDIA_SUB_TYPE_ID" ;;
  }

  dimension: media_sub_type_name {
    type: string
    sql: ${TABLE}."MEDIA_SUB_TYPE_NAME" ;;
  }

  dimension: media_type {
    type: number
    sql: ${TABLE}."MEDIA_TYPE" ;;
  }

  dimension: media_type_name {
    type: string
    sql: ${TABLE}."MEDIA_TYPE_NAME" ;;
  }

  dimension: point_of_contact_id {
    type: number
    sql: ${TABLE}."POINT_OF_CONTACT_ID" ;;
  }

  dimension: point_of_contact_name {
    type: string
    sql: ${TABLE}."POINT_OF_CONTACT_NAME" ;;
  }

  dimension: post_queue_seconds {
    type: number
    sql: ${TABLE}."POST_QUEUE_SECONDS" ;;
  }

  dimension: pre_queue_seconds {
    type: number
    sql: ${TABLE}."PRE_QUEUE_SECONDS" ;;
  }

  dimension: primary_disposition_id {
    type: number
    sql: ${TABLE}."PRIMARY_DISPOSITION_ID" ;;
  }

  dimension: refuse_reason {
    type: string
    sql: ${TABLE}."REFUSE_REASON" ;;
  }

  dimension: refuse_time {
    type: string
    sql: ${TABLE}."REFUSE_TIME" ;;
  }

  dimension: release_seconds {
    type: number
    sql: ${TABLE}."RELEASE_SECONDS" ;;
  }

  # This is in MILLISECONDS in the table
  dimension: routing_time {
    type: number
    sql: ${TABLE}."ROUTING_TIME" ;;
  }

  dimension: secondary_disposition_id {
    type: number
    sql: ${TABLE}."SECONDARY_DISPOSITION_ID" ;;
  }

  dimension: service_level_flag {
    type: number
    sql: ${TABLE}."SERVICE_LEVEL_FLAG" ;;
  }

  dimension: skill_id {
    type: number
    sql: ${TABLE}."SKILL_ID" ;;
  }

  dimension: skill_name {
    type: string
    sql: ${TABLE}."SKILL_NAME" ;;
  }

  dimension: team_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."TEAM_ID" ;;
  }

  dimension: team_name {
    type: string
    sql: ${TABLE}."TEAM_NAME" ;;
  }

  dimension: to_addr {
    type: string
    sql: ${TABLE}."TO_ADDR" ;;
  }

  dimension: total_duration_seconds {
    type: number
    sql: ${TABLE}."TOTAL_DURATION_SECONDS" ;;
  }

  dimension: transfer_indicator_id {
    type: number
    sql: ${TABLE}."TRANSFER_INDICATOR_ID" ;;
  }

  dimension: transfer_indicator_name {
    type: string
    sql: ${TABLE}."TRANSFER_INDICATOR_NAME" ;;
  }

  dimension: primary_disposition {
    type: string
    sql: ${TABLE}."PRIMARY_DISPOSITION_NAME" ;;
  }

  dimension: secondary_disposition {
    type: string
    sql: ${TABLE}."SECONDARY_DISPOSITION_NAME" ;;
  }

  # - - - - - CUSTOM DIMENSIONS - - - - -

  dimension: total_duration {
    type: string
    sql: TO_TIME(${total_duration_seconds}::string) ;;
  }

  dimension: is_master_contact {
    type: yesno
    sql: ${contact_id} = ${master_contact_id} ;;
  }

  # - - - - - MEASURES - - - - -

# This is messed up because the "to" in the drill shows multiple for the same. I think it's because of the numbers being set on multiple companies.
  measure: total_inbound_calls {
    type: count_distinct
    filters: [media_type: "4", is_outbound: "no"]
    drill_fields: [contact_detail*]
    sql: ${master_contact_id} ;;
  }

  measure: inbound_calls_90_days {
    type: count_distinct
    filters: [contact_start_date: "90 days ago for 90 days", media_type: "4", is_outbound: "no"]
    sql: ${master_contact_id} ;;
  }

  measure: sum_total_duration_seconds {
    type: sum
    filters: [is_master_contact: "yes"]
    drill_fields: [contact_detail*]
    sql: ${total_duration_seconds} ;;
  }

  measure: count_records {
    type: count
    drill_fields: [contact_detail*]
  }

  # ----- Sets of fields for drilling ------
  set: contact_detail {
    fields: [
      master_contact_id,
      contact_start_time,
      from_addr,
      from_company.name,
      sum_total_duration_seconds
    ]
  }
}
