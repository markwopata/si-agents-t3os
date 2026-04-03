view: rentals_missing_attachments {

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
     , r.ORDER_ID
     , r.RENTAL_ID
     , START_DATE
     , END_DATE
from main_mover_pool mmp
left join PLATFORM.GOLD.DIM_ASSETS gda on mmp.ASSET_ID = gda.ASSET_ID
left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dmfo on gda.ASSET_RENTAL_MARKET_ID = dmfo.MARKET_ID
left join (select * from ES_WAREHOUSE.PUBLIC.RENTALS
            where not DELETED
                     and START_DATE::date <= current_date
                     and COALESCE(END_DATE, '2099-12-31')::date > current_date) r on mmp.ASSET_ID = r.ASSET_ID
where market_id <> -1
)

, att_summary as (
select il.INVENTORY_LOCATION_MARKET_ID as market_id
         , m.MARKET_NAME
         , il.INVENTORY_LOCATION_ID as store_id
         , il.INVENTORY_LOCATION_NAME as store_name
     , p.part_id
     , p.PART_NUMBER
     , p.PART_NAME as cat_class_name
     , PART_PROVIDER_NAME as cat_class_category_name
     , sum(zeroifnull(rpa.QUANTITY)) as on_rent_quantity
     , rpa.RENTAL_ID
     , rpa.order_id
from FLEET_OPTIMIZATION.GOLD.DIM_PARTS_FLEET_OPT p
join PLATFORM.GOLD.FACT_STORE_PART_INVENTORY_LEVELS sp
    on p.PART_KEY = sp.STORE_PART_INVENTORY_LEVELS_PART_KEY
join PLATFORM.GOLD.DIM_INVENTORY_LOCATIONS il
    on sp.STORE_PART_INVENTORY_LEVELS_INVENTORY_LOCATION_KEY = il.INVENTORY_LOCATION_KEY
join fleet_optimization.gold.dim_markets_fleet_opt m
    on il.INVENTORY_LOCATION_MARKET_ID = m.MARKET_ID
left join (select o.MARKET_ID, o.ORDER_ID, rpa.* from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
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
     , rpa.RENTAL_ID
     , rpa.ORDER_ID
)

, aggregate as (
select dmfo.MARKET_NAME
     , dmfo.MARKET_ID
     , dmfo.MARKET_DISTRICT
     , dmfo.MARKET_REGION_NAME
     , ms.ORDER_ID
     , ms.rental_id
     , ms.ASSET_ID
     , ms.ASSET_CURRENT_OEC
     , ms.ASSET_EQUIPMENT_MAKE
     , ms.ASSET_EQUIPMENT_MODEL_NAME
     , ms.ASSET_EQUIPMENT_CLASS_NAME
     , ms.ASSET_EQUIPMENT_SUBCATEGORY_NAME
     , ms.ASSET_EQUIPMENT_CATEGORY_NAME
     , ats.rental_contract_list as att_rentals
     , earliest_start
     , latest_end
from FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dmfo
join analytics.public.ES_COMPANIES ec on dmfo.MARKET_COMPANY_ID = ec.COMPANY_ID and ec.owned
left join (select market_id
                , ORDER_ID
                , RENTAL_ID
                , ASSET_ID
     , ASSET_CURRENT_OEC
     , ASSET_EQUIPMENT_MAKE
     , ASSET_EQUIPMENT_MODEL_NAME
     , ASSET_EQUIPMENT_CLASS_NAME
     , ASSET_EQUIPMENT_SUBCATEGORY_NAME
     , ASSET_EQUIPMENT_CATEGORY_NAME
                --, listagg(RENTAL_ID, ', ') as rental_contract_list
                , min(START_DATE)::date as earliest_start
                , max(END_DATE)::date as latest_end
                , count(zeroifnull(asset_id)) as mm_number
                , sum(zeroifnull(on_rent)) as on_rent_number
        from mm_summary group by market_id, order_id, rental_id, ASSET_ID
     , ASSET_CURRENT_OEC
     , ASSET_EQUIPMENT_MAKE
     , ASSET_EQUIPMENT_MODEL_NAME
     , ASSET_EQUIPMENT_CLASS_NAME
     , ASSET_EQUIPMENT_SUBCATEGORY_NAME
     , ASSET_EQUIPMENT_CATEGORY_NAME) ms on dmfo.MARKET_ID = ms.MARKET_ID
left join (select MARKET_ID
                , order_id
                --, rental_id
                , listagg(rental_id, ', ') as rental_contract_list
--                 , sum(zeroifnull(inventory_quantity)) as att_number
                , sum(zeroifnull(on_rent_quantity)) as on_rent_number
            from att_summary group by market_id, order_id) ats on dmfo.MARKET_ID = ats.MARKET_ID and ms.ORDER_ID = ats.ORDER_ID
where MARKET_REGION_NAME != 'Default Region - Missing Value'
-- and MARKET_REGION_NAME ilike 'mountain%west'
and ms.order_id is not null)

select c.COMPANY_NAME as customer_name
     , a.MARKET_NAME
     , a.MARKET_ID
     , a.MARKET_DISTRICT
     --, a.ORDER_ID
     , a.rental_id
     , a.ASSET_ID
     , a.ASSET_CURRENT_OEC
     , a.ASSET_EQUIPMENT_MAKE
     , a.ASSET_EQUIPMENT_MODEL_NAME
     , a.ASSET_EQUIPMENT_CLASS_NAME
     , a.ASSET_EQUIPMENT_SUBCATEGORY_NAME
     , a.ASSET_EQUIPMENT_CATEGORY_NAME
     , a.earliest_start
     , a.latest_end
from aggregate a
join ES_WAREHOUSE.PUBLIC.ORDERS o on a.ORDER_ID = o.ORDER_ID
join FLEET_OPTIMIZATION.GOLD.DIM_COMPANIES_FLEET_OPT c on o.COMPANY_ID = c.COMPANY_ID
where a.att_rentals is null
order by MARKET_DISTRICT, MARKET_NAME
      ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: market_id {
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

  dimension: customer_name {
    type: string
    sql: ${TABLE}."CUSTOMER_NAME" ;;
  }

  dimension: rental_id {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: rental_id_with_link {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_ID" ;;
    html:  <a href="https://admin.equipmentshare.com/#/home/rentals/{{ rental_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ rental_id._value }}</a> ;;
  }

  dimension: rental_contract_url_text {
    label: "Rental URL"
    type: string
    sql: CONCAT('https://admin.equipmentshare.com/#/home/rentals/', ${rental_id}) ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: equipment_class_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CLASS_NAME" ;;
  }

  dimension: equipment_subcategory_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_SUBCATEGORY_NAME" ;;
  }

  dimension: equipment_category_name {
    type: string
    sql: ${TABLE}."ASSET_EQUIPMENT_CATEGORY_NAME" ;;
  }

  measure: rental_contract_count {
    type: count
    drill_fields: [market_name
                  , customer_name
                  , equipment_class_name
                  , equipment_subcategory_name
                  , equipment_category_name
                  , rental_id_with_link
                  , rental_contract_url_text]
  }

  # measure: distinct_rental_contract_count {
  #   type: count_distinct
  #   sql: ${rental_id} ;;
  # }

  # dimension: main_mover_count {
  #   type: number
  #   sql: ${TABLE}."NUMBER_OF_MM" ;;
  # }

  # dimension: main_mover_on_rent_count {
  #   type: number
  #   sql: ${TABLE}."NUMBER_OF_MM_ON_RENT" ;;
  # }

  # dimension: attachment_count {
  #   type: number
  #   sql: ${TABLE}."NUMBER_OF_ATT" ;;
  # }

  # dimension: attachment_on_rent_count {
  #   type: number
  #   sql: ${TABLE}."NUMBER_OF_ATT_ON_RENT" ;;
  # }

  # measure: percent_total_attachments_in_T3 {
  #   type: number
  #   value_format_name: percent_4
  #   sql: sum(${attachment_count})/sum(${main_mover_count});;
  # }

  # measure: percent_rental_contracts_with_attachments {
  #   type: number
  #   value_format_name: percent_4
  #   sql: zeroifnull(iff(sum(${main_mover_on_rent_count})=0,0,sum(${attachment_on_rent_count})/sum(${main_mover_on_rent_count}))) ;;
  # }

}
