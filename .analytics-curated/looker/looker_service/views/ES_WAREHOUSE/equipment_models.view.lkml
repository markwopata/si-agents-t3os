view: equipment_models {
  sql_table_name: "ES_WAREHOUSE"."PUBLIC"."EQUIPMENT_MODELS" ;;
  drill_fields: [equipment_model_id]

  dimension: equipment_model_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."EQUIPMENT_MODEL_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: equipment_make_id {
    type: number
    sql: ${TABLE}."EQUIPMENT_MAKE_ID" ;;
  }
  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }
  dimension: service_document_collection_id {
    type: number
    sql: ${TABLE}."SERVICE_DOCUMENT_COLLECTION_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [equipment_model_id, name, equipment_classes_models_xref.count]
  }
}
