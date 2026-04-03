view: interview_question {
  sql_table_name: "GREENHOUSE"."INTERVIEW_QUESTION"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}."ID" ;;
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

  dimension: interview_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."INTERVIEW_ID" ;;
  }

  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, interview.id, interview.name]
  }
}
