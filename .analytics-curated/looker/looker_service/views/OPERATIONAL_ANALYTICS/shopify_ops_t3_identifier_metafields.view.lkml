view: shopify_ops_t3_identifier_metafields {
  sql_table_name: "PARTS_INVENTORY"."SHOPIFY_OPS_T3_IDENTIFIER_METAFIELDS" ;;

  dimension: mapping_status {
    type: string
    sql: ${TABLE}."MAPPING_STATUS" ;;
  }
  dimension: shopify_product_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SHOPIFY_PRODUCT_ID" ;;
  }
  dimension: t3_part_id {
    type: number
    sql: ${TABLE}."T3_PART_ID" ;;
  }
  dimension: t3_part_number {
    type: string
    sql: ${TABLE}."T3_PART_NUMBER" ;;
  }
  dimension: t3_provider_id {
    type: number
    sql: ${TABLE}."T3_PROVIDER_ID" ;;
  }
}
