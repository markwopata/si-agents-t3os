view: main_movers {

  derived_table: {
    sql:


    select asset_id
     , ASSET_CURRENT_OEC
     , ASSET_COMPANY_ID
     , ASSET_RENTAL_MARKET_ID
       , case -- more detail in 2025-09-08 scratch.sql
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME in
                  ('Skid Steers', 'Compact Track Loaders', 'Wheeled Skid Loaders')
                 then 'Track Loader' -- provider name contains track loader
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME = 'Mini Skid Steers' then 'Mini Track Loader' -- provider name contains mini track loader
             when (a.ASSET_EQUIPMENT_SUBCATEGORY_NAME = 'Wheel Loaders' or a.EQUIPMENT_CLASS_ID = '5689')
                 then 'Wheel Loader or Track High Loader' -- provider name contains wheel loader
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME = 'Track High Loaders' then 'Wheel Loader or Track High Loader' -- provider name contains wheel loader
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME = 'Track Excavators' then 'Track Excavator' -- provider name contains track excavator
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME = 'Mini Excavators' then 'Mini Excavator or Backhoe' -- provider name contains mini excavator
             when (a.ASSET_EQUIPMENT_SUBCATEGORY_NAME = 'Backhoes and Skip Loaders' and
                   try_to_number(a.EQUIPMENT_CLASS_ID) != 528) then 'Mini Excavator or Backhoe' -- provider name contains mini excavator (shares with mini excavators)
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME in ('Rotating Telehandlers') then 'Rotating Telehandler' -- provider name contains rotator
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME in ('Rough Terrain Forklifts', 'Forklifts, Reach Trucks & Stand-Ons', 'High Capacity Industrial Forklifts', 'Industrial Forklifts') then 'Forklift' -- everything else not covered specifically
             else 'Other' end                                 as mm_type
from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
where mm_type != 'Other'

;;
    }

  dimension: asset_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: OEC {
    type: number
    value_format_name: usd
    sql: ${TABLE}."ASSET_CURRENT_OEC" ;;
  }

  dimension: company_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_COMPANY_ID" ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_RENTAL_MARKET_ID" ;;
  }

  dimension: main_mover_type {
    type: string
    sql: ${TABLE}."MM_TYPE" ;;
  }

  measure: asset_count {
    type: count
    drill_fields: [market_id, main_mover_type, asset_count]
  }

    }
