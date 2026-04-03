view: stg_t3__pim_product_category {
  sql_table_name: "BUSINESS_INTELLIGENCE"."TRIAGE"."STG_T3__PIM_PRODUCT_CATEGORY" ;;

  dimension: pim_category_name {
    type: string
    sql: ${TABLE}."PIM_CATEGORY_NAME" ;;
  }
  dimension: pim_category_uom {
    type: string
    sql: ${TABLE}."PIM_CATEGORY_UOM" ;;
  }
  dimension: pim_category_value {
    type: string
    sql: ${TABLE}."PIM_CATEGORY_VALUE" ;;
  }
  dimension: pim_product_id {
    type: string
    sql: ${TABLE}."PIM_PRODUCT_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [pim_category_name]
  }
}
