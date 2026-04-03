view: failure_mode_identifiers {
  sql_table_name: "PUBLIC"."FAILURE_MODE_IDENTIFIERS"
    ;;
  drill_fields: [failure_mode_identifier_id]

  dimension: failure_mode_identifier_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."FAILURE_MODE_IDENTIFIER_ID" ;;
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

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  measure: description_groups {
    label: "Failure"
    type: list
    list_field: description
  }

  measure: count {
    type: count
    drill_fields: [failure_mode_identifier_id]
  }
}
