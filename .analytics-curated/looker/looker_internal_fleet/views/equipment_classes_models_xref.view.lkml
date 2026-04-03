view: equipment_classes_models_xref {
  sql_table_name: "PUBLIC"."EQUIPMENT_CLASSES_MODELS_XREF"
    ;;
  drill_fields: [equipment_classes_models_xref_id]

  dimension: equipment_classes_models_xref_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASSES_MODELS_XREF_ID" ;;
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

  dimension_group: date_created {
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
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }

  dimension: equipment_class_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_CLASS_ID" ;;
  }

  dimension: equipment_model_id {
    type: number
    # hidden: yes
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }

  measure: count {
    type: count
    drill_fields: [equipment_classes_models_xref_id, equipment_models.equipment_model_id, equipment_models.name]
  }
}
