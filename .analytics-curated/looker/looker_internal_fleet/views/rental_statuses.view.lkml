view: rental_statuses {
  sql_table_name: "PUBLIC"."RENTAL_STATUSES"
    ;;
  drill_fields: [rental_status_id]

  dimension: rental_status_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_STATUS_ID" ;;
  }

  dimension_group: _es_update_timestamp {
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
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [rental_status_id, name]
  }
}
