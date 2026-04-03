view: int_inventory_item {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."INT_INVENTORY_ITEM" ;;

  dimension: current_product_cost {
    type: number
    sql: ${TABLE}."CURRENT_PRODUCT_COST" ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: product_variant_id {
    type: number
    sql: ${TABLE}."PRODUCT_VARIANT_ID" ;;
  }

  dimension: current_product_price {
    type: number
    sql: ${TABLE}."CURRENT_PRODUCT_PRICE" ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}."PRODUCT_ID" ;;
  }
}
