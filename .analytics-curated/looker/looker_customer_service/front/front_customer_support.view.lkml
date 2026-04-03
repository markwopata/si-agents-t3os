view: front_customer_support {
  sql_table_name: "PEOPLE_ANALYTICS"."BUSINESS_INTELLIGENCE"."FRONT_CUSTOMER_SUPPORT" ;;

  dimension: blurb {
    type: string
    sql: ${TABLE}."BLURB" ;;
  }
  dimension: body {
    type: string
    sql: ${TABLE}."BODY" ;;
  }
  dimension_group: conversation_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CONVERSATION_CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: conversation_id {
    type: string
    sql: ${TABLE}."CONVERSATION_ID" ;;
  }
  dimension: conversation_subject {
    type: string
    sql: ${TABLE}."CONVERSATION_SUBJECT" ;;
  }
  dimension: inbox_id {
    type: string
    sql: ${TABLE}."INBOX_ID" ;;
  }
  dimension: inbox_name {
    type: string
    sql: ${TABLE}."INBOX_NAME" ;;
  }
  dimension_group: message_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."MESSAGE_CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: message_id {
    type: string
    sql: ${TABLE}."MESSAGE_ID" ;;
  }
  dimension: recipient_handle {
    type: string
    sql: ${TABLE}."RECIPIENT_HANDLE" ;;
  }
  dimension: recipient_role {
    type: string
    sql: ${TABLE}."RECIPIENT_ROLE" ;;
  }
  dimension: teammate_email {
    type: string
    sql: ${TABLE}."TEAMMATE_EMAIL" ;;
  }
  dimension: teammate_first_name {
    type: string
    sql: ${TABLE}."TEAMMATE_FIRST_NAME" ;;
  }
  dimension: teammate_id {
    type: string
    sql: ${TABLE}."TEAMMATE_ID" ;;
  }
  dimension: teammate_last_name {
    type: string
    sql: ${TABLE}."TEAMMATE_LAST_NAME" ;;
  }
  dimension: text {
    type: string
    sql: ${TABLE}."TEXT" ;;
  }
  dimension: teammate_full_name {
    type: string
    sql: concat(${teammate_first_name},' ',${teammate_last_name}) ;;
  }
  measure: count {
    type: count
    drill_fields: [teammate_first_name, teammate_last_name, inbox_name]
  }
}
