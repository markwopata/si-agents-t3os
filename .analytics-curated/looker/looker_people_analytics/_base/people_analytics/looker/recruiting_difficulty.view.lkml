view: recruiting_difficulty {
  sql_table_name: "LOOKER"."RECRUITING_DIFFICULTY" ;;

  dimension: _es_update_timestamp {
    type: date_raw
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
    hidden:  yes
  }
  dimension: difficulty_quartile {
    type: number
    sql: ${TABLE}."DIFFICULTY_QUARTILE" ;;
  }
  dimension: job_name {
    primary_key: yes
    type: string
    sql: ${TABLE}."JOB_NAME" ;;
  }
  measure: count {
    type: count
    drill_fields: [job_name]
  }
}
