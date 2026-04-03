view: lost_revenue_vendor_level {
    derived_table: { #https://gitlab.internal.equipmentshare.com/business-intelligence/ba-part-analytics/-/blob/main/Adhoc/Backordered%20Parts%20LR/Recs.sql
      sql: with granular as ( -- Accepted quanitity of parts at the receiver level. Unique at the receiver level.
    select  po.purchase_order_number
        , li.purchase_order_line_item_id
        , r.purchase_order_receiver_id
        , ri.purchase_order_receiver_item_id --unique
        , po.date_created
        , r.date_received
        , datediff(days,po.date_created,r.date_received) lead_time
        , li.price_per_unit
        , ri.accepted_quantity
        , p.master_part_id as part_id
        , p.part_number
        , pt.description
        , pr.name provider
        , e.name vendor
        , evs.EXTERNAL_ERP_VENDOR_REF as vendorid
    from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
    left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
        on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
        on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
    join ES_WAREHOUSE.INVENTORY.PARTS p1
        on li.item_id = p1.item_id
    join ANALYTICS.PARTS_INVENTORY.PARTS p
        on p1.part_id = p.part_id
    left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
        on p.provider_id = pr.provider_id
    join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
        on p.PART_TYPE_ID = pt.PART_TYPE_ID
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
        on r.purchase_order_id=po.purchase_order_id
    left JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITIES" e
        on po.vendor_ID = e.entity_ID
    left JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" evs
        on e.entity_ID = evs.entity_id
    where po.purchase_order_number != 321858 --obvious mistake
        and to_date(po.date_created) >= '2023-01-01'
        and lead_time >= 0
        and po.date_archived is null
        and li.date_archived is null
)

, parts_sum as (
    select part_id
        , part_number
        , description
        , provider
        , avg(lead_time) avg_part_delay
        , avg(price_per_unit) avg_price
        , sum(accepted_quantity)
        , count(purchase_order_number)
    from granular
    where not (description ILIKE ANY('%filter%','%oil%','%15W%','%Decal%','%Grease%'))
    group by part_id
        , part_number
        , description
        , provider
)

, part_details as ( --work order parts where on average the part goes on back order
    select pit.work_order_id wo_id
        , pit.root_part_id as part_id
        , sum(-pit.quantity) as parts_quantity
        , ps.part_number
        , ps.description
        , ps.provider
        , ps.avg_part_delay
        , ps.avg_price
    from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
    join parts_sum ps
        on pit.root_part_id = ps.part_id
    where transaction_type_id in (7,9)
        and wo_id is not null
        and avg_part_delay >= 7 --back order
    group by wo_id
        , pit.root_part_id
        , ps.part_number
        , ps.description
        , ps.provider
        , ps.avg_part_delay
        , ps.avg_price
)

, base as ( --every rental period for every asset
    select concat(asset_id || date_end) period_id
        , asset_id
        , asset_inventory_status
        , date_start
        , date_end return_date
        , lead(date_start) over (partition by asset_id order by date_start) next_rental --do we want to include stuff without a next rental or not?
    from "ES_WAREHOUSE"."SCD"."SCD_ASSET_INVENTORY_STATUS"
    where asset_inventory_status = 'On Rent'
        -- and asset_id =10141 --marks example asset
    order by date_start
)

, own as (
    select aa.asset_id, vpp.start_date, coalesce(vpp.end_date, '2099-12-31') as end_date
    from ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    join ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS vpp
        on vpp.asset_id = aa.asset_id
)

, es as (
    select aa.asset_id, scd.date_start start_date, scd.date_end end_date --all assets owned by es at the end of the year
    from ES_WAREHOUSE.SCD.SCD_ASSET_COMPANY scd
    join ANALYTICS.PUBLIC.ES_COMPANIES esc
        on esc.company_id = scd.company_id
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on scd.asset_id = aa.asset_id
    where esc.owned = true
)

, wo_days as ( --General Work Orders that fall between rentals
    select b.period_id
        , b.asset_id
        , return_date
        , b.next_rental
        , work_order_id wo_id
        , severity_level_name severity
        , date_created
        , date_completed
        , datediff(days, date_created, date_completed) wo_duration
        , sum(datediff(days, date_created, date_completed)) over (partition by b.period_id) period_wo_duration_overlap --total amount of work order days between rentals
    from base b
    join "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS" wo
        on b.asset_id = wo.asset_id
        and wo.date_created between return_date and next_rental
    left join own
        on own.asset_id = wo.asset_id
            and own.start_date <= wo.date_created
            and own.end_date > wo.date_updated
    left join es
        on es.asset_id = wo.asset_id
            and es.start_date <= wo.date_created
            and es.end_date > wo.date_created
    where b.next_rental is not null
        and (severity ='Hard Down' or severity ='Soft Down') --soft down was not originally included due to them still be available for rent
        and work_order_type_name = 'General'
        and archived_date is null
        and year(date_created)>=2021
        and year(date_completed)>=2021
        and coalesce(es.asset_id, own.asset_id) is not null
    order by return_date, asset_id
)

, duration as ( --total work order duration per off rent period
    select period_id
        , min(date_created)
        , max(date_completed) as filter_date
        , datediff(days,min(date_created),max(date_completed)) period_wo_duration
    from wo_days d
    group by period_id
    having period_wo_duration > 0
)

, asset_status as ( --connecting work orders to the total wo days in that peiod and parts that are on back order on average
    select w.*
        , d.period_wo_duration
        , d.filter_date
        , pd.part_id
        , pd.part_number
        , pd.description
        , pd.provider
        , pd.avg_part_delay
        , pd.avg_price
        , pd.parts_quantity
        , count(distinct(part_id)) over (partition by w.period_id) bo_parts_count
    from wo_days w
    join duration d
        on w.period_id = d.period_id
    join part_details pd
        on w.wo_id=pd.wo_id
    where parts_quantity > 0
)

, new_lr_factor as ( -- Getting estimated daily revenue by asset class.
    select aa.CLASS
        , aa.EQUIPMENT_CLASS_ID
        , sum(hu.DAY_RATE) as revenue
        -- , sum(hu.PURCHASE_PRICE) as OEC
        , count(*) as days_in_fleet
        , revenue/days_in_fleet as daily_revenue
    from ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION HU
    left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on hu.ASSET_ID = aa.ASSET_ID
    where DTE between dateadd(month, -14, date_trunc(month, current_date)) and current_date
    group by aa.CLASS
        , aa.EQUIPMENT_CLASS_ID
)

, asset_detail as (
    select ast.*
        , aa.OEC
        , aa.class
        , aa.equipment_class_id
        , daily_revenue
        , daily_revenue * period_wo_duration lr_asset_period
        , (daily_revenue * period_wo_duration)/bo_parts_count parts_lr
        , (concat(make,', ',model)) Make_Model
        , company_id
    from asset_status ast
    join "ES_WAREHOUSE"."PUBLIC"."ASSETS_AGGREGATE" aa
        on ast.asset_id = aa.asset_id
    join new_lr_factor n
        on aa.equipment_class_id = n.equipment_class_id
    order by period_id, date_created
)

--run everything above this line to get WO/parts detail
, inventory as (
select part_id
,sum(available_quantity) parts_avail
from "ES_WAREHOUSE"."INVENTORY"."STORE_PARTS"
  where store_id!=432 -- this is ecom, which is currently inaccurate
  group by part_id
)

, summary as (
  select distinct
  ad.part_id
  , max(ad.filter_date) over (partition by ad.part_id) filter_date
  , part_number
  , description
  , provider
  , avg_part_delay
  ,avg_price
  , sum(parts_lr) over (partition by ad.part_id) total_part_lr
  , sum(parts_quantity) over (partition by ad.part_id) part_usage --this is within the 2021+ sample, not total part_usage with sales
  , parts_avail
  , datediff(months, '2021-01-01', current_date) months
  , avg_part_delay/30 avg_months_delay
  from asset_detail ad
  --lr_detail lr
  left join inventory i
  on ad.part_id=i.part_id
 order by total_part_lr desc
 )
-- , inventory_suggestions as(
-- select s.*
--  , part_usage/months monthly_consumption
--  , parts_avail/(part_usage/months) months_to_empty
--  , case when avg_months_delay>(parts_avail/(part_usage/months)) then 'Consider Ordering'
--   else 'Well Stocked' end inventory_health
-- from summary s
-- where total_part_lr is not null
-- and total_part_lr >=1
-- )

 --run everything above this line to get part LR summary
, vendor as(
select
distinct vendor
  ,vendorid
 ,(count(g.purchase_order_number) over (partition by g.part_id, g.vendorid))/(count(g.purchase_order_number) over (partition by g.part_id)) vendor_weight_percent
, s.*
 from summary s
 join granular g
  on s.part_id = g.part_id
  where total_part_lr is not null
  and total_part_lr >=1
  order by part_id
            )
 -- run everything above this line to get vendor details by part
, vendor_lr as(
  select vendor
  , vendorid
  , filter_date
 , part_id
 , vendor_weight_percent*total_part_lr vendor_part_lr
 from vendor
)

 select
 vendor,
 vendorid,
 filter_date,
 sum(vendor_part_lr) as lost_revenue
 from vendor_lr
    WHERE
    filter_date >= {% parameter start_date %}::date
    and filter_date < {% parameter end_date %}::date
group by vendor, vendorid, filter_date
;;
    }


    parameter: start_date {
      default_value: "2010-01-01"
      type: date
    }

    parameter: end_date {
      type: date
      default_value: "2099-01-01"
    }

    dimension: vendorid {
      type: string
      sql: ${TABLE}.vendorid ;;
    }

    dimension: vendor_name {
      type: string
      sql: ${TABLE}.vendor ;;
    }

  dimension_group: filter_date {
    type: time
    timeframes: [raw,date,time,week,month,quarter,year]
    sql: ${TABLE}.filter_date ;;
  }

  dimension: primary_key {
    primary_key: yes
    sql: CONCAT(${TABLE}.vendorid, ${TABLE}.filter_date) ;;
  }

  dimension: lost_revenue {
    type: number
    sql: ${TABLE}.lost_revenue ;;
  }

  dimension:  last_30_days{
    type: yesno
    sql:  ${filter_date_date} <= current_date AND ${filter_date_date} >= (current_date - INTERVAL '30 days')
      ;;
  }

  measure: sum_lr {
    type: sum
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${TABLE}.lost_revenue ;;
  }

  measure: days_30_lr {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name: usd
    value_format: "$#,##0"
    sql: ${TABLE}.lost_revenue ;;
  }

  }
