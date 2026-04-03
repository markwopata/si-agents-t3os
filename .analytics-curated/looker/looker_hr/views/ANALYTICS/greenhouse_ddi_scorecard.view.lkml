view: greenhouse_ddi_scorecard {
  sql_table_name: "GS"."GREENHOUSE_DDI_SCORECARD"
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

  dimension: _row {
    type: number
    sql: ${TABLE}."_ROW" ;;
  }

  dimension: candidate_email {
    type: string
    sql: ${TABLE}."CANDIDATE_EMAIL" ;;
  }

  dimension: competency {
    type: string
    sql: ${TABLE}."COMPETENCY" ;;
  }

  dimension: candidate_competency {
    type: string
    primary_key: yes
    sql: concat(${candidate_email},'-',${competency}) ;;
  }

  dimension: job_location {
    type: string
    sql: ${TABLE}."JOB_LOCATION" ;;
  }

  dimension: recruiter {
    type: string
    sql: ${TABLE}."RECRUITER" ;;
  }

  dimension: score {
    type: number
    sql: ${TABLE}."SCORE" ;;
  }

  dimension: scorecard_id_from_greenhouse {
    type: number
    value_format_name: id
    sql: ${TABLE}."SCORECARD_ID_FROM_GREENHOUSE" ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }

  measure: average_DDI_score {
    type: average
    value_format: "0.0"
    sql: ${score} ;;
  }
}
