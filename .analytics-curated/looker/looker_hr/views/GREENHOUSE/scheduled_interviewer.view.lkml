view: scheduled_interviewer {
  sql_table_name: "GREENHOUSE"."SCHEDULED_INTERVIEWER"
    ;;

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

  dimension: interviewer_id {
    type: number
    sql: ${TABLE}."INTERVIEWER_ID" ;;
  }

  dimension: scheduled_interview_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SCHEDULED_INTERVIEW_ID" ;;
  }

  dimension: scorecard_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SCORECARD_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [scorecard.id, scheduled_interview.id]
  }
}
