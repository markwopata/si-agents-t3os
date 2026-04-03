view: lost_revenue {
  derived_table: { #based off of https://gitlab.internal.equipmentshare.com/business-intelligence/ba-part-analytics/-/blob/main/Adhoc/Backordered%20Parts%20LR/Recs.sql
    sql:
    with granular as(
  select po.purchase_order_number
, po.date_created
, r.date_received
, datediff(days,po.date_created,r.date_received) lead_time
, li.price_per_unit
, ri.accepted_quantity
, p.part_id
, p.part_number
, pt.description
, pr.name provider
, e.name vendor
, evs.external_erp_vendor_ref as vendor_id
from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
join "ES_WAREHOUSE"."INVENTORY"."PARTS" p
on li.item_id = p.item_id
left join "ES_WAREHOUSE"."INVENTORY"."PROVIDERS" pr
on p.provider_id=pr.provider_id
join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
on p.PART_TYPE_ID = pt.PART_TYPE_ID
join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
on r.purchase_order_id=po.purchase_order_id
left JOIN "ES_WAREHOUSE"."PURCHASES"."ENTITIES" e
on po.vendor_ID = e.entity_ID
left join "ES_WAREHOUSE"."PURCHASES"."ENTITY_VENDOR_SETTINGS" evs --to get vendor id formatted like Vxxx
on e.entity_ID = evs.entity_ID
where
po.purchase_order_number != 321858 --obvious mistake
and to_date(po.date_created) >= '2021-01-01'
and lead_time >=0
)
, parts_sum as(
select part_id
,part_number
,description
,provider
,avg(lead_time) avg_part_delay
,avg(price_per_unit) avg_price
,sum(accepted_quantity)
,count(purchase_order_number)
from granular
where not (description ILIKE ANY('%filter%','%oil%','%15W%','%Decal%','%Grease%'))
group by part_id, part_number
, description,provider
)
,   transactions_combined as (
-- Negative transactions (reducing inventory, increasing WO quantity)
         select
                tt.transaction_type_id,
                tt.name                               transaction_type,
                ti.QUANTITY_RECEIVED                 quantity,
                p1.part_id,
                p1.part_number,
       p1.provider_id,
                pt.description,
                t.from_id,
                t.to_id wo_id,
                ti.COST_PER_ITEM, -- Choosing to not trust this cost at this time
                t.transaction_id,
                ti.transaction_item_id,
                t.date_completed,
                date_trunc('month', t.date_completed) month_,
                case
                    when t.TRANSACTION_TYPE_ID = 7
                        then 'https://app.estrack.com/#/service/work-orders/' || TO_ID::STRING
                    end                               url_track,
                'negatives'                           src
         from es_warehouse.inventory.transactions t
                  join ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                       on t.TRANSACTION_ID = ti.TRANSACTION_ID
                  join es_warehouse.INVENTORY.TRANSACTION_TYPES tt
                       on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
                  join ES_WAREHOUSE.INVENTORY.PARTS p1
                       on ti.PART_ID = p1.PART_ID
                  left join ES_WAREHOUSE.INVENTORY.PARTS p2
                            on p1.duplicate_of_id = p2.PART_ID
                  join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
                       on pt.PART_TYPE_ID = coalesce(p2.PART_TYPE_ID, p1.PART_TYPE_ID)
       where tt.transaction_type_id=7

         union all

-- Positive transactions (Increasing inventory, Decreasing WO quantity)
         select
                tt.transaction_type_id,
                tt.name                               transaction_type,
                -ti.QUANTITY_RECEIVED                  quantity,
                p1.part_id,
                p1.part_number,
       p1.provider_id,
                pt.description,
                t.to_id,
       t.from_id wo_id,
                ti.COST_PER_ITEM, -- Choosing to not trust this cost at this time
                t.transaction_id,
                ti.transaction_item_id,
                t.date_completed,
                date_trunc('month', t.date_completed) month_,
                case
                    when t.TRANSACTION_TYPE_ID = 9
                        then 'https://app.estrack.com/#/service/work-orders/' || from_id::STRING
                    end                               url_track,
                'positives'                           src
         from es_warehouse.inventory.transactions t
                  join ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
                       on t.TRANSACTION_ID = ti.TRANSACTION_ID
                  join es_warehouse.INVENTORY.TRANSACTION_TYPES tt
                       on t.TRANSACTION_TYPE_ID = tt.TRANSACTION_TYPE_ID
                  join ES_WAREHOUSE.INVENTORY.PARTS p1
                       on ti.PART_ID = p1.PART_ID
                  left join ES_WAREHOUSE.INVENTORY.PARTS p2
                            on p1.duplicate_of_id = p2.PART_ID
                  join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
                       on pt.PART_TYPE_ID = coalesce(p2.PART_TYPE_ID, p1.PART_TYPE_ID)
       where tt.transaction_type_id=9
     )


,part_details as (
  select distinct tc.part_id
, wo_id
, SUM(tc.quantity) OVER (PARTITION BY tc.part_id,wo_id) AS parts_quantity
, ps.part_number
, ps.description
, ps.provider
, ps.avg_part_delay
, ps.avg_price
from transactions_combined tc
join parts_sum ps
on tc.part_id = ps.part_id
where wo_id is not null
and avg_part_delay >=10

  )
, base as (
  select concat(asset_id || date_end) period_id
, asset_id
, asset_inventory_status
, date_start
, date_end return_date
, lead(date_start) over (partition by asset_id order by date_start) next_rental
from "ES_WAREHOUSE"."SCD"."SCD_ASSET_INVENTORY_STATUS"
  where asset_inventory_status = 'On Rent'
  --and asset_id =10141 --marks example asset
order by date_start
)
,wo_days as (
  select b.period_id
, b.asset_id
, return_date
, COALESCE(next_rental,current_date)
, work_order_id wo_id
, severity_level_name severity
, date_created
, date_completed
, datediff(days, date_created, date_completed) wo_duration
, sum(datediff(days, date_created, date_completed)) over (partition by b.period_id) period_wo_duration_overlap
from base b
join "ES_WAREHOUSE"."WORK_ORDERS"."WORK_ORDERS" wo
on b.asset_id = wo.asset_id
and wo.date_created between return_date and next_rental
where b.next_rental is not null
and (severity ='Hard Down' or severity ='Soft Down') --soft down was not originally included due to them still be available for rent
and work_order_type_name = 'General'
and archived_date is null
and year(date_created)>=2021
and year(date_completed)>=2021
order by return_date
)
, duration as(
  select period_id
,min(date_created)
, max(date_completed)
, datediff(days,min(date_created),max(date_completed)) period_wo_duration
from wo_days d
group by period_id
having period_wo_duration>0
)
, asset_status as(
  select w.*
, d.period_wo_duration
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
  on w.period_id=d.period_id
join part_details pd
  on w.wo_id=pd.wo_id
  where parts_quantity>0
 )
, new_lr_factor as (
  select
  aa.CLASS
,aa.EQUIPMENT_CLASS_ID
,sum(hu.DAY_RATE) as revenue
,sum(hu.PURCHASE_PRICE) as OEC
,count(*) as days_in_fleet
,revenue/days_in_fleet as daily_revenue
from ANALYTICS.PUBLIC.HISTORICAL_UTILIZATION HU
left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
    on hu.ASSET_ID = aa.ASSET_ID
where DTE between '2021-01-01' and current_date
group by
  aa.CLASS
,aa.EQUIPMENT_CLASS_ID
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
  on aa.equipment_class_id=n.equipment_class_id
//and COMPANY_ID IN (SELECT COMPANY_ID
//                               FROM ES_WAREHOUSE.public.companies
//                               WHERE name REGEXP 'IES\\d+ .*'
//                                  OR COMPANY_ID = 420           -- Demo Units
//                                  OR COMPANY_ID = 62875         -- ES Owned special events - still owned by us
//                                  OR COMPANY_ID IN (1854, 1855) -- ES Owned
//                                  OR COMPANY_ID = 61036         -- Trekker
//                                  --CONTRACTOR OWNED/OWN PROGRAM
//                                  OR COMPANY_ID IN (SELECT DISTINCT AA.COMPANY_ID
//                                                    FROM ES_WAREHOUSE.PUBLIC.V_PAYOUT_PROGRAMS VPP
//                                                             JOIN ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE AA
//                                                                  ON VPP.ASSET_ID = AA.ASSET_ID
//                                                    WHERE CURRENT_TIMESTAMP >= VPP.START_DATE
//                                                      AND CURRENT_TIMESTAMP < COALESCE(VPP.END_DATE, '2099-12-31')))
//
//                                                  AND FIRST_RENTAL >= '2021-01-01'  --would like something smarter here, like using all of fleet then measuring months in fleet toget monthly part consumption?
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
  , ad.date_created
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
, inventory_suggestions as(
select s.*
 , part_usage/months monthly_consumption
 , parts_avail/(part_usage/months) months_to_empty
 , case when avg_months_delay>(parts_avail/(part_usage/months)) then 'Consider Ordering'
  else 'Well Stocked' end inventory_health
from summary s
where total_part_lr is not null
and total_part_lr >=1
)
 --run everything above this line to get part LR summary
, vendor as(
select distinct vendor
  , vendor_id --added for scorecard
 ,(count(g.purchase_order_number) over (partition by g.part_id, g.vendor))/(count(g.purchase_order_number) over (partition by g.part_id)) vendor_weight_percent
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
  select date_created
 , vendor
 , vendor_id
 , part_id
 , vendor_weight_percent*total_part_lr vendor_part_lr
 from vendor
 )
 select date_created
 , vendor
 , vendor_id
 , sum(vendor_part_lr) as lost_revenue
 from vendor_lr
 group by date_created, vendor, vendor_id
             ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}.date_created ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}.vendor_id ;;
  }

  dimension: lost_revenue {
    type: number
    sql: ${TABLE}.lost_revenue ;;
  }

  # -------------------- rolling 30 days section --------------------
  dimension:  last_30_days{
    type: yesno
    sql:  ${date_created} <= current_date AND ${date_created} >= (current_date - INTERVAL '30 days')
      ;;
  }


  measure: 30_day_cost {
    type: sum
    filters: [last_30_days: "No"]
    value_format_name:usd
    value_format: "$#,##0"
    sql: ${lost_revenue} ;;
  }

  # -------------------- end rolling 30 days section --------------------


}
