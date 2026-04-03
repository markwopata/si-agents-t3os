view: main_movers_history {
  derived_table: {
    sql:

    select a.asset_id
     , a.ASSET_CURRENT_OEC
     , a.ASSET_COMPANY_ID
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
     , rsp.rental_branch_id
     , ddfo.DT_DATE
     , concat_ws('-', a.ASSET_ID, rsp.RENTAL_BRANCH_ID, ddfo.DT_DATE) as unique_key
from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
join FLEET_OPTIMIZATION.GOLD.dim_asset_rsp_pit rsp on a.asset_id = rsp.ASSET_ID
join FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT ddfo
    on ddfo.DT_DATE between rsp.START_WINDOW and rsp.END_WINDOW
where mm_type != 'Other'
  and ddfo.dt_date <= current_date()
  ;;
  }

  dimension: asset_id {
    type: number
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: main_mover_type {
    type: string
    sql: ${TABLE}."MM_TYPE" ;;
  }

  dimension: rental_branch_id {
    type: number
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
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

  measure: asset_count {
    type: count
    drill_fields: [rental_branch_id, main_mover_type, asset_count]
  }
}
