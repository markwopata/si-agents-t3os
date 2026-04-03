view: front_cx_conversation {
  sql_table_name: "PEOPLE_ANALYTICS"."BUSINESS_INTELLIGENCE"."FRONT_CX_CONVERSATION" ;;

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
  dimension: recipient_handle {
    type: string
    sql: ${TABLE}."RECIPIENT_HANDLE" ;;
  }
  dimension: recipient_role {
    type: string
    sql: ${TABLE}."RECIPIENT_ROLE" ;;
  }
  dimension: teammate_id {
    type: string
    sql: ${TABLE}."TEAMMATE_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [inbox_name]
  }
}
