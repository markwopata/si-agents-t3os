view: stg_t3__pim_product_shipping_dimensions {
  sql_table_name: "TRIAGE"."STG_T3__PIM_PRODUCT_SHIPPING_DIMENSIONS" ;;

  dimension: pim_product_id {
    type: string
    sql: ${TABLE}."PIM_PRODUCT_ID" ;;
  }
  dimension: shipping_dimension_description {
    type: string
    sql: ${TABLE}."SHIPPING_DIMENSION_DESCRIPTION" ;;
  }
  dimension: shipping_dimension_name {
    type: string
    sql: ${TABLE}."SHIPPING_DIMENSION_NAME" ;;
  }
  dimension: shipping_dimension_uom {
    type: string
    sql: ${TABLE}."SHIPPING_DIMENSION_UOM" ;;
  }
  dimension: shipping_dimension_value {
    type: string
    sql: ${TABLE}."SHIPPING_DIMENSION_VALUE" ;;
  }
  measure: count {
    type: count
    drill_fields: [shipping_dimension_name]
  }
}
