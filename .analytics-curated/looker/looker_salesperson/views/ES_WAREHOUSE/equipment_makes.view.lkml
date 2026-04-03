view: equipment_makes {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_MAKES"
    ;;
  drill_fields: [equipment_make_id]

  dimension: equipment_make_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
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

  dimension: popular_equipment_make {
    type: yesno
    sql: ${TABLE}."POPULAR_EQUIPMENT_MAKE" ;;
  }

  dimension: popular_vehicle_make {
    type: yesno
    sql: ${TABLE}."POPULAR_VEHICLE_MAKE" ;;
  }

  dimension: sort_index {
    type: number
    sql: ${TABLE}."SORT_INDEX" ;;
  }

  measure: count {
    type: count
    drill_fields: [equipment_make_id, name, equipment_models.count]
  }
}
