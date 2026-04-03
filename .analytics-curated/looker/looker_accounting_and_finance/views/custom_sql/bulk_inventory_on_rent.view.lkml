view: bulk_inventory_on_rent {

  derived_table: {
    sql:
    with prep_store_part_cost as (
    select STORE_PART_ID
         , STORE_PART_COST_ID
         , COST
         , DATE_ARCHIVED
         , DATE_CREATED
         , coalesce(lag(DATE_ARCHIVED::timestamp_ntz)
                        over (partition by STORE_PART_ID order by date_archived, STORE_PART_COST_ID),
                    0::timestamp_ntz)::timestamp_ntz                           as date_start
         , coalesce(DATE_ARCHIVED::timestamp_ntz, '2099-12-31'::timestamp_ntz) as date_end
    from ES_WAREHOUSE.INVENTORY.STORE_PART_COSTS
    order by STORE_PART_ID, STORE_PART_COST_ID
)
select r.RENTAL_ID
     , r.RENTAL_TYPE_ID
     , o.ORDER_ID
     , o.MARKET_ID
     , m.NAME                  as               market_name
     , pt.PART_TYPE_ID
     , pt.DESCRIPTION
     , c.COMPANY_ID
     , c.NAME                  as               renting_company_name
     , sp.STORE_PART_ID
     , coalesce(p2.part_id, p1.PART_ID)         part_id
     , coalesce(p2.part_number, p1.part_number) part_number
     , rpa.QUANTITY
     , spc.COST
     , sp.STORE_ID
     , rpa.QUANTITY * spc.COST as               total_cost,
       rpa.START_DATE::date as start_date,
       coalesce(rpa.END_DATE::date,'2099-12-31'::date) as end_date
from ES_WAREHOUSE.PUBLIC.RENTAL_PART_ASSIGNMENTS rpa
         join ES_WAREHOUSE.PUBLIC.RENTALS r
              on rpa.RENTAL_ID = r.RENTAL_ID
         join ES_WAREHOUSE.PUBLIC.ORDERS o
              on r.ORDER_ID = o.ORDER_ID
         join ES_WAREHOUSE.PUBLIC.USERS u
              on o.USER_ID = u.USER_ID
         join ES_WAREHOUSE.PUBLIC.COMPANIES c
              on c.COMPANY_ID = u.COMPANY_ID
         join ES_WAREHOUSE.PUBLIC.MARKETS m
              on o.MARKET_ID = m.MARKET_ID -- Only uninvoiced, so use orders.market_id
         join ES_WAREHOUSE.INVENTORY.STORES s
              on o.MARKET_ID = s.BRANCH_ID -- Pat confirmed 10/15/21 that you can't rent out of a store that doesn't
    -- have a branch. There aren't any instances of a single branch with multiple stores right now.
    -- https://equipmentshare.slack.com/archives/G01GLQE2G3C/p1634323619052600 <Mark,Paul,Vishesh>
         join ES_WAREHOUSE.INVENTORY.PARTS p1
              on rpa.part_id = p1.part_id
         left join es_warehouse.INVENTORY.parts p2 -- In case the p1 part refers to a part that was MergePart'ed
                   on p1.DUPLICATE_OF_ID = p2.part_id
         join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
              on s.store_id = sp.STORE_ID
                  and sp.PART_ID = coalesce(p2.part_id, p1.part_id)
         join prep_store_part_cost spc
              on sp.STORE_PART_ID = spc.STORE_PART_ID
                  and rpa.start_date >= spc.date_start
                  and rpa.start_date < spc.date_end
         join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
              on pt.PART_TYPE_ID = coalesce(p2.PART_TYPE_ID, p1.PART_TYPE_ID)
where last_day(add_months(current_timestamp::date,-1)) between rpa.START_DATE and coalesce(rpa.END_DATE, '2099-12-31'::DATE)
                                   ;;
  }

  dimension: rental_id {
    type: string
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: rental_type_id {
    type: string
    sql: ${TABLE}."RENTAL_TYPE_ID" ;;
  }

  dimension: order_id {
    type: string
    sql: ${TABLE}."ORDER_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: part_type_id {
    type: string
    sql: ${TABLE}."PART_TYPE_ID" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: renting_company_name {
    type: string
    sql: ${TABLE}."RENTING_COMPANY_NAME" ;;
  }

  dimension: store_part_id {
    type: string
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension: store_id {
    type: string
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: total_cost {
    type: number
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  dimension: start_date {
    type: date
    sql: ${TABLE}."START_DATE" ;;
  }

  dimension: end_date {
    type: date
    sql: ${TABLE}."END_DATE" ;;
  }

  }
