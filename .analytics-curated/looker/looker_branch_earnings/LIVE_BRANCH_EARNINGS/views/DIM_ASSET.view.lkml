view: DIM_ASSET {
  sql_table_name: "BRANCH_EARNINGS"."DIM_ASSET"
    ;;

  dimension: PK_ASSET {
    type: string
    hidden: yes
    primary_key: yes
    sql: ${TABLE}."PK_ASSET" ;;
  }

  dimension: ASSET_ID {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: MARKET_ID {
    type: string
    hidden: yes
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: EQUIPMENT_MAKE {
    type: string
    sql: ${TABLE}."EQUIPMENT_MAKE" ;;
  }

  dimension: EQUIPMENT_TYPE {
    type: string
    sql: ${TABLE}."EQUIPMENT_TYPE" ;;
  }

  dimension: EQUIPMENT_MODEL_NAME {
    type: string
    sql: ${TABLE}."EQUIPMENT_MODEL_NAME" ;;
  }

  dimension: EQUIPMENT_CLASS_NAME {
    type: string
    sql: ${TABLE}."EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: EQUIPMENT_SUBCATEGORY_NAME {
    type: string
    sql: ${TABLE}."EQUIPMENT_SUBCATEGORY_NAME" ;;
  }

  dimension: EQUIPMENT_CATEGORY_NAME {
    type: string
    sql: ${TABLE}."EQUIPMENT_CATEGORY_NAME" ;;
  }

  dimension: CURRENT_OEC {
    type: number
    sql: ${TABLE}."CURRENT_OEC" ;;
  }

  dimension: CURRENT_OEC_BUCKET {
    type: string
    order_by_field: CURRENT_OEC_BUCKET_SORT
    sql: ${TABLE}."CURRENT_OEC_BUCKET" ;;
  }

  dimension: CURRENT_OEC_BUCKET_SORT {
    type: number
    hidden: yes
    sql: ${TABLE}."CURRENT_OEC_BUCKET_SORT" ;;
  }

  dimension: RECORD_CREATED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_CREATED_TIMESTAMP" ;;
  }

  dimension: RECORD_MODIFIED_TIMESTAMP {
    type: date_time
    sql: ${TABLE}."RECORD_MODIFIED_TIMESTAMP" ;;
  }

  measure: count {
    type: count
    label: "NUMBER OF ASSETS"
    drill_fields: [ASSET_ID, EQUIPMENT_TYPE, EQUIPMENT_CLASS_NAME, EQUIPMENT_CATEGORY_NAME, EQUIPMENT_SUBCATEGORY_NAME, EQUIPMENT_MAKE, EQUIPMENT_MODEL_NAME, CURRENT_OEC]
  }
}
