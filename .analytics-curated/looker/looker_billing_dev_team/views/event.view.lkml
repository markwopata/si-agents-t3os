view: event {
  sql_table_name: "ANALYTICS"."BILLING_SENDGRID"."EVENT"
    ;;
  drill_fields: [sg_event_id]

  dimension: sg_event_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."SG_EVENT_ID" ;;
  }

  dimension: _fivetran_id {
    type: string
    sql: ${TABLE}."_FIVETRAN_ID" ;;
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

  dimension: attempt {
    type: number
    sql: ${TABLE}."ATTEMPT" ;;
  }

  dimension: campaign_id {
    type: number
    sql: ${TABLE}."CAMPAIGN_ID" ;;
  }

  dimension: campaign_split_id {
    type: string
    sql: ${TABLE}."CAMPAIGN_SPLIT_ID" ;;
  }

  dimension: campaign_version {
    type: string
    sql: ${TABLE}."CAMPAIGN_VERSION" ;;
  }

  dimension: cert_err {
    type: string
    sql: ${TABLE}."CERT_ERR" ;;
  }

  dimension: custom_sg_content_type {
    type: string
    sql: ${TABLE}."CUSTOM_SG_CONTENT_TYPE" ;;
  }

  dimension: custom_sg_template_id {
    type: string
    sql: ${TABLE}."CUSTOM_SG_TEMPLATE_ID" ;;
  }

  dimension: custom_sg_template_name {
    type: string
    sql: ${TABLE}."CUSTOM_SG_TEMPLATE_NAME" ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}."EMAIL" ;;
  }

  dimension: event {
    type: string
    sql: ${TABLE}."EVENT" ;;
  }

  dimension: ip {
    type: string
    sql: ${TABLE}."IP" ;;
  }

  dimension: mc_stats {
    type: string
    sql: ${TABLE}."MC_STATS" ;;
  }

  dimension: phase_id {
    type: string
    sql: ${TABLE}."PHASE_ID" ;;
  }

  dimension: pool_id {
    type: string
    sql: ${TABLE}."POOL_ID" ;;
  }

  dimension: pool_name {
    type: string
    sql: ${TABLE}."POOL_NAME" ;;
  }

  dimension: post_type {
    type: string
    sql: ${TABLE}."POST_TYPE" ;;
  }

  dimension: reason {
    type: string
    sql: ${TABLE}."REASON" ;;
  }

  dimension: response {
    type: string
    sql: ${TABLE}."RESPONSE" ;;
  }

  dimension: send_at {
    type: string
    sql: ${TABLE}."SEND_AT" ;;
  }

  dimension: sg_message_id {
    type: string
    sql: ${TABLE}."SG_MESSAGE_ID" ;;
  }

  dimension: sg_user_id {
    type: string
    sql: ${TABLE}."SG_USER_ID" ;;
  }

  dimension: singlesend_id {
    type: string
    sql: ${TABLE}."SINGLESEND_ID" ;;
  }

  dimension: singlesend_name {
    type: string
    sql: ${TABLE}."SINGLESEND_NAME" ;;
  }

  dimension: smtp_id {
    type: string
    sql: ${TABLE}."SMTP_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension_group: timestamp {
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
    sql: CAST(${TABLE}."TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: tls {
    type: string
    sql: ${TABLE}."TLS" ;;
  }

  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }

  dimension: url {
    type: string
    sql: ${TABLE}."URL" ;;
  }

  dimension: url_offset_index {
    type: number
    sql: ${TABLE}."URL_OFFSET_INDEX" ;;
  }

  dimension: url_offset_type {
    type: string
    sql: ${TABLE}."URL_OFFSET_TYPE" ;;
  }

  dimension: useragent {
    type: string
    sql: ${TABLE}."USERAGENT" ;;
  }

  measure: count {
    type: count
    drill_fields: [sg_event_id, pool_name, singlesend_name, custom_sg_template_name]
  }
}
