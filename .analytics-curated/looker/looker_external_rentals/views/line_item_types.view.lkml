view: line_item_types {
  sql_table_name: "PUBLIC"."GLOBAL_LINE_ITEM_TYPES"
    ;;
  drill_fields: [line_item_type_id]

  dimension: line_item_type_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."LINE_ITEM_TYPE_ID" ;;
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

  dimension: domain_id {
    type: number
    sql: ${TABLE}."DOMAIN_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [line_item_type_id, name]
  }
}
