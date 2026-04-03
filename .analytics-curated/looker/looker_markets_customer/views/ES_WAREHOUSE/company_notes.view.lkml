view: company_notes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."COMPANY_NOTES"
    ;;
  drill_fields: [company_note_id]

  dimension: company_note_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."COMPANY_NOTE_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: note_description {
    type: string
    sql: ${TABLE}."NOTE_DESCRIPTION" ;;
  }

  dimension: note_text {
    type: string
    sql: ${TABLE}."NOTE_TEXT" ;;
  }

  dimension: note_type_id {
    type: number
    sql: ${TABLE}."NOTE_TYPE_ID" ;;
  }

  dimension: user_id {
    type: number
    sql: ${TABLE}."USER_ID" ;;
  }

  dimension: user_and_note {
    type: string
    sql: concat(${users.Full_Name},' - ',${note_text}) ;;
  }

  measure: count {
    hidden: yes
    type: count
    drill_fields: [company_note_id]
  }
}
