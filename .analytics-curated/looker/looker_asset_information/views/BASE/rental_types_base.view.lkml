view: rental_types {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."RENTAL_TYPES"
    ;;
  drill_fields: [rental_type_id]

  dimension: rental_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."RENTAL_TYPE_ID" ;;
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
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  measure: count {
    type: count
    drill_fields: [rental_type_id, name]
  }
}
