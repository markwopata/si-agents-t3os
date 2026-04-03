view: stg_t3__pim_product_options {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__PIM_PRODUCT_OPTIONS" ;;

  dimension: pim_product_id {
    type: string
    sql: ${TABLE}."PIM_PRODUCT_ID" ;;
  }
  dimension: product_option_attribute_name {
    type: string
    sql: ${TABLE}."PRODUCT_OPTION_ATTRIBUTE_NAME" ;;
  }
  dimension: product_option_attribute_value {
    type: string
    sql: ${TABLE}."PRODUCT_OPTION_ATTRIBUTE_VALUE" ;;
  }
  dimension: product_option_choice_name {
    type: string
    sql: ${TABLE}."PRODUCT_OPTION_CHOICE_NAME" ;;
  }
  dimension: product_option_group {
    type: string
    sql: ${TABLE}."PRODUCT_OPTION_GROUP" ;;
  }
  dimension: product_option_name {
    type: string
    sql: ${TABLE}."PRODUCT_OPTION_NAME" ;;
  }
  dimension: product_option_uom {
    type: string
    sql: ${TABLE}."PRODUCT_OPTION_UOM" ;;
  }
  dimension: product_option_value {
    type: string
    sql: ${TABLE}."PRODUCT_OPTION_VALUE" ;;
  }
  measure: count {
    type: count
    drill_fields: [product_option_attribute_name, product_option_name, product_option_choice_name]
  }
}
