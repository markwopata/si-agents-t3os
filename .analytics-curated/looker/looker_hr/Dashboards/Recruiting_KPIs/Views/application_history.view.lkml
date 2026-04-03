view: application_history {
  sql_table_name: "GREENHOUSE"."APPLICATION_HISTORY"
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

  dimension: application_id {
    type: number
    sql: ${TABLE}."APPLICATION_ID" ;;
  }

  dimension: new_stage_id {
    type: number
    sql: ${TABLE}."NEW_STAGE_ID" ;;
  }

  dimension: new_status {
    type: string
    sql: ${TABLE}."NEW_STATUS" ;;
  }

  dimension_group: updated {
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
    sql: CAST(${TABLE}."UPDATED_AT" AS TIMESTAMP_NTZ) ;;
  }

  measure: count {
    type: count
    drill_fields: []
  }
}
