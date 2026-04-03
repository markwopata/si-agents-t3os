view: suspect_parameter_numbers {
  sql_table_name: "PUBLIC"."SUSPECT_PARAMETER_NUMBERS"
    ;;
  drill_fields: [suspect_parameter_number_id]

  dimension: suspect_parameter_number_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."SUSPECT_PARAMETER_NUMBER_ID" ;;
    hidden: yes
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
    hidden: yes
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
    hidden: yes
  }

  measure: description_groups {
    label: "Detail"
    type: list
    list_field: description
    view_label: "Tracking Diagnostic Codes"
  }

  measure: count {
    type: count
    drill_fields: [suspect_parameter_number_id]
    hidden: yes
  }
}
