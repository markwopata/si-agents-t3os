view: attachments_history {
  derived_table: {
    sql:

select il.INVENTORY_LOCATION_MARKET_ID
     , ibs.STORE_PART_ID
     , p.part_id
     , p.PART_PROVIDER_NAME
     , p.PART_NUMBER
     , p.PART_NAME
     , ibs.QUANTITY
    , ibs.timestamp::date as dt_date
, concat_ws('-', ibs.STORE_PART_ID, ibs.TIMESTAMP::date) as unique_key
from FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT p
join PLATFORM.GOLD.FACT_STORE_PART_INVENTORY_LEVELS sp
    on p.PART_KEY = sp.STORE_PART_INVENTORY_LEVELS_PART_KEY
join PLATFORM.GOLD.DIM_INVENTORY_LOCATIONS il
    on sp.STORE_PART_INVENTORY_LEVELS_INVENTORY_LOCATION_KEY = il.INVENTORY_LOCATION_KEY
join analytics.public.INVENTORY_BALANCES_SNAPSHOT ibs
    on p.PART_ID = ibs.PART_ID
    and il.inventory_location_id = ibs.STORE_ID
 where TIMESTAMP::date >= '2025-01-01'
        and hour(TIMESTAMP) = 23
  and p.PART_REPORTING_CATEGORY = 'bulk - attachments'
  and PART_PROVIDER_NAME not ilike '%telehandler%'
      ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_LOCATION_MARKET_ID" ;;
  }

  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: part_provider_name {
    type: string
    sql: ${TABLE}."PART_PROVIDER_NAME" ;;
  }

  dimension: si_67_part_provider_name {
    hidden: yes
    type: string
    sql: iff(${TABLE}."PART_PROVIDER_NAME" = 'BULK - BUCKET MINI TRACK LOADER', 'BULK - BUCKET MINI-TRACK-LOADER' , ${TABLE}."PART_PROVIDER_NAME") ;;
  }

  dimension: quantity {
    type: number
    sql: zeroifnull(${TABLE}."QUANTITY") ;;
  }

  dimension: dt_date {
    type: date
    sql: ${TABLE}."DT_DATE" ;;
  }

  dimension: unique_key {
    primary_key: yes
    type: string
    sql: ${TABLE}."UNIQUE_KEY" ;;
  }

  measure: total_quantity {
    type: sum
    sql: zeroifnull(${quantity}) ;;
    drill_fields: [market_id, part_id, part_number, total_quantity]
  }
}
