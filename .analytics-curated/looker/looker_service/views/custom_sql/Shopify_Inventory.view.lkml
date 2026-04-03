view: shopify_inventory {
  derived_table: {
  sql:
  -- Shopify Inventory w/part_id
select shopify_product_id,
       t3_part_id as part_id,
       iq.name as inventory_type,
       l.name as location,
       quantity
from analytics.SHOPIFY.INVENTORY_QUANTITY iq
         join analytics.shopify.INVENTORY_LEVEL il on iq.INVENTORY_LEVEL_ID = il.ID and iq.inventory_item_id = il.inventory_item_id
         join analytics.SHOPIFY.LOCATION l on il.LOCATION_ID = l.ID
         join fleet_optimization.gold.int_inventory_item ii on il.inventory_item_id = ii.inventory_item_id
         join analytics.parts_inventory.shopify_ops_t3_identifier_metafields tim on ii.product_id = tim.shopify_product_id
where 1 = 1
and l.name not ilike '%via shopify collective'
-- iq.name = 'on_hand'
-- and quantity > 0
;;
}

  dimension: pk {
    type: string
    primary_key: yes
    hidden: yes
    sql: concat(CAST(${TABLE}.shopify_product_id AS VARCHAR), '_', ${TABLE}.location);;
  }


  dimension: shopify_product_id {
    type: number
    sql: ${TABLE}.shopify_product_id ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}.part_id ;;
  }

  dimension: inventory_type {
    type: string
    sql: ${TABLE}.inventory_type ;;
  }

  dimension: location {
    type: string
    sql: ${TABLE}.location ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}.quantity ;;
  }

  dimension: exists_in_shopify_catalog {
    type: yesno
    sql: ${shopify_product_id} IS NOT NULL ;;
  }


  measure: quantity_available {
    type: sum
    sql: ${quantity};;
    filters: [inventory_type: "available"]
    drill_fields: [shopify_product_id, part_id, inventory_type, location, quantity]
  }

  measure: quantity_on_hand {
    type: sum
    sql: ${quantity} ;;
    filters: [inventory_type: "on_hand"]
    drill_fields: [shopify_product_id, part_id, inventory_type, location, quantity]
  }

  measure: reserved {
    type: sum
    sql: ${quantity} ;;
    filters: [inventory_type: "reserved"]
    drill_fields: [shopify_product_id, part_id, inventory_type, location, quantity]
  }

  measure: incoming {
    type: sum
    sql: ${quantity};;
    filters: [inventory_type: "incoming"]
    drill_fields: [shopify_product_id, part_id, inventory_type, location, quantity]
  }

  measure: safety_stock {
    type: sum
    sql: ${quantity};;
    filters: [inventory_type: "safety_stock"]
    drill_fields: [shopify_product_id, part_id, inventory_type, location, quantity]
  }
}
