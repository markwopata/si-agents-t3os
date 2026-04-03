view: wos_needed_for_rentals {
  derived_table: {
    sql: with upcoming_deliveries as(
  SELECT r.rental_id,
         ec.equipment_class_id,
         ec.name    AS equipment_class,
         o.market_id,
         CONVERT_TIMEZONE('UTC', 'America/Denver', d.scheduled_date::timestamp)                 AS delivery_date,
rank() over (partition by ec.equipment_class_id, o.market_id order by delivery_date,r.rental_id asc) date_rank
    FROM es_warehouse.public.rentals AS r
             LEFT JOIN es_warehouse.public.orders AS o
             ON r.order_id = o.order_id
             LEFT JOIN es_warehouse.public.deliveries AS d
             ON r.drop_off_delivery_id = d.delivery_id
             LEFT JOIN es_warehouse."PUBLIC".equipment_classes AS ec
             ON r.equipment_class_id = ec.equipment_class_id
where r.asset_id is null and delivery_date>=current_date and equipment_class is not null
and r.rental_status_id in(1,2,3,4)
order by ec.equipment_class_id, o.market_id, delivery_date asc)

, assets_needed as (
select market_id
, equipment_class_id
, equipment_class
, count(rental_id) assets_needed
, min(delivery_date) first_needed --take this date out?
from upcoming_deliveries
group by market_id, equipment_class_id, equipment_class)

,  assets_available as(
SELECT AA.RENTAL_BRANCH_ID market_id
  ,AA.EQUIPMENT_CLASS_ID
  , count(aa.asset_id) assets_available
FROM ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AS AA
LEFT JOIN ES_WAREHOUSE.PUBLIC.ASSET_STATUS_KEY_VALUES AS ASKV
ON AA.ASSET_ID = ASKV.ASSET_ID
WHERE lower(ASKV.NAME) LIKE '%asset_inventory_status%'
AND AA.COMPANY_ID IN (select COMPANY_ID
                    FROM ES_WAREHOUSE.public.companies
                    WHERE name regexp 'IES\\d+ .*'  -- captures all IES# company_ids
                    OR COMPANY_ID = 420          -- Demo Units
                    OR COMPANY_ID = 62875        -- ES Owned special events - still owned by us
                    OR COMPANY_ID in (1854, 1855) -- ES Owned
                    OR COMPANY_ID = 61036        -- ES Owned - Trekker Temporary Holding
               --CONTRACTOR OWNED/OWN PROGRAM
                    OR COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
                                      FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
                                      JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
                                          ON VPP.ASSET_ID = AA.ASSET_ID
                                      WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
                                        AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))
AND ASKV.VALUE='Ready To Rent'
  group by aa.rental_branch_id, equipment_class_id
)

select  wo.*
, aa.make
, aa.model
, aa.class
, aa.equipment_class_id
, an.equipment_class
, coalesce(assets_available,0) assets_available
, assets_needed
, first_needed
, delivery_date
, assets_needed-assets_available assets_still_needed
, wo.branch_id||aa.equipment_class_id market_class_id
from "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS" wo
join "ES_WAREHOUSE"."PUBLIC"."ASSETS_AGGREGATE" aa
on wo.asset_id=aa.asset_id
join assets_needed an
on wo.branch_id=an.market_id
and aa.equipment_class_id=an.equipment_class_id
left join assets_available av
on wo.branch_id=av.market_id
and aa.equipment_class_id=av.equipment_class_id
join upcoming_deliveries ud
on wo.branch_id=ud.market_id
and aa.equipment_class_id=ud.equipment_class_id
and (assets_available+1)=ud.date_rank
where date_completed is null and archived_Date is null
and aa.company_id IN (select COMPANY_ID
                    FROM ES_WAREHOUSE.public.companies
                    WHERE name regexp 'IES\\d+ .*'  -- captures all IES# company_ids
                    OR COMPANY_ID = 420          -- Demo Units
                    OR COMPANY_ID = 62875        -- ES Owned special events - still owned by us
                    OR COMPANY_ID in (1854, 1855) -- ES Owned
                    OR COMPANY_ID = 61036        -- ES Owned - Trekker Temporary Holding
               --CONTRACTOR OWNED/OWN PROGRAM
                    OR COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
                                      FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
                                      JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
                                          ON VPP.ASSET_ID = AA.ASSET_ID
                                      WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
                                        AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))
                      and (assets_available<assets_needed or assets_available is null)
order by wo.branch_id, equipment_class_id, first_needed asc   ;;
  }
  dimension: work_order_id {
    type: string
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}.description ;;
  }

  dimension: asset_id {
    type: string
    sql: ${TABLE}.asset_id ;;
  }

  dimension: severity_level {
    type: string
    sql: ${TABLE}.severity_level_name ;;
  }

  dimension: work_order_type {
    type: string
    sql: ${TABLE}.work_order_type_name ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw,date,week,month,year]
    sql: ${TABLE}.date_created ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [raw,date,week,month,year]
    sql: ${TABLE}.date_completed ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}.branch_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }

  dimension: equipment_class {
    type: string
    sql: ${TABLE}.equipment_class ;;
  }

  dimension: equipment_class_id {
    type: string
    sql: ${TABLE}.equipment_class_id ;;
  }

  dimension_group: first_needed {
    type: time
    timeframes: [raw,date,week,month,year]
    sql: ${TABLE}.first_needed ;;
  }

  dimension_group: next_needed {
    type: time
    timeframes: [raw,date,week,month,year]
    sql: ${TABLE}.delivery_date ;;
  }

  dimension: assets_needed {
    type: number
    sql: ${TABLE}.assets_needed ;;
  }

  dimension: assets_available {
    type: number
    sql: ${TABLE}.assets_available ;;
  }

dimension: assets_still_needed {
  type: number
  sql: ${TABLE}.assets_still_needed ;;
}
dimension: market_class_id {
  type:  string
  sql: ${TABLE}.market_class_id ;;
}
measure: distinct_assets_needed {
  type: sum_distinct
  sql_distinct_key: ${market_class_id} ;;
  sql: ${assets_still_needed} ;;
  drill_fields: [market_region_xwalk.market_name, date_created_date,work_order_id,work_order_type,severity_level,description,asset_id,equipment_class,assets_needed,assets_available,assets_still_needed,first_needed_date,next_needed_date]
}
}
