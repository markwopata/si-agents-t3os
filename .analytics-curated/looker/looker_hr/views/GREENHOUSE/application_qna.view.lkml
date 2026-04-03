view: application_qna {
  sql_table_name: "GREENHOUSE"."APPLICATION_QNA"
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

  dimension: answer {
    type: string
    sql: ${TABLE}."ANSWER" ;;
  }

  dimension: application_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: index {
    type: number
    sql: ${TABLE}."INDEX" ;;
  }

  dimension: question {
    type: string
    sql: ${TABLE}."QUESTION" ;;
  }

  measure: count {
    type: count
    drill_fields: [application.id]
  }
}
