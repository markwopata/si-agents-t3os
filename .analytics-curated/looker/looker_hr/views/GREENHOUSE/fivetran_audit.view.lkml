view: fivetran_audit {
  sql_table_name: "GREENHOUSE"."FIVETRAN_AUDIT"
    ;;
  drill_fields: [id]

  dimension: id {
    primary_key: yes
    type: string
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

  dimension_group: done {
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
    sql: CAST(${TABLE}."DONE" AS TIMESTAMP_NTZ) ;;
  }

  dimension: message {
    type: string
    sql: ${TABLE}."MESSAGE" ;;
  }

  dimension_group: progress {
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
    sql: CAST(${TABLE}."PROGRESS" AS TIMESTAMP_NTZ) ;;
  }

  dimension: rows_updated_or_inserted {
    type: number
    sql: ${TABLE}."ROWS_UPDATED_OR_INSERTED" ;;
  }

  dimension: schema {
    type: string
    sql: ${TABLE}."SCHEMA" ;;
  }

  dimension_group: start {
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
    sql: CAST(${TABLE}."START" AS TIMESTAMP_NTZ) ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: table {
    type: string
    sql: ${TABLE}."TABLE" ;;
  }

  dimension: update_id {
    type: string
    sql: ${TABLE}."UPDATE_ID" ;;
  }

  dimension_group: update_started {
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
    sql: CAST(${TABLE}."UPDATE_STARTED" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: [id]
  }
}
