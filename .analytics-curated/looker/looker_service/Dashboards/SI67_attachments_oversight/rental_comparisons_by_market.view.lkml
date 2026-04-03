view: rental_comparisons_by_market {

  derived_table: {
    sql:


    with main_mover_pool as (select asset_id
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
             when a.asset_equipment_subcategory_name in ('Telehandlers', 'High Reach Telehandlers') then 'Telehandler' -- provider name contains telehandler
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME in ('Rotating Telehandlers') then 'Rotating Telehandler' -- provider name contains rotator
             when a.ASSET_EQUIPMENT_SUBCATEGORY_NAME in ('Rough Terrain Forklifts', 'Forklifts, Reach Trucks & Stand-Ons', 'High Capacity Industrial Forklifts', 'Industrial Forklifts') then 'Forklift' -- everything else not covered specifically
             else 'Other' end                                 as mm_type
from FLEET_OPTIMIZATION.GOLD.DIM_ASSETS_FLEET_OPT a
where mm_type != 'Other')
, mm_summary as
(select mmp.ASSET_ID
     , gda.ASSET_CURRENT_OEC
     , gda. ASSET_EQUIPMENT_MAKE
     , gda.ASSET_EQUIPMENT_MODEL_NAME
     , ASSET_EQUIPMENT_CLASS_NAME
     , ASSET_EQUIPMENT_SUBCATEGORY_NAME
     , ASSET_EQUIPMENT_CATEGORY_NAME
     , dmfo.MARKET_ID
     , dmfo.MARKET_NAME
     , dmfo.MARKET_DISTRICT
     , iff(r.asset_id is null, 0, 1) as on_rent
from main_mover_pool mmp
left join PLATFORM.GOLD.DIM_ASSETS gda on mmp.ASSET_ID = gda.ASSET_ID
left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dmfo on gda.ASSET_RENTAL_MARKET_ID = dmfo.MARKET_ID
left join (select * from ES_WAREHOUSE.PUBLIC.RENTALS
            where not DELETED
                     and START_DATE::date <= current_date
                     and COALESCE(END_DATE, '2099-12-31')::date > current_date) r on mmp.ASSET_ID = r.ASSET_ID
where market_id <> -1)

, att_summary as (
select il.INVENTORY_LOCATION_MARKET_ID as market_id
         , m.MARKET_NAME
         , il.INVENTORY_LOCATION_ID as store_id
         , il.INVENTORY_LOCATION_NAME as store_name
     , p.part_id
     , p.PART_NUMBER
     , p.PART_NAME as cat_class_name
     , PART_PROVIDER_NAME as cat_class_category_name
     , zeroifnull(wacs.WEIGHTED_AVERAGE_COST) as replacement_cost
     , sp.STORE_PART_INVENTORY_LEVELS_QUANTITY as inventory_quantity
     , sum(zeroifnull(rpa.QUANTITY)) as on_rent_quantity
     , replacement_cost * inventory_quantity as inventory_total
     , replacement_cost * on_rent_quantity as on_rent_total
from FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT p
join PLATFORM.GOLD.FACT_STORE_PART_INVENTORY_LEVELS sp
    on p.PART_KEY = sp.STORE_PART_INVENTORY_LEVELS_PART_KEY
join PLATFORM.GOLD.DIM_INVENTORY_LOCATIONS il
    on sp.STORE_PART_INVENTORY_LEVELS_INVENTORY_LOCATION_KEY = il.INVENTORY_LOCATION_KEY
join fleet_optimization.gold.dim_markets_fleet_opt m
    on il.INVENTORY_LOCATION_MARKET_ID = m.MARKET_ID
left join es_warehouse.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS wacs
    on il.INVENTORY_LOCATION_ID = wacs.INVENTORY_LOCATION_ID
           and p.PART_ID = wacs.PRODUCT_ID
           and IS_CURRENT
left join (select o.MARKET_ID, rpa.* from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
                        join ES_WAREHOUSE.PUBLIC.RENTALS r on rpa.RENTAL_ID = r.RENTAL_ID
                        join ES_WAREHOUSE.PUBLIC.ORDERS o on r.ORDER_ID = o.order_id
                        where not r.DELETED
                          and rpa.START_DATE::date <= current_date
                          and COALESCE(rpa.END_DATE, '2099-12-31')::date > current_date
                        ) rpa on p.PART_ID = rpa.PART_ID
                                     and il.INVENTORY_LOCATION_MARKET_ID = rpa.MARKET_ID

where PART_REPORTING_CATEGORY = 'bulk - attachments'

group by il.INVENTORY_LOCATION_MARKET_ID
         , m.MARKET_NAME
         , il.INVENTORY_LOCATION_ID
         , il.INVENTORY_LOCATION_NAME
     , p.part_id
     , p.PART_NUMBER
     , p.PART_NAME
     , PART_PROVIDER_NAME
     , zeroifnull(wacs.WEIGHTED_AVERAGE_COST)
     , sp.STORE_PART_INVENTORY_LEVELS_QUANTITY
)

select dmfo.MARKET_NAME
     , dmfo.MARKET_ID
     , dmfo.MARKET_DISTRICT
     , dmfo.MARKET_REGION_NAME
     , ms.mm_number as number_of_mm
     , ms.on_rent_number as number_of_mm_on_rent
     , ats.att_number as number_of_att
     , ats.on_rent_number as number_of_att_on_rent
     , round(number_of_att / number_of_mm,4)*100 as percent_total_attachments_in_T3
     , round(iff(number_of_mm_on_rent = 0, 0, number_of_att_on_rent / number_of_mm_on_rent),4)*100 as percent_MM_rental_contracts_with_attachments
from FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dmfo
join analytics.public.ES_COMPANIES ec on dmfo.MARKET_COMPANY_ID = ec.COMPANY_ID and ec.owned
left join (select market_id
                , count(zeroifnull(asset_id)) as mm_number
                , sum(zeroifnull(on_rent)) as on_rent_number
        from mm_summary group by market_id) ms on dmfo.MARKET_ID = ms.MARKET_ID
left join (select MARKET_ID
                , sum(zeroifnull(inventory_quantity)) as att_number
                , sum(zeroifnull(on_rent_quantity)) as on_rent_number
            from att_summary group by market_id) ats on dmfo.MARKET_ID = ats.MARKET_ID
where MARKET_REGION_NAME != 'Default Region - Missing Value'


      ;;
  }

dimension: market_name {
  type: string
  sql: ${TABLE}."MARKET_NAME" ;;
}

dimension: market_id {
  primary_key: yes
  type: number
  value_format_name: id
  sql: ${TABLE}."MARKET_ID" ;;
}

dimension: district {
  type: string
  sql: ${TABLE}."MARKET_DISTRICT" ;;
}

dimension: region {
  type: string
  sql: ${TABLE}."MARKET_REGION_NAME" ;;
}

dimension: main_mover_count {
  type: number
  sql: ${TABLE}."NUMBER_OF_MM" ;;
}

dimension: main_mover_on_rent_count {
  type: number
  sql: ${TABLE}."NUMBER_OF_MM_ON_RENT" ;;
}

dimension: attachment_count {
  type: number
  sql: ${TABLE}."NUMBER_OF_ATT" ;;
}

dimension: attachment_on_rent_count {
  type: number
  sql: ${TABLE}."NUMBER_OF_ATT_ON_RENT" ;;
}

measure: percent_total_attachments_in_T3 {
  type: number
  value_format_name: percent_4
  sql: sum(${attachment_count})/sum(${main_mover_count});;
}

measure: percent_rental_contracts_with_attachments {
  type: number
  value_format_name: percent_4
  sql: zeroifnull(iff(sum(${main_mover_on_rent_count})=0,0,sum(${attachment_on_rent_count})/sum(${main_mover_on_rent_count}))) ;;
}

}
