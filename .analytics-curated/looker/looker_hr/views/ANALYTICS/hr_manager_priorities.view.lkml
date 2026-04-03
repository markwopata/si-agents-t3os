view: hr_manager_priorities {
  sql_table_name: "GS"."HR_MANAGER_PRIORITIES"
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

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: candidate_id {
    type: number
    sql: ${TABLE}."CANDIDATE_ID" ;;
  }

  dimension: candidate {
    type: string
    sql: ${TABLE}."CANDIDATE" ;;
  }

  dimension: priority_comments {
    type: string
    sql: ${TABLE}."COMMENTS" ;;
  }

  dimension: priority_app {
    type: string
    sql: ${TABLE}."PRIORITY" ;;
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
    sql: CAST(${TABLE}."TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
