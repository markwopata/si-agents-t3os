view: stage_matters_changelog {
  sql_table_name: "CLIO_GOLD"."MATTERS_CHANGELOG" ;;

  dimension_group: extracted {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."EXTRACTED_AT" AS TIMESTAMP_NTZ) ;;
  }
  dimension: matter_id {
    type: string
    sql: ${TABLE}."MATTER_ID" ;;
  }
  dimension: matter_status_value {
    type: string
    sql: ${TABLE}."MATTER_STATUS_VALUE" ;;
  }
  measure: count {
    type: count
  }
}
