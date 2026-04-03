view: front_cx_message {
  sql_table_name: "PEOPLE_ANALYTICS"."BUSINESS_INTELLIGENCE"."FRONT_CX_MESSAGE" ;;

  dimension: author_id {
    type: string
    sql: ${TABLE}."AUTHOR_ID" ;;
  }
  dimension: blurb {
    type: string
    sql: ${TABLE}."BLURB" ;;
  }
  dimension: body {
    type: string
    sql: ${TABLE}."BODY" ;;
  }
  dimension: conversation_id {
    type: string
    sql: ${TABLE}."CONVERSATION_ID" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: duration {
    type: number
    sql: ${TABLE}."DURATION" ;;
  }
  dimension: have_been_answered {
    type: yesno
    sql: ${TABLE}."HAVE_BEEN_ANSWERED" ;;
  }
  dimension: have_been_favorited {
    type: yesno
    sql: ${TABLE}."HAVE_BEEN_FAVORITED" ;;
  }
  dimension: have_been_retweeted {
    type: yesno
    sql: ${TABLE}."HAVE_BEEN_RETWEETED" ;;
  }
  dimension: headers {
    type: string
    sql: ${TABLE}."HEADERS" ;;
  }
  dimension: intercom_url {
    type: string
    sql: ${TABLE}."INTERCOM_URL" ;;
  }
  dimension: is_inbound {
    type: yesno
    sql: ${TABLE}."IS_INBOUND" ;;
  }
  dimension: is_retweet {
    type: yesno
    sql: ${TABLE}."IS_RETWEET" ;;
  }
  dimension: message_id {
    type: string
    sql: ${TABLE}."MESSAGE_ID" ;;
  }
  dimension: text {
    type: string
    sql: ${TABLE}."TEXT" ;;
  }
  dimension: thread_ref {
    type: string
    sql: ${TABLE}."THREAD_REF" ;;
  }
  dimension: twitter_url {
    type: string
    sql: ${TABLE}."TWITTER_URL" ;;
  }
  dimension: type {
    type: string
    sql: ${TABLE}."TYPE" ;;
  }
  measure: count {
    type: count
  }
  measure: messages_received {
    type: count_distinct
    sql: ${message_id} ;;
    filters: [is_inbound: "true"]
    drill_fields: [created_raw, message_id, conversation_id, blurb]
  }
  measure: messages_sent {
    type: count_distinct
    sql: ${message_id} ;;
    filters: [is_inbound: "false"]
    drill_fields: [created_raw, message_id, conversation_id, blurb]
  }
}
