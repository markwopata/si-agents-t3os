view: int_shopify_cost {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."INT_SHOPIFY_COST" ;;

  dimension: cost {
    type: number
    sql: ${TABLE}."PRODUCT_COST" ;;
  }

  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }
  dimension: product_id {
    type: number
    sql: ${TABLE}."PRODUCT_ID" ;;
  }
  dimension: product_variant_id {
    type: number
    sql: ${TABLE}."PRODUCT_VARIANT_ID" ;;
  }

  dimension: snapshot_month {
    type: date
    sql: ${TABLE}."SNAPSHOT_MONTH" ;;
  }

  dimension: unique_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."UNIQUE_ID" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }

}
