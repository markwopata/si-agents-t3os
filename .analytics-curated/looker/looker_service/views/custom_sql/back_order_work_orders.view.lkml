view: back_order_work_orders_listed {
  derived_table: {
    sql: with bo_po_li as ( --3762
    select po.purchase_order_number
        , po.purchase_order_id
        , li.purchase_order_line_item_id
        , li.allocation_type
        , li.allocation_id
        , datediff(days, po.date_created, current_date) days_since_order
        , po.reference
        , po.date_created
    from "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" po
    join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" li
        on po.PURCHASE_ORDER_ID = li.PURCHASE_ORDER_ID
    left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVER_ITEMS" ri
        on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
    left join "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_RECEIVERS" r
        on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
    left join ES_WAREHOUSE.PUBLIC.MARKETS ma
        on po.REQUESTING_BRANCH_ID = ma.MARKET_ID
    join "ES_WAREHOUSE"."INVENTORY"."PARTS" p --Only looking at PO's that have a part attached
        on li.item_id = p.item_id
    where days_since_order >= 7 --changing from 10 to 7 per alistair (procurement) -hh 11/22/24
        and po.status = 'OPEN'
        and po.date_archived is null
        AND DATE_RECEIVED IS NULL
        and ma.company_id = 1854
        and li.date_archived is null
        -- and reference is not null
        -- and reference <> ''
        and li.allocation_type not ilike 'INVOICE'
    group by po.purchase_order_number
        , days_since_order
        , po.reference
        , po.purchase_order_id
        , li.purchase_order_line_item_id
        , li.allocation_type
        , li.allocation_id
        , po.date_created
)

-- select count(distinct purchase_order_number) from bo_po_li;

, wo_on_bo as (
    select wo.work_order_id
        , wo.date_created
        , wo.asset_id
        , a.make
        , a.model
        , a.class
    from ES_WAREHOUSE.work_orders.work_orders wo
    left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE a
        on a.asset_id = wo.asset_id
    where date_completed is null
         and datediff(day,wo.date_created, current_date) > 7 --changing from 10 to 7 per alistair (procurement) -hh 11/22/24
         -- and wo.work_order_id = 33033
)

, allocated_line_items as (
    select po.purchase_order_number
        , po.reference
        , wo.work_order_id
        , wo.asset_id
        , wo.make
        , wo.model
        , wo.class
    from bo_po_li po
    join wo_on_bo wo
        on po.allocation_id = wo.work_order_id
            and wo.date_created <= po.date_created
    group by po.purchase_order_number
        , po.reference
        , wo.work_order_id
        , wo.asset_id
        , wo.make
        , wo.model
        , wo.class
)

, bo_po as (
    select bo.purchase_order_number
        , bo.purchase_order_id
        , bo.days_since_order
        , bo.reference
        , bo.date_created
    from bo_po_li bo
    left join allocated_line_items ali
        on ali.purchase_order_number = bo.purchase_order_number
    where bo.reference is not null
        and bo.reference <> ''
        and ali.purchase_order_number is null
    group by bo.purchase_order_number
        , bo.days_since_order
        , bo.reference
        , bo.purchase_order_id
        , bo.date_created
    )

 -- select purchase_order_number, count(purchase_order_number) as c from bo_po group by purchase_order_number order by c desc;
 --select count(purchase_order_number), count(distinct purchase_order_number) from bo_po ; --3503 Back Order PO's that have Parts on them

, formatless as (
    select purchase_order_number
        , LTRIM(REGEXP_REPLACE(reference,'[A-z]','')) as no_letters
        , Ltrim(no_letters, ':#/-_,$.* ') as left_no_symbols
        , Rtrim(left_no_symbols, ':#/-_,$.* ') as no_symbols
        , left(no_symbols,7) as wo_id
        , left(no_symbols,6) as asset_id
        , reference
        , date_created
        , days_since_order
    from bo_po
    where reference not ilike '%WO%'
        and reference not ilike '%W/O%'
        and reference not ilike '%W.O.%'
        and reference not ilike '%W %'
        and reference not ilike '%asset%'
        and reference not ilike '%a:%'
        and reference not like '%A %'
        and reference not ilike '%A#%'
        and reference not ilike '%unit%'
        and reference not ilike '%ass#%'
        and reference not ilike '%UN:%'
        and wo_id <> ''
)

, wo as (
    select purchase_order_number
        , LTRIM(REGEXP_REPLACE(reference,'[A-z]','')) as no_letters
        , Ltrim(no_letters, ':#/-_,$.* ') as left_no_symbols
        , Rtrim(left_no_symbols, ':#/-_,$.* ') as no_symbols
        , left(no_symbols,7) as wo_id
        , reference
        , date_created
        , days_since_order
    from bo_po
    where (reference ilike '%WO%'
            or reference ilike '%W/O%'
            or reference ilike '%W.O.%'
            or reference not ilike '%W %')
        and reference not ilike '%asset%'
        and reference not ilike '%a:%'
        and reference not like '%A %'
        and reference not ilike '%A#%'
        and reference not ilike '%unit%'
        and reference not ilike '%ass#%'
        and reference not ilike '%UN:%'
)

, asset as (
    select purchase_order_number
        , LTRIM(REGEXP_REPLACE(reference,'[A-z]','')) as no_letters
        , Ltrim(no_letters, ':#/-_,$.* ') as left_no_symbols
        , Rtrim(left_no_symbols, ':#/-_,$.* ') as no_symbols
        , left(no_symbols,6) as asset_id
        , reference
        , date_created
        , days_since_order
    from bo_po
    where reference not ilike '%WO%'
        and reference not ilike '%W/O%'
        and reference not ilike '%W.O.%'
        and reference not ilike '%W %'
        and (reference ilike '%asset%'
            or reference ilike '%a:%'
            or reference like '%A %'
            or reference ilike '%A#%'
            or reference ilike '%unit%'
            or reference ilike '%ass#%'
            or reference ilike '%UN:%' )
)

, wo_asset as (
    select purchase_order_number
        , LTRIM(REGEXP_REPLACE(reference,'[A-z]','')) as no_letters
        , Ltrim(no_letters, ':#/-_,$.* ') as left_no_symbols
        , Rtrim(left_no_symbols, ':#/-_,$.* ') as no_symbols
        , left(no_symbols,6) as asset_id
        , left(no_symbols,7) as wo_id
        , reference
        , date_created
        , days_since_order
    from bo_po
    where (reference ilike '%WO%'
            or reference ilike '%W/O%'
            or reference ilike '%W.O.%'
            or reference not ilike '%W %')
        and (reference ilike '%asset%'
            or reference ilike '%a:%'
            or reference like '%A %'
            or reference ilike '%A#%'
            or reference ilike '%unit%'
            or reference ilike '%ass#%'
            or reference ilike '%UN:%' )
)

--Invoices were all based on he purchase order invoice, no luck attaching them
, aggregate as (
select po.purchase_order_number
    , days_since_order
    , po.reference
    , wo.work_order_id
    , wo.asset_id
    , wo.make
    , wo.model
    , wo.class
from wo po
join wo_on_bo wo
    on wo.work_order_id::STRING = po.wo_id
        and wo.date_created <= po.date_created

union

select po.purchase_order_number
    , days_since_order
    , po.reference
    , wo.work_order_id
    , wo.asset_id
    , wo.make
    , wo.model
    , wo.class
from asset po
join wo_on_bo wo
    on wo.asset_id::STRING = po.asset_id
        and wo.date_created <= po.date_created

union

select po.purchase_order_number
    , days_since_order
    , po.reference
    , coalesce(wo1.work_order_id, wo2.work_order_id) as _work_order_id
    , coalesce(wo1.asset_id, wo2.asset_id) as _asset_id
    , coalesce(wo1.make, wo2.make) as make
    , coalesce(wo1.model, wo2.model) as model
    , coalesce(wo1.class, wo2.class) as class
from wo_asset po
left join wo_on_bo wo1
    on wo1.work_order_id::STRING = po.wo_id
        and wo1.date_created <= po.date_created
left join wo_on_bo wo2
    on wo2.asset_id::STRING = po.asset_id
        and wo2.date_created <= po.date_created
where _work_order_id is not null

union

select po.purchase_order_number
    , days_since_order
    , po.reference
    , coalesce(wo1.work_order_id, wo2.work_order_id) as _work_order_id
    , coalesce(wo1.asset_id, wo2.asset_id) as _asset_id
    , coalesce(wo1.make, wo2.make) as make
    , coalesce(wo1.model, wo2.model) as model
    , coalesce(wo1.class, wo2.class) as class
from formatless po
left join wo_on_bo wo1
    on wo1.work_order_id::STRING = po.wo_id
        and wo1.date_created <= po.date_created
left join wo_on_bo wo2
    on wo2.asset_id::STRING = po.asset_id
        and wo2.date_created <= po.date_created
where _work_order_id is not null
)

-- select * from aggregate order by purchase_order_number desc;
-- select count(purchase_order_number), count(distinct purchase_order_number) from aggregate;
select a.purchase_order_number
    , a.reference
    , a.work_order_id
    , iff(wo.archived_date is null and xw.MARKET_ID is not null, a.work_order_id, null) as wo_id
    , a.asset_id
    , a.make
    , a.model
    , a.class
from aggregate a
left join es_warehouse.work_orders.work_orders wo
  on a.work_order_id = wo.work_order_id
left join ANALYTICS.PUBLIC.MARKET_REGION_XWALK xw
  on wo.BRANCH_ID = xw.MARKET_ID
;;
}

  dimension: powo {
    primary_key: yes
    type: number
    value_format_name: id
    sql: concat(${TABLE}.purchase_order_number,"-",${TABLE}.work_order_id) ;;
  }

  dimension: purchase_order_number {
    type: number
    value_format_name: id
    sql: ${TABLE}.purchase_order_number ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}.reference ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: wo_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.wo_id ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_id_2 {
    type: number
    value_format_name: id
    sql: iff(${wo_id} is null, null, ${TABLE}.asset_id) ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: make_2 {
    label: "Make"
    type: string
    sql: iff(${wo_id} is null, null, ${TABLE}.make) ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: model_2 {
    label: "Model"
    type: string
    sql: iff(${wo_id} is null, null, ${TABLE}.model) ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }

  measure: outstanding_wo_count {
      type: count_distinct
      sql: ${wo_id} ;;
      drill_fields: [entities.name,
                     back_order_parts_and_wo_impact.part_id,
                     back_order_parts_and_wo_impact.part_number,
                     back_order_parts_and_wo_impact.description,
                     back_order_parts_and_wo_impact.sum_total_on_order,
                     back_order_parts_and_wo_impact.po_number_link,
                    part_back_order_requests_board.vendor_updates,
                     market_region_xwalk.market_name,
                    market_region_xwalk.region_name,
                     work_orders.work_order_id_with_link_to_work_order,
                     work_orders.severity_level_name,
                     work_orders.asset_id,
                     assets_aggregate.oec,
                     make_2,
                     model_2,
                  assets_aggregate.serial_number,
                   part_back_order_requests_board.equipment_priority,
                     daily_rev_calculation.time_utilization

                    ]
  }

}


view: back_order_work_orders{
  derived_table: {
    sql:
-- select * from aggregate order by purchase_order_number desc;
-- select count(purchase_order_number), count(distinct purchase_order_number) from aggregate;
select purchase_order_number
    , reference
    , listagg(work_order_id, ', ') as potential_wo
    , asset_id
    , make
    , model
    , class
from ${back_order_work_orders_listed.SQL_TABLE_NAME}
group by purchase_order_number
    , reference
    , asset_id
    , make
    , model
    , class
;;
  }

  dimension: purchase_order_number {
    primary_key: yes
    type: number
    value_format_name: id
    sql: ${TABLE}.purchase_order_number ;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}.reference ;;
  }

  dimension: potential_wo {
    type: string
    sql: ${TABLE}.potential_wo ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: make {
    type: string
    sql: ${TABLE}.make ;;
  }

  dimension: model {
    type: string
    sql: ${TABLE}.model ;;
  }

  dimension: class {
    type: string
    sql: ${TABLE}.class ;;
  }

  measure: count {
    type: count_distinct
    sql: ${purchase_order_number} ;;
    drill_fields: [purchase_order_number
        , reference
        , potential_wo
        , asset_id
        , make
        , model]
  }

}
