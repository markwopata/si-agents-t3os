view: attachments {
  derived_table: {
    sql:
select il.INVENTORY_LOCATION_MARKET_ID
     , sp.STORE_PART_INVENTORY_LEVELS_KEY
     , part_id
     , PART_PROVIDER_NAME
     , PART_NUMBER
     , PART_NAME
     , sp.STORE_PART_INVENTORY_LEVELS_QUANTITY
--      , sp.STORE_PART_INVENTORY_LEVELS_AVAILABLE_QUANTITY
from FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT p
join PLATFORM.GOLD.FACT_STORE_PART_INVENTORY_LEVELS sp
    on p.PART_KEY = sp.STORE_PART_INVENTORY_LEVELS_PART_KEY
join PLATFORM.GOLD.DIM_INVENTORY_LOCATIONS il
    on sp.STORE_PART_INVENTORY_LEVELS_INVENTORY_LOCATION_KEY = il.INVENTORY_LOCATION_KEY
where PART_REPORTING_CATEGORY = 'bulk - attachments'
  and PART_PROVIDER_NAME not ilike '%telehandler%'

      ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  # dimension: store_part_id {
  #   primary_key: yes
  #   type: number
  #   sql: ${TABLE}."STORE_PART_ID" ;;
  # }

  dimension: store_part_key {
    primary_key: yes
    type: number
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_KEY" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  # dimension: quantity {
  #   type: number
  #   sql: ${TABLE}."QUANTITY" ;;
  # }

  dimension: quantity {
    type: number
    sql: ${TABLE}."STORE_PART_INVENTORY_LEVELS_QUANTITY" ;;
  }

  measure: total_quantity {
    type: sum
    sql: zeroifnull(${quantity}) ;;
    drill_fields: [market_id, part_id, part_number, total_quantity]
  }
}
