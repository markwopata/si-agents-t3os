view: product_classes {
  sql_table_name: "INVENTORY"."PRODUCT_CLASSES" ;;
  drill_fields: [product_class_id]

  dimension: product_class_id {
    primary_key: yes
    type: number
    sql: ${TABLE}."PRODUCT_CLASS_ID" ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: cat_class {
    type: string
    sql: ${TABLE}."CAT_CLASS" ;;
  }
  dimension: category_name {
    type: string
    sql: ${TABLE}."CATEGORY_NAME" ;;
  }
  dimension: classification {
    type: string
    sql: ${TABLE}."CLASSIFICATION" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_UPDATED" ;;
  }
  measure: count {
    type: count
    drill_fields: [product_class_id, category_name]
  }
}
