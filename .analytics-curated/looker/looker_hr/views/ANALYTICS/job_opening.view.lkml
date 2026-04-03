view: job_opening {
  sql_table_name: "ANALYTICS"."GREENHOUSE"."JOB_OPENING"
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

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: close_reason_id {
    type: number
    sql: ${TABLE}."CLOSE_REASON_ID" ;;
  }

  dimension_group: closed {
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
    sql: CAST(${TABLE}."CLOSED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: job_id {
    type: number
    sql: ${TABLE}."JOB_ID" ;;
  }

  dimension_group: opened {
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
    sql: CAST(${TABLE}."OPENED_AT" AS TIMESTAMP_NTZ) ;;
  }

  dimension: opening_id {
    type: string
    sql: ${TABLE}."OPENING_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }

  measure: average_days_job_open {
    type: average
    sql:  datediff(day,${opened_date},${closed_date}) ;;
  }

}
