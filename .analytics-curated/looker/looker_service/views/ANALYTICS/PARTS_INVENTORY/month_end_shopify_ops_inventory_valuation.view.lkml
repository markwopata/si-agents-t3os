view: month_end_shopify_ops_inventory_valuation {
  derived_table: {
    sql:
    select sois.INVENTORY_ITEM_ID
     , sois.PRODUCT_VARIANT_ID
     , sois.PRODUCT_ID
     , sois.status
     , sois.VENDOR
     , sois.sku
     , p.title
     , p.PRODUCT_TYPE
     , sois.UNIT_COST_AMOUNT
     , sois.TOTAL_QUANTITY
     , round(zeroifnull(sois.UNIT_COST_AMOUNT)*zeroifnull(sois.TOTAL_QUANTITY),2) as total_in_inventory
     , sois.LOCATION_NAME
     , sois.SNAPSHOT_MONTH
from ANALYTICS.PARTS_INVENTORY.SHOPIFY_OPS_INVENTORY_SNAPSHOT sois
left join analytics.SHOPIFY.PRODUCT p
    on sois.PRODUCT_ID = p.ID
where sois.status ilike 'active'
and total_in_inventory != 0
and not sois.DIAGNOSTIC
and not sois.ADMIN_ASSET
      ;;
  }


  dimension: inventory_item_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_ITEM_ID" ;;
  }

  dimension: product_variant_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PRODUCT_VARIANT_ID" ;;
  }

  dimension: product_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PRODUCT_ID" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: sku {
    type: string
    sql: ${TABLE}."SKU" ;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}."TITLE" ;;
  }

  dimension: product_type {
    type: string
    sql: ${TABLE}."PRODUCT_TYPE" ;;
  }

  dimension: unit_cost_amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."UNIT_COST_AMOUNT" ;;
  }

  dimension: total_quantity {
    type: number
    sql: ${TABLE}."TOTAL_QUANTITY" ;;
  }

  dimension: total_in_inventory {
    type: number
    value_format_name: usd
    sql: ${TABLE}."TOTAL_IN_INVENTORY" ;;
  }

  dimension: location_name {
    type: string
    sql: ${TABLE}."LOCATION_NAME" ;;
  }

  dimension_group: snapshot_month {
    type: time
    timeframes: [date, week, month, year]
    sql: ${TABLE}."SNAPSHOT_MONTH" ;;
  }
}
