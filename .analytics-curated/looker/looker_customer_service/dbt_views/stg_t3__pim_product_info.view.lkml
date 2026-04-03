view: stg_t3__pim_product_info {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__PIM_PRODUCT_INFO" ;;

  dimension_group: data_createdat {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATA_CREATEDAT" ;;
  }
  dimension: data_product_category_name {
    type: string
    sql: ${TABLE}."DATA_PRODUCT_CATEGORY_NAME" ;;
  }
  dimension: data_product_category_path {
    type: string
    sql: ${TABLE}."DATA_PRODUCT_CATEGORY_PATH" ;;
  }
  dimension: data_product_core_attributes_make {
    type: string
    sql: ${TABLE}."DATA_PRODUCT_CORE_ATTRIBUTES_MAKE" ;;
  }
  dimension: data_product_core_attributes_model {
    type: string
    sql: ${TABLE}."DATA_PRODUCT_CORE_ATTRIBUTES_MODEL" ;;
  }
  dimension: data_product_core_attributes_name {
    type: string
    sql: ${TABLE}."DATA_PRODUCT_CORE_ATTRIBUTES_NAME" ;;
  }
  dimension: data_product_core_attributes_variant {
    type: string
    sql: ${TABLE}."DATA_PRODUCT_CORE_ATTRIBUTES_VARIANT" ;;
  }
  dimension: data_product_core_attributes_year {
    type: string
    sql: ${TABLE}."DATA_PRODUCT_CORE_ATTRIBUTES_YEAR" ;;
  }
  dimension: data_product_source_attributes_source {
    type: string
    sql: ${TABLE}."DATA_PRODUCT_SOURCE_ATTRIBUTES_SOURCE" ;;
  }
  dimension: data_tenant_id {
    type: string
    sql: ${TABLE}."DATA_TENANT_ID" ;;
  }
  dimension_group: data_updatedat {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATA_UPDATEDAT" ;;
  }
  dimension: pim_product_id {
    type: string
    sql: ${TABLE}."PIM_PRODUCT_ID" ;;
  }
  dimension: time {
    type: string
    sql: ${TABLE}."TIME" ;;
  }
  measure: count {
    type: count
    drill_fields: [data_product_core_attributes_name, data_product_category_name]
  }
}
