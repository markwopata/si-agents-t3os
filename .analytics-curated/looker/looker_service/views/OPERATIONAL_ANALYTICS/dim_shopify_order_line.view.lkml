view: dim_shopify_order_line {
  sql_table_name: "FLEET_OPTIMIZATION"."GOLD"."DIM_SHOPIFY_ORDER_LINE" ;;


  dimension: inventory_item_id {
    type: number
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: name {
    type: string
    sql: ${TABLE}."NAME" ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: match_id {
    type: number
    sql: ${TABLE}."MATCH_ID" ;;
  }

  dimension: order_line_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."ORDER_LINE_ID" ;;
  }

  dimension: order_line_tax {
    type: number
    sql: ${TABLE}."ORDER_LINE_TAX" ;;
  }

  dimension: sales {
    type: number
    value_format_name: usd
    sql: ${TABLE}."POST_DISCOUNT_TOTAL_LINE_AMOUNT" ;;
  }

  dimension: product_id {
    type: number
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: fulfillment_method {
    type: string
    sql: iff(${TABLE}."FULFILLMENT_METHOD"='other', 'manually fulfilled items', ${TABLE}."FULFILLMENT_METHOD") ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}."SKU" ;;
  }

  dimension: variant_id {
    type: number
    sql: ${TABLE}."VARIANT_ID" ;;
  }

  dimension: troubleshooting {
    type: number
    sql: coalesce(${int_shopify_cost.cost}, ${int_inventory_item.current_product_cost}) ;;
  }

  dimension: line_item_cost {
    type: number
    value_format_name: usd
    sql: iff(${order_line_id} ilike '%r%', -${TABLE}.quantity * coalesce(${int_shopify_cost.cost}, ${int_inventory_item.current_product_cost}),${TABLE}.quantity * coalesce(${int_shopify_cost.cost}, ${int_inventory_item.current_product_cost})) ;;
  }

  dimension: margin {
    type: number
    value_format_name: usd
    sql: ${sales} - zeroifnull(${line_item_cost}) ;;
  }

  measure: aggro_cost {
    type: sum
    value_format_name: usd_0
    sql: zeroifnull(${line_item_cost}) ;;
    drill_fields: [aggro_drill*]
  }

  measure: aggro_revenue {
    type: sum
    value_format_name: usd_0
    sql: ${sales} ;;
    drill_fields: [aggro_drill*]
  }

  measure: aggro_margin {
    type: sum
    value_format_name: usd_0
    sql: ${margin} ;;
    drill_fields: [aggro_drill*]
  }

  measure: number_of_units_sold {
    type: sum
    sql: ${quantity} ;;
    drill_fields: [aggro_drill*]
  }

  measure: aggro_margin_percent {
    type: number
    value_format_name: percent_0
    sql: iff(round(${aggro_margin},0) = 0 and round(${aggro_cost},0) = 0, 0 ,${aggro_margin}/iff(${aggro_revenue} = 0, ${aggro_cost}, ${aggro_revenue})) ;;
    drill_fields: [aggro_drill*]
  }

  measure: average_sale_per_order {
    type: number
    value_format_name: usd
    sql: ${aggro_revenue}/ ${dim_shopify_order_header.total_orders} ;;
  }

  measure: average_cost_per_order {
    type: number
    value_format_name: usd
    sql: ${aggro_cost}/ ${dim_shopify_order_header.total_orders} ;;
  }

  set: aggro_drill {
    fields: [
      dim_shopify_order_header.order_number,
      name,
      sales,
      line_item_cost,
      quantity,
      dim_customers.customer_name,
      dim_shopify_order_header.order_created_date
    ]
  }
}
