view: prospects__notes__v3 {
  sql_table_name: "PROSPECTS"."PROSPECTS__NOTES__V3"
    ;;

  dimension: note {
    type: string
    sql: ${TABLE}."NOTE" ;;
  }

  dimension: note_id {
    type: number
    sql: ${TABLE}."NOTE_ID" ;;
  }

  dimension: prospect_id {
    type: string
    sql: ${TABLE}."PROSPECT_ID" ;;
  }

  dimension: sales_representative_email_address {
    type: string
    sql: ${TABLE}."SALES_REPRESENTATIVE_EMAIL_ADDRESS" ;;
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
    sql: ${TABLE}."TIMESTAMP" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
