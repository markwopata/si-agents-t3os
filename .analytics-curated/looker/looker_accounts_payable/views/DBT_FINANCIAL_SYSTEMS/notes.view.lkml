view: notes {
  sql_table_name: "CLIO_GOLD"."NOTES" ;;
  drill_fields: [clio_note_id]

  dimension: clio_note_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."CLIO_NOTE_ID" ;;
  }
  dimension: author_first_name {
    type: string
    sql: ${TABLE}."AUTHOR_FIRST_NAME" ;;
  }
  dimension: author_last_name {
    type: string
    sql: ${TABLE}."AUTHOR_LAST_NAME" ;;
  }
  dimension: clio_author_id {
    type: number
    sql: ${TABLE}."CLIO_AUTHOR_ID" ;;
  }
  dimension_group: created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."CREATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: customer_number {
    type: string
    sql: ${TABLE}."CUSTOMER_NUMBER" ;;
  }
  dimension_group: date {
    type: time
    timeframes: [raw, date, week, month, quarter, year]
    convert_tz: no
    datatype: date
    sql: ${TABLE}."DATE" ;;
  }
  dimension: detail {
    type: string
    sql: ${TABLE}."DETAIL" ;;
  }
  dimension_group: extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."EXTRACTED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: related_matter_id {
    type: number
    sql: ${TABLE}."RELATED_MATTER_ID" ;;
  }
  dimension: related_matter_practice {
    type: string
    sql: ${TABLE}."RELATED_MATTER_PRACTICE" ;;
  }
  dimension: subject {
    type: string
    sql: ${TABLE}."SUBJECT" ;;
  }
  dimension: subscription_type {
    type: string
    sql: ${TABLE}."SUBSCRIPTION_TYPE" ;;
  }
  dimension_group: updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }
  measure: count {
    type: count
    drill_fields: [clio_note_id, author_first_name, author_last_name]
  }
}
