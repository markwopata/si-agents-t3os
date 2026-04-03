view: scorecard_qna {
  sql_table_name: "GREENHOUSE"."SCORECARD_QNA"
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

  dimension: answer {
    type: string
    sql: TRIM(${TABLE}."ANSWER") ;;
  }

  dimension: index {
    type: number
    sql: ${TABLE}."INDEX" ;;
  }

  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
  }

  dimension: scorecard_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."SCORECARD_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [id, scorecard.id]
  }
}
