view: suggested_min_max {
  derived_table: {
    sql:
with inventory_on_hand_prep as (
    select sp.STORE_ID
        , sp.PART_ID
        , sp.store_part_id
        , sp.max
        , sp.threshold min
        , sp.QUANTITY
        , sp.available_quantity
        , sum(iff(r.target_type_id = 1,r.quantity,0)) as reserved_work_order
        , sum(iff(r.target_type_id = 2,r.quantity,0)) as reserved_invoice
        , sum(zeroifnull(r.quantity)) as reserved
    from ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
    left join es_warehouse.inventory.reservations r
        on r.store_id = sp.store_id
            and r.part_id = sp.part_id
            and date_completed is null
            and date_cancelled is null
    group by 1,2,3,4,5,6,7
)
-- select count(reservation_id), count(distinct reservation_id) from inventory_on_hand ; --No dupes

, inventory_on_hand as (
    select store_id
        , part_id
        , store_part_id
        , quantity as owned_quantity
        , available_quantity as quantity_on_hand
        , reserved_work_order
        , reserved_invoice
        , reserved
        , quantity - quantity_on_hand - reserved as quantity_on_rent
        , max
        , min
    from inventory_on_hand_prep
)

, current_store_inventory as (
    select dm.market_id
        , dm.market_name
        , p.master_part_id
        , avg(wac.weighted_average_cost) as market_average_cost
        , sum(owned_quantity) as market_owned_quantity
        , sum(zeroifnull(owned_quantity) * zeroifnull(wac.weighted_average_cost)) as market_value_owned
        , sum(zeroifnull(i.quantity_on_hand)) market_quantity_on_hand
        , sum(zeroifnull(i.quantity_on_hand) * zeroifnull(wac.weighted_average_cost)) as market_value_on_hand
        , sum(zeroifnull(i.quantity_on_rent)) market_quantity_on_rent
        , sum(zeroifnull(i.quantity_on_rent) * zeroifnull(wac.weighted_average_cost)) as market_value_on_rent
        , sum(zeroifnull(i.reserved_work_order)) market_reserved_work_order
        , sum(zeroifnull(i.reserved_work_order) * zeroifnull(wac.weighted_average_cost)) as market_value_reserved_work_order
        , sum(zeroifnull(i.reserved_invoice)) market_reserved_invoice
        , sum(zeroifnull(i.reserved_invoice) * zeroifnull(wac.weighted_average_cost)) as market_value_reserved_invoice
        , sum(zeroifnull(max)) as market_max
        , sum(zeroifnull(min)) as market_min
    from inventory_on_hand i
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS s
        on i.STORE_ID = s.INVENTORY_LOCATION_ID
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
        on dm.market_id = s.branch_id
    left join ANALYTICS.PARTS_INVENTORY.PARTS p
        on i.part_id = p.part_id
    left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS wac
        on wac.is_current = TRUE
            and i.part_id = wac.product_id
            and i.STORE_ID = wac.inventory_location_id
    where s.date_archived is null
        and s.INVENTORY_LOCATION_ID in ( -- vishesh agreed with ignoring qty on inactive stores and active stores that are tied to an archived market
                select il.inventory_location_id -- this is the accounting JE suppression piece
                from ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
                join ES_WAREHOUSE.PUBLIC.MARKETS m
                    on il.BRANCH_ID = m.MARKET_ID
                where il.company_id = 1854
                    and il.date_archived is null
                    and m.ACTIVE = TRUE)
    group by 1,2,3
)

, market_parts as ( --Pulling the every part and market combination present in the inventory.
    select distinct market_id
        , master_part_id
   from current_store_inventory
   where master_part_id is not null
)

, on_order as (
    select iff(mp.market_id is null, TRUE, FALSE) as new_part
        , dm.market_id
        , dm.market_name
        , p.master_part_id
        , sum(poli.quantity - poli.total_accepted - poli.total_rejected) as quantity_on_order
        , avg(poli.price_per_unit) as avg_line_item_price
        , sum(poli.price_per_unit * (poli.quantity - poli.total_accepted - poli.total_rejected))  as value_on_order
    from procurement.public.purchase_orders po
    join procurement.public.purchase_order_line_items poli
        on po.purchase_order_id = poli.purchase_order_id
    join es_warehouse.inventory.parts og
        on poli.item_id = og.item_id
    join analytics.parts_inventory.parts p
        on og.part_id = p.part_id
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
        on po.REQUESTING_BRANCH_ID = dm.market_id
    left join market_parts mp
        on mp.market_id = dm.market_id
            and mp.master_part_id = p.master_part_id
    where po.date_archived is null
        and po.status = 'OPEN'
        and poli.date_archived is null
        -- and pr.provider_id not in (select provider_id from ANALYTICS.PARTS_INVENTORY.ATTACHMENT_PROVIDER_IDS)
    group by 1,2,3,4
    having quantity_on_order > 0
)

-- select the_region_name, round(sum(value_on_order), 0) v from on_order group by 1 order by 2;

, current_inventory as (
    select ti.market_id
        , ti.market_name
        , ti.master_part_id
        , ti.market_max
        , ti.market_min
        , iff(market_min + market_max = 0, 'As Needed', 'Stocked') as possession_type
        , ti.market_average_cost
        , ti.market_owned_quantity
        , ti.market_value_owned
        , ti.market_quantity_on_hand
        , ti.market_value_on_hand
        , ti.market_quantity_on_rent
        , ti.market_value_on_rent
        , ti.market_reserved_work_order
        , ti.market_value_reserved_work_order
        , ti.market_reserved_invoice
        , ti.market_value_reserved_invoice
        , zeroifnull(oo.quantity_on_order) quantity_on_order
        , zeroifnull(oo.value_on_order) as value_on_order
        , oo.avg_line_item_price
        ,(ti.market_owned_quantity + zeroifnull(oo.quantity_on_order))- ti.market_max  as excess_inventory
    from current_store_inventory ti
    left join on_order oo
        on oo.master_part_id = ti.master_part_id
            and oo.market_id = ti.market_id
            and oo.new_part = FALSE

    union

    select market_id
        , market_name
        , master_part_id
        , null as market_max
        , null as market_min
        , 'As Needed' as possesion_type
        , 0 as market_average_cost
        , 0 as market_owned_quantity
        , 0 as market_value_owned
        , 0 as market_quantity_on_hand
        , 0 as market_value_on_hand
        , 0 as market_quantity_on_rent
        , 0 as market_value_on_rent
        , 0 as market_reserved_work_order
        , 0 as market_value_reserved_work_order
        , 0 as market_reserved_invoice
        , 0 as market_value_reserved_invoice
        , oo.quantity_on_order quantity_on_order
        , oo.value_on_order as value_on_order
        , oo.avg_line_item_price
        , oo.quantity_on_order as excess_inventory
    from on_order oo
    where oo.new_part = TRUE
)

--Needs to be by transaction line now
, total_sold as (
    select pit.market_id
        , pit.market_name
        , pit.transaction_id
        , pit.date_completed
        , pit.transaction_item_id
        , pit.root_part_id as master_part_id
        , -pit.quantity as quantity_sold
        -- , avg(coalesce(li.price_per_unit, pit.weighted_average_cost, pit.cost_per_item)) as invoice_price
        -- , quantity_sold * invoice_price as value_sold
    from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
    -- left join es_warehouse.public.line_items li
    --     on pit.to_id = li.invoice_id
    --         and li.extended_data:part_id = pit.part_id
    where pit.TRANSACTION_TYPE_ID in (3, -- Store to Retail Sale
                                     13) -- Store to Rental Retail Sale
        and pit.DATE_CANCELLED is null
        and pit.store_id not in (432, 6004, 9814)
        and date_trunc(month, pit.date_completed) > dateadd(month, -13, date_trunc(month, current_date))
        and date_trunc(month, pit.date_completed) < date_trunc(month, current_date)
    -- group by 1,2,3,4,5,6,7
)

, total_to_wo_prep as (
    select pit.market_id
        , pit.market_name
        , pit.transaction_id
        , pit.date_completed
        , pit.transaction_item_id
        , pit.root_part_id as master_part_id
        , -pit.quantity as wo_quantity
        -- , pit.cost_per_item
        -- , max(pit.wac_snapshot_id) over (partition by pit.work_order_id, pit.root_part_id) as last_snapshot
    from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
    join ANALYTICS.PARTS_INVENTORY.PARTS p
        on p.part_id = pit.part_id
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on wo.work_order_id = pit.work_order_id
            and wo.description not ilike '%Cycle Count%'
    left join (
            select distinct wo.work_order_id
            from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_COMPANY_TAGS woct
            join ES_WAREHOUSE.WORK_ORDERS.COMPANY_TAGS ct
                on ct.company_tag_id = woct.company_tag_id
            join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
                on wo.work_order_id = woct.work_order_id
            where ct.name ilike any ('%Inventory%','%Cycle Count%','%Adjustment%') and wo.asset_id is null
        ) ct
        on ct.work_order_id = wo.work_order_id
    where pit.DATE_CANCELLED is null
        and pit.store_id not in (432, 6004, 9814)
        and ct.work_order_id is null
        and date_trunc(month, pit.date_completed) > dateadd(month, -13, date_trunc(month, current_date))
        and date_trunc(month, pit.date_completed) < date_trunc(month, current_date)
)

, total_to_wo as (
    select p.market_id
        , p.market_name
        , p.transaction_id
        , p.date_completed
        , p.transaction_item_id
        , p.master_part_id
        , p.wo_quantity
        -- , p.wo_quantity * coalesce(wac.weighted_average_cost, p.cost_per_item) as cost_to_wo
        -- , coalesce(wac.weighted_average_cost, p.cost_per_item) cost_per_item
    from total_to_wo_prep p
    -- left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS wac
    --     on wac.wac_snapshot_id = p.last_snapshot
)

, po_to_store as (
    select pit.market_id
        , pit.market_name
        , v.vendorid
        , v.name as vendor_name
        , pit.transaction_id
        , pit.date_completed
        , pit.transaction_item_id
        , pit.root_part_id as master_part_id
        , pit.quantity as quantity_bought
        -- , pit.quantity * coalesce(pit.weighted_average_cost, pit.cost_per_item) as price
        -- , coalesce(pit.weighted_average_cost, pit.cost_per_item) as cost_per_item
    from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
    left join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
        on po.purchase_order_id = pit.purchase_order_id
    left join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs
        on evs.entity_id = po.vendor_id
    left join ANALYTICS.INTACCT.VENDOR v
        on v.vendorid = evs.external_erp_vendor_ref
    where pit.TRANSACTION_TYPE_ID in (21, 23) -- Purchase to store
        and pit.DATE_CANCELLED is null
        and pit.store_id not in (432, 6004, 9814)
        and date_trunc(month, pit.date_completed) > dateadd(month, -13, date_trunc(month, current_date))
        and date_trunc(month, pit.date_completed) < date_trunc(month, current_date)
)

, top_part_vendor_market as (
    select pos.market_id
        , pos.market_name
        , pos.vendorid
        , pos.vendor_name
        , pos.master_part_id
        , sum(pos.quantity_bought)  as total_bought_vendor
        , row_number() over (partition by market_id,master_part_id order by total_bought_vendor desc) r
    from po_to_store pos
    where vendorid is not null
    group by 1,2,3,4,5
    qualify r = 1
)

, part_bought_company as (
    select pos.master_part_id
        , sum(pos.quantity_bought) as total_bought_company
    from po_to_store pos
    group by 1
)

, top_part_vendor_company as (
    select pos.vendorid
        , pos.vendor_name
        , pos.master_part_id
        , sum(pos.quantity_bought) as total_bought_vendor
        , total_bought_company
        , row_number() over (partition by pos.master_part_id order by total_bought_vendor desc) r
    from po_to_store pos
    left join part_bought_company pbc
        on pbc.master_part_id = pos.master_part_id
    where vendorid is not null
    group by 1,2,3,5
    qualify r = 1
)

, market_demand as (
    select market_id
        , market_name
        , transaction_id
        , date_completed
        , transaction_item_id
        , master_part_id
        , 'CONSUMPTION' as demand
        , quantity_sold as quantity
        -- , value_sold as value
        -- , invoice_price as cost_per_item
    from total_sold

    union

    select market_id
        , market_name
        , transaction_id
        , date_completed
        , transaction_item_id
        , master_part_id
        , 'CONSUMPTION' as demand
        , wo_quantity as quantity
        -- , cost_to_wo as value
        -- , cost_per_item
    from total_to_wo

    union

    select market_id
        , market_name
        , transaction_id
        , date_completed
        , transaction_item_id
        , master_part_id
        , 'PURCHASE' as demand
        , quantity_bought as quantity
        -- , price as value
        -- , cost_per_item
    from po_to_store
)

, month_market_part as ( --every market and part with at least 1 consumption in the last 12 months
    select distinct dd.date_month_start, md.market_id, md.master_part_id
    from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT dd
    full outer join (
            select distinct md.market_id
                , md.master_part_id
            from market_demand md
            where demand = 'CONSUMPTION'
            ) md
    where dd.date_month_start > dateadd(month, -13, date_trunc(month, current_date))
        and dd.date_month_start < date_trunc(month, current_date)
)

-- select market_id, master_part_id, count(market_id, master_part_id) c from month_market_part group by 1,2 ;

, trailing_12_month_demand_prep as (
    select dd.date_month_start
        , dd.market_id
        , dd.master_part_id
        , sum(zeroifnull(md.quantity)) as quantity_consumed
    from month_market_part dd
    left join market_demand md
        on date_trunc(month, md.date_completed) = dd.date_month_start
            and md.market_id = dd.market_id
            and md.master_part_id = dd.master_part_id
            and demand = 'CONSUMPTION'
    -- where dd.market_name = 'Whittier, CA - Core Solutions' and dd.part_id = 4328
    group by 1,2,3
)

-- select market_name, master_part_id, count(market_name, master_part_id) from trailing_12_month_demand_prep group by 1,2 ;

, trailing_12_month_demand as (
    select market_id
        , master_part_id
        , date_month_start as month_1
        , quantity_consumed as trailing_month_1
        , iff(trailing_month_1 > 0, 1, 0) as month_1_active
        , lead(quantity_consumed) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_2
        , iff(trailing_month_2 > 0, 1, 0) as month_2_active
        , lead(quantity_consumed, 2) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_3
        , iff(trailing_month_3 > 0, 1, 0) as month_3_active
        , lead(quantity_consumed, 3) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_4
        , iff(trailing_month_4 > 0, 1, 0) as month_4_active
        , lead(quantity_consumed, 4) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_5
        , iff(trailing_month_5 > 0, 1, 0) as month_5_active
        , lead(quantity_consumed, 5) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_6
        , iff(trailing_month_6 > 0, 1, 0) as month_6_active
        , lead(quantity_consumed, 6) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_7
        , iff(trailing_month_7 > 0, 1, 0) as month_7_active
        , lead(quantity_consumed, 7) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_8
        , iff(trailing_month_8 > 0, 1, 0) as month_8_active
        , lead(quantity_consumed, 8) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_9
        , iff(trailing_month_9 > 0, 1, 0) as month_9_active
        , lead(quantity_consumed, 9) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_10
        , iff(trailing_month_10 > 0, 1, 0) as month_10_active
        , lead(quantity_consumed, 10) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_11
        , iff(trailing_month_11 > 0, 1, 0) as month_11_active
        , lead(quantity_consumed, 11) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_12
        , iff(trailing_month_12 > 0, 1, 0) as month_12_active
    from trailing_12_month_demand_prep
    qualify month_1 = dateadd(month, -12, date_trunc(month, current_date))
)

, month_market_part_purchase as ( --every market and part with at least 1 purchase in the last 12 months
    select distinct dd.date_month_start, md.market_id, md.master_part_id
    from FLEET_OPTIMIZATION.GOLD.DIM_DATES_FLEET_OPT dd
    full outer join (
            select distinct md.market_id
                , md.master_part_id
            from market_demand md
            where demand = 'PURCHASE'
            ) md
    where dd.date_month_start > dateadd(month, -13, date_trunc(month, current_date))
        and dd.date_month_start < date_trunc(month, current_date)
)

-- select market_id, master_part_id, count(market_id, master_part_id) c from month_market_part group by 1,2 ;

, trailing_12_month_purchase_prep as (
    select dd.date_month_start
        , dd.market_id
        , dd.master_part_id
        , sum(zeroifnull(md.quantity)) as quantity_purchased
    from month_market_part_purchase dd
    left join market_demand md
        on date_trunc(month, md.date_completed) = dd.date_month_start
            and md.market_id = dd.market_id
            and md.master_part_id = dd.master_part_id
            and demand = 'PURCHASE'
    -- where dd.market_name = 'Whittier, CA - Core Solutions' and dd.part_id = 4328
    group by 1,2,3
)

-- select market_name, master_part_id, count(market_name, master_part_id) from trailing_12_month_demand_prep group by 1,2 ;

, trailing_12_month_purchases as (
    select market_id
        , master_part_id
        , date_month_start as month_1
        , quantity_purchased as trailing_month_1_purchases
        , lead(quantity_purchased) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_2_purchases
        , lead(quantity_purchased, 2) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_3_purchases
        , lead(quantity_purchased, 3) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_4_purchases
        , lead(quantity_purchased, 4) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_5_purchases
        , lead(quantity_purchased, 5) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_6_purchases
        , lead(quantity_purchased, 6) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_7_purchases
        , lead(quantity_purchased, 7) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_8_purchases
        , lead(quantity_purchased, 8) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_9_purchases
        , lead(quantity_purchased, 9) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_10_purchases
        , lead(quantity_purchased, 10) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_11_purchases
        , lead(quantity_purchased, 11) over (partition by market_id,master_part_id order by date_month_start asc) as trailing_month_12_purchases
    from trailing_12_month_purchase_prep
    qualify month_1 = dateadd(month, -12, date_trunc(month, current_date))
)

, stock_type as (
    select market_id
        , master_part_id
        , iff(
            month_1_active + month_2_active + month_3_active+ month_4_active+ month_5_active+ month_6_active+ month_7_active+ month_8_active+ month_9_active+ month_10_active+ month_11_active+ month_12_active >= 4
            , 'Stocked'
            , 'As Needed'
            ) suggested_stock_type
    from trailing_12_month_demand
)

, lead_time as ( ---this needs work
    select m.market_id
        , m.market_name
        , p1.master_part_id
        , avg(datediff(days, po.date_created, r.date_received)) lead_time
    from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
        on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
        on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
        on r.purchase_order_id=po.purchase_order_id
    join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT m
        on m.market_id = po.requesting_branch_id
    join ES_WAREHOUSE.INVENTORY.PARTS p
        on li.item_id = p.item_id
    join analytics.parts_inventory.parts p1
        on p1.part_id = p.part_id
    where ri.created_by_id != 21758 --this is eric prieto correcting POs for cost/quantities, but we want the og reception date
        and ri.accepted_quantity > 0 --Parts that were actually received
        and po.status!= 'ARCHIVED'
        and po.date_archived is null
        and li.date_archived is null
        and date_trunc(month, po.date_created) >= dateadd(month, -12, date_trunc(month, current_date))
        and date_trunc(month, po.date_created) < date_trunc(month, current_date)
    group by 1,2,3
)

, trailing_demand as (
    select md.market_id
        , md.master_part_id
        , lead_time
        , datediff(day, dateadd(month, -12, date_trunc(month, current_date)), dateadd(day, -1, date_trunc(month, current_date))) as trailing_days
        , sum(iff(md.demand = 'CONSUMPTION', md.quantity, 0)) as quantity_consumed
        -- , sum(iff(md.demand = 'CONSUMPTION', md.value, 0)) as value_consumed
        , sum(iff(md.demand = 'CONSUMPTION',  0, md.quantity)) as quantity_bought
        -- , sum(iff(md.demand = 'CONSUMPTION',  0, md.value)) as value_bought
    from market_demand md
    left join lead_time lt
        on lt.market_id = md.market_id
            and lt.master_part_id = md.master_part_id
    group by 1,2,3,4
)

select ci.market_id
    , ci.market_name
    , pr.name as provider_name
    , tpvm.vendorid as most_common_part_vendor
    , tpvm.vendor_name as most_common_part_vendor_name
    , tpvm.total_bought_vendor / nullifzero(quantity_bought) as percent_quantity_bought_from_vendor
    , tpvc.vendorid as most_common_part_vendor_company_wide
    , tpvc.vendor_name as most_common_part_vendor_name_company_wide
    , tpvc.total_bought_vendor as total_bought_vendor_company_wide
    , tpvc.total_bought_company as total_bought_company_wide
    , p.part_number
    , p.master_part_id
    , pt.description
    , ci.market_max
    , ci.market_max * ci.market_average_cost as market_max_value
    , ci.market_min
    , ci.market_min * ci.market_average_cost as market_min_value
    , ci.possession_type as current_stocking
    , listagg(distinct sp.location, ' / ') as bin_locations
    , ci.market_average_cost
    , ple.amount as list_price
    , ci.market_owned_quantity
    , ci.market_value_owned
    , ci.market_quantity_on_hand
    , ci.market_value_on_hand
    , ci.market_quantity_on_rent
    , ci.market_value_on_rent
    , ci.market_reserved_work_order
    , ci.market_value_reserved_work_order
    , ci.market_reserved_invoice
    , ci.market_value_reserved_invoice
    , ci.quantity_on_order
    , ci.value_on_order
    , ci.avg_line_item_price
    , ci.excess_inventory
    , ci.excess_inventory * ci.market_average_cost as excess_inventory_value
    , coalesce(st.suggested_stock_type, 'As Needed') as suggested_stocking
    , case
      when ci.excess_inventory < 0 then 'Needs Ordered'
      when ci.excess_inventory > 0 then 'Excess Inventory'
      else 'Good' end as inventory_health
    , zeroifnull(quantity_consumed) as trailing_12_mth_consumption
    -- , zeroifnull(value_consumed) as trailing_12_mth_consumption_value
    , zeroifnull(quantity_bought) as trailing_12_mth_purchases
    -- , zeroifnull(value_bought) as trailing_12_mth_purchase_value
    , lead_time as trailing_12_mth_lead_time
    , trailing_12_mth_consumption / trailing_days as daily_demand
    , daily_demand * iff(zeroifnull(lead_time) < 1, 1, lead_time) as lead_time_demand
    , iff(suggested_stocking = 'As Needed', null, round(daily_demand * (7+zeroifnull(lead_time)), 0)) as suggested_min
    , suggested_min * ci.market_average_cost as suggested_min_value
    , iff(suggested_stocking = 'As Needed', null, round((((zeroifnull(lead_time) + 30) * daily_demand) + suggested_min), 0)) as suggested_max
    , suggested_max * ci.market_average_cost as suggested_max_value
    , trailing_month_1
    , trailing_month_1 * ci.market_average_cost as trailing_month_1_value
    , trailing_month_2
    , trailing_month_2 * ci.market_average_cost as trailing_month_2_value
    , trailing_month_3
    , trailing_month_3 * ci.market_average_cost as trailing_month_3_value
    , trailing_month_4
    , trailing_month_4 * ci.market_average_cost as trailing_month_4_value
    , trailing_month_5
    , trailing_month_5 * ci.market_average_cost as trailing_month_5_value
    , trailing_month_6
    , trailing_month_6 * ci.market_average_cost as trailing_month_6_value
    , trailing_month_7
    , trailing_month_7 * ci.market_average_cost as trailing_month_7_value
    , trailing_month_8
    , trailing_month_8 * ci.market_average_cost as trailing_month_8_value
    , trailing_month_9
    , trailing_month_9 * ci.market_average_cost as trailing_month_9_value
    , trailing_month_10
    , trailing_month_10 * ci.market_average_cost as trailing_month_10_value
    , trailing_month_11
    , trailing_month_11 * ci.market_average_cost as trailing_month_11_value
    , trailing_month_12
    , trailing_month_12 * ci.market_average_cost as trailing_month_12_value
    , iff(suggested_stocking = 'As Needed', (ci.market_owned_quantity + zeroifnull(ci.quantity_on_order)) - 0, (ci.market_owned_quantity + zeroifnull(ci.quantity_on_order)) - suggested_max) as excess_based_on_suggestion
    , excess_based_on_suggestion * ci.market_average_cost as excess_value_based_on_suggestion
    , case
      when excess_based_on_suggestion < 0 then 'Needs Ordered'
      when excess_based_on_suggestion > 0 then 'Excess Inventory'
      else 'Good' end as excess_based_on_suggestion_inventory_health
    , trailing_month_1_purchases
    , trailing_month_2_purchases
    , trailing_month_3_purchases
    , trailing_month_4_purchases
    , trailing_month_5_purchases
    , trailing_month_6_purchases
    , trailing_month_7_purchases
    , trailing_month_8_purchases
    , trailing_month_9_purchases
    , trailing_month_10_purchases
    , trailing_month_11_purchases
    , trailing_month_12_purchases
from current_inventory ci
left join trailing_demand td
    on td.market_id = ci.market_id
        and td.master_part_id = ci.master_part_id
left join stock_type st
    on st.market_id = ci.market_id
        and st.master_part_id = ci.master_part_id
join analytics.parts_inventory.parts p
    on p.part_id = ci.master_part_id
left join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
    on pt.part_type_id = p.part_type_id
left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
    on pr.provider_id = p.provider_id
left join FLEET_OPTIMIZATION.GOLD.DIM_MARKETS_FLEET_OPT dm
    on dm.market_id = ci.market_id
left join trailing_12_month_demand tmd
    on tmd.market_id = ci.market_id
        and tmd.master_part_id = ci.master_part_id
left join trailing_12_month_purchases tmp
    on tmp.market_id = ci.market_id
        and tmp.master_part_id = ci.master_part_id
left join ES_WAREHOUSE.INVENTORY.PARTS p1
  on p.part_id = p1.part_id
left join PROCUREMENT.PUBLIC.PRICE_LIST_ENTRIES ple
  on ple.item_id = p1.item_id
left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
    on il.branch_id = ci.market_id
left join ES_WAREHOUSE.INVENTORY.STORE_PARTS sp
    on sp.store_id = il.inventory_location_id
        and sp.part_id = p1.part_id
left join top_part_vendor_market tpvm
    on tpvm.market_id = ci.market_id
        and tpvm.master_part_id = p.master_part_id
left join top_part_vendor_company tpvc
    on tpvc.master_part_id = p.master_part_id
group by 1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45,46,47,48,49,50,51,52,53,54,55,56,57,58,59,60,61,62,63,64,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86;;
  }

  dimension: primary_key {
    type: number
    primary_key: yes
    sql: concat(${market_id}, ${master_part_id}) ;;
  }

  dimension: market_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.market_id ;;
  }

  dimension: market_name {
    type: string
    # value_format_name: id
    sql: ${TABLE}.market_name ;;
  }

  dimension: provider_name {
    type: string
    # value_format_name: id
    sql: ${TABLE}.provider_name ;;
  }

  dimension: most_common_part_vendor {
    type: string
    sql: ${TABLE}.most_common_part_vendor ;;
  }

  dimension: most_common_part_vendor_name {
    type: string
    sql: ${TABLE}.most_common_part_vendor_name ;;
  }

  dimension: percent_quantity_bought_from_vendor {
    type: number
    value_format_name: percent_1
    sql: ${TABLE}.percent_quantity_bought_from_vendor ;;
  }

  dimension: most_common_part_vendor_company_wide {
    type: string
    sql: ${TABLE}.most_common_part_vendor_company_wide ;;
  }

  dimension: most_common_part_vendor_name_company_wide {
    type: string
    sql: ${TABLE}.most_common_part_vendor_name_company_wide ;;
  }

  dimension: quantity_bought_from_vendor_company_wide {
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.total_bought_vendor_company_wide ;;
  }

  dimension: quantity_bought_company_wide {
    type: number
    value_format_name: decimal_0
    sql: ${TABLE}.total_bought_company_wide ;;
  }

  dimension: part_number {
    type: string
    # value_format_name: id
    sql: ${TABLE}.part_number ;;
  }

  dimension: is_telematics_part {
    type: yesno
    sql: iff(${TABLE}.master_part_id in (select part_id from ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS), true, false) ;;
  }

  dimension: description {
    type: string
    # value_format_name: id
    sql: ${TABLE}.description ;;
  }

  dimension: market_min {
    type: number
    # value_format_name: id
    sql: ${TABLE}.market_min ;;
  }

  dimension: market_max {
    type: number
    # value_format_name: usd
    sql: ${TABLE}.market_max ;;
  }

  dimension: market_max_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.market_max_value ;;
  }

  dimension: market_min_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.market_min_value ;;
  }

  dimension: current_stocking {
    type: string
    # value_format_name: id
    sql: ${TABLE}.current_stocking ;;
  }

  dimension: market_average_cost {
    type: number
    value_format_name: usd
    sql: ${TABLE}.market_average_cost ;;
  }

  dimension: list_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.list_price ;;
  }

  dimension: market_owned_quantity {
    type: number
    # value_format_name: usd_0
    sql: ${TABLE}.market_owned_quantity ;;
  }

  dimension: bin_locations {
    type: string
    sql: ${TABLE}.bin_locations ;;
  }

  dimension: market_value_owned {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.market_value_owned ;;
  }

  dimension: market_quantity_on_hand {
    type: number
    # value_format_name: usd_0
    sql: ${TABLE}.market_quantity_on_hand ;;
  }

  dimension: market_value_on_hand {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.market_value_on_hand ;;
  }

  dimension: market_quantity_on_rent {
    type: number
    # value_format_name: usd_0
    sql: ${TABLE}.market_quantity_on_rent ;;
  }

  dimension: market_value_on_rent {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.market_value_on_rent ;;
  }

  dimension: market_reserved_work_order {
    type: number
    # value_format_name: usd_0
    sql: ${TABLE}.market_reserved_work_order ;;
  }

  dimension: market_value_reserved_work_order {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.market_value_reserved_work_order ;;
  }

  dimension: market_reserved_invoice {
    type: number
    # value_format_name: usd_0
    sql: ${TABLE}.market_reserved_invoice ;;
  }

  dimension: market_value_reserved_invoice {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.market_value_reserved_invoice ;;
  }

  dimension: quantity_on_order {
    type: number
    # value_format_name: usd_0
    sql: ${TABLE}.quantity_on_order ;;
  }

  dimension: value_on_order {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.value_on_order ;;
  }

  dimension: avg_line_item_price {
    type: number
    value_format_name: usd
    sql: ${TABLE}.avg_line_item_price ;;
  }

  dimension: excess_inventory {
    type: number
    # value_format_name: usd
    sql: ${TABLE}.excess_inventory ;;
  }

  dimension: excess_inventory_value {
    type: number
    value_format_name: usd
    sql: ${TABLE}.excess_inventory_value ;;
  }

  dimension: inventory_health {
    type: string
    sql: ${TABLE}.inventory_health ;;
  }

  dimension: suggested_stocking {
    type: string
    # value_format_name: usd
    sql: ${TABLE}.suggested_stocking ;;
  }

  dimension: trailing_12_mth_consumption {
    type: number
    # value_format_name: usd
    sql: ${TABLE}.trailing_12_mth_consumption ;;
  }

  dimension: trailing_12_mth_consumption_value {
    type: number
    value_format_name: usd_0
    sql: (${trailing_12_mth_consumption} * ${market_average_cost}) ;;
  }

  dimension: trailing_12_mth_purchases {
    type: number
    # value_format_name: usd
    sql: ${TABLE}.trailing_12_mth_purchases ;;
  }

  dimension: trailing_12_mth_lead_time {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.trailing_12_mth_lead_time ;;
  }

  dimension: daily_demand {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.daily_demand ;;
  }

  dimension: lead_time_demand {
    type: number
    value_format_name: decimal_1
    sql: ${TABLE}.lead_time_demand;;
  }

  dimension: suggested_min {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.suggested_min;;
  }

  dimension: suggested_max {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.suggested_max ;;
  }

  dimension: suggested_min_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.suggested_min_value ;;
  }

  dimension: suggested_max_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.suggested_max_value ;;
  }

  dimension: trailing_month_1 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_1 ;;
  }

  dimension: trailing_month_1_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_1_value ;;
  }

  dimension: trailing_month_2 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_2 ;;
  }

  dimension: trailing_month_2_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_2_value ;;
  }

  dimension: trailing_month_3 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_3 ;;
  }

  dimension: trailing_month_3_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_3_value ;;
  }

  dimension: trailing_month_4 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_4 ;;
  }

  dimension: trailing_month_4_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_4_value ;;
  }

  dimension: trailing_month_5 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_5 ;;
  }

  dimension: trailing_month_5_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_5_value ;;
  }

  dimension: trailing_month_6 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_6 ;;
  }

  dimension: trailing_month_6_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_6_value ;;
  }

  dimension: trailing_month_7 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_7 ;;
  }

  dimension: trailing_month_7_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_7_value ;;
  }

  dimension: trailing_month_8 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_8 ;;
  }

  dimension: trailing_month_8_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_8_value ;;
  }

  dimension: trailing_month_9 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_9 ;;
  }

  dimension: trailing_month_9_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_9_value ;;
  }

  dimension: trailing_month_10 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_10 ;;
  }

  dimension: trailing_month_10_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_10_value ;;
  }

  dimension: trailing_month_11 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_11 ;;
  }

  dimension: trailing_month_11_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_11_value ;;
  }

  dimension: trailing_month_12 {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_12 ;;
  }

  dimension: trailing_month_12_value {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_12_value ;;
  }

  dimension: master_part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.master_part_id ;;
  }

  dimension: excess_based_on_suggestion {
    type: number
    sql: ${TABLE}.excess_based_on_suggestion ;;
  }

  dimension: excess_value_based_on_suggestion {
    type: number
    value_format_name: usd
    sql: ${TABLE}.excess_value_based_on_suggestion ;;
  }

  dimension: excess_based_on_suggestion_inventory_health {
    type: string
    sql: ${TABLE}.excess_based_on_suggestion_inventory_health ;;
  }

  dimension: trailing_month_1_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_1_purchases ;;
  }
  dimension: trailing_month_2_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_2_purchases ;;
  }
  dimension: trailing_month_3_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_3_purchases ;;
  }
  dimension: trailing_month_4_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_4_purchases ;;
  }
  dimension: trailing_month_5_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_5_purchases ;;
  }
  dimension: trailing_month_6_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_6_purchases ;;
  }
  dimension: trailing_month_7_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_7_purchases ;;
  }
  dimension: trailing_month_8_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_8_purchases ;;
  }
  dimension: trailing_month_9_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_9_purchases ;;
  }
  dimension: trailing_month_10_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_10_purchases ;;
  }
  dimension: trailing_month_11_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_11_purchases ;;
  }
  dimension: trailing_month_12_purchases {
    type: number
    # value_format_name: decimal_
    sql: ${TABLE}.trailing_month_12_purchases ;;
  }
}
