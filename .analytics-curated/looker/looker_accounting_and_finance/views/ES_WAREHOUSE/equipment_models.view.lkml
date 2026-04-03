view: equipment_models {
  sql_table_name: public.equipment_models ;;
  drill_fields: [equipment_model_id]

  dimension: equipment_model_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."equipment_model_id" ;;
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
    sql: ${TABLE}."date_created" ;;
  }

  dimension_group: date_updated {
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
    sql: ${TABLE}."date_updated" ;;
  }

  dimension: domain_id {
    type: number
    sql: ${TABLE}."domain_id" ;;
  }

  dimension: equipment_make_id {
    type: number
    sql: ${TABLE}."equipment_make_id" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."name" ;;
  }

  dimension: service_document_collection_id {
    type: number
    sql: ${TABLE}."service_document_collection_id" ;;
  }

  measure: count {
    type: count
    drill_fields: [equipment_model_id, name]
  }
}
