view: open_work_orders {
  derived_table: {
    sql:
    WITH post_deadline_time as (
    select *
    from ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
    where ARCHIVED_DATE is null
      --and NEEDS_REVISION = false
      and WORK_ORDER_ID is not null
      and START_DATE > '2022-10-01'
      and te.EVENT_TYPE_ID = 1
      --and te.APPROVAL_STATUS like 'Approved'
      and datediff('day', te.START_DATE, te.END_DATE) <= 1 -- historical time entry has instances where it exceed 24 consecutive hours
      and datediff('hour', te.START_DATE, te.END_DATE) < 24
)

, pre_deadline_parts as (
    select *,
           IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) as work_order_id,
           IFF(TRANSACTION_TYPE_ID = 7, ti.QUANTITY_RECEIVED, 0 - ti.QUANTITY_RECEIVED) as qty
    from ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
    join ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
        on t.TRANSACTION_ID = ti.TRANSACTION_ID
    where t.TRANSACTION_TYPE_ID in (7,9)
        and t.date_completed is not null
        and t.date_cancelled is null
)

--Connecting each part on a work order to it's master part id
, parts_per_work_order as (
    select pdp.work_order_id
         , p1.master_part_id as current_part_ID
         , sum(pdp.qty) as quantity
         , wo.BRANCH_ID as market_id
         , iff(wo.date_completed is not null, wo.DATE_COMPLETED, wo.DATE_CREATED) as ref_date
    from pre_deadline_parts pdp
    join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
        on pdp.work_order_id = wo.WORK_ORDER_ID
    JOIN analytics.parts_inventory.parts p1
        on pdp.part_ID = p1.part_ID
    group by pdp.work_order_id
           , current_part_ID
           , wo.BRANCH_ID
           , iff(wo.date_completed is not null, wo.DATE_COMPLETED, wo.DATE_CREATED)
    having  sum(pdp.qty) <> 0
)
--select count(distinct work_order_id) from parts_per_work_order ;

, wac_prep as (
select *
    from es_warehouse.inventory.weighted_average_cost_snapshots wacs
    where date_applied::date <= current_date
        qualify
                row_number() over (
                    partition by wacs.inventory_location_id, wacs.product_id, date_applied
                    order by wacs.date_created desc)
                = 1
        and
                max(date_applied) over (
                    partition by PRODUCT_ID, INVENTORY_LOCATION_ID
                    order by date_applied desc)
                = date_applied
    order by product_id, INVENTORY_LOCATION_ID, date_applied desc)

--Aggregating WAC's for each part by the master part id across branch
, wac as (
    select il.branch_id
        , p.master_part_id as current_part_id
        , avg(wac.weighted_average_cost) as avg_cost
    from wac_prep wac
    join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
        on wac.inventory_location_id = il.inventory_location_id
    join analytics.parts_inventory.parts p
        on p.part_id = wac.product_id
    group by current_part_id
        , il.branch_id
)

--Company wide average backup
, wac_backup as (
    select p.master_part_id as current_part_id
        , avg(wac.weighted_average_cost) as avg_cost
    from wac_prep wac
    join analytics.parts_inventory.parts p
        on p.part_id = wac.product_id
    group by current_part_id
)

, parts_per_wo_w_cost_market as (
    select wo.work_order_id
         , wo.CURRENT_PART_ID
         , quantity * (acss.avg_cost) as line_total
    FROM parts_per_work_order wo
    JOIN wac acss
        ON wo.current_part_ID = acss.CURRENT_PART_ID
            AND wo.market_ID = acss.branch_id
    ORDER BY work_order_ID
)

--Pulling company wide where market is not present
, parts_per_wo_w_cost_company as (
    select wo.work_order_id
         , wo.CURRENT_PART_ID
         , quantity * (acss.avg_cost) as line_total
    FROM parts_per_work_order wo
    join wac_backup acss
        ON wo.current_part_ID = acss.CURRENT_PART_ID
    left join parts_per_wo_w_cost_market m
        on m.work_order_id = wo.work_order_id
            and m.current_part_id = wo.current_part_id
    where m.work_order_id is null
        and m.current_part_id is null
    ORDER BY work_order_ID
)

, parts_per_wo_w_cost as (
    select work_order_id
        , current_part_id
        , line_total
        , 'market' as c
    from parts_per_wo_w_cost_market
    --)select count(work_order_id, current_part_id) from parts_per_wo_w_cost; -- validate

    union

    select work_order_id
        , current_part_id
        , line_total
        , 'company' as c
    from parts_per_wo_w_cost_company
)
-- select count(work_order_id, current_part_id) from parts_per_wo_w_cost; --validate

--Aggregate work orders
, part_cost_per_work_order_final as (
    select
         work_order_id
         , sum(line_total) as part_cost
    FROM parts_per_wo_w_cost wo
    group by
           work_order_id
)

--, wo as (
    select m.name as market_name
        , listagg( distinct concat(cd.first_name, ' ', cd.last_name), ' / ') as GM
        , listagg( distinct cd.employee_title, ' / ') as title
        , listagg( distinct cd.work_email, ' / ') as email
        , wo.work_order_id
        , wo.date_created::date as created_date
        , wo.asset_id
        , c.name as asset_owner
        , ot.name as work_order_originator
        , wo.severity_level_name
        , bt.name as billing_type
        , sum(pdt.regular_hours) + sum(pdt.overtime_hours) as hours_worked
        , hours_worked * 100 as current_est_labor_cost
        , ppwo.part_cost as current_parts_cost
        , zeroifnull(current_est_labor_cost) + zeroifnull(ppwo.part_cost) as est_total_cost
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    left join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on aa.asset_id = wo.asset_id
    left join ES_WAREHOUSE.PUBLIC.COMPANIES c
        on c.company_id = aa.company_id
    left join post_deadline_time pdt
        on pdt.work_order_id = wo.work_order_id
    left join part_cost_per_work_order_final ppwo
        on ppwo.work_order_id = wo.work_order_id
    left join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDER_ORIGINATORS woo
        on woo.work_order_id = wo.work_order_id
    left join ES_WAREHOUSE.WORK_ORDERS.ORIGINATOR_TYPES ot
        on ot.originator_type_id = woo.originator_type_id
    left join ES_WAREHOUSE.WORK_ORDERS.BILLING_TYPES bt
        on bt.billing_type_id = wo.billing_type_id
    left join ES_WAREHOUSE.PUBLIC.MARKETS m
        on m.market_id = wo.branch_id
    left join (select * from ANALYTICS.PAYROLL.COMPANY_DIRECTORY where employee_title ilike 'general manager%' and date_terminated is null) cd
        on cd.market_id = m.market_id
     where wo.archived_date is null
        and wo.date_completed is null
group by wo.work_order_id
        , wo.asset_id
        , asset_owner
        , wo.severity_level_name
        , ppwo.part_cost
        , wo.date_created
        , work_order_originator
        , billing_type
        , market_name;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: GM {
    type: string
    sql: ${TABLE}.GM;;
  }

  dimension: title {
    type: string
    sql: ${TABLE}.title ;;
  }

  dimension: email {
    type: string
    sql: ${TABLE}.email ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.work_order_id ;;
  }

  dimension: created_date {
    type: date
    sql: ${TABLE}.created_date ;;
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_id ;;
  }

  dimension: asset_owner {
    type: number
    value_format_name: id
    sql: ${TABLE}.asset_owner ;;
  }

  dimension: work_order_originator {
    type: string
    sql: ${TABLE}.work_order_originator ;;
  }

  dimension: severity_level_name{
    type: string
    sql: ${TABLE}.severity_level_name ;;
  }

  dimension: billing_type {
    type: string
    sql: ${TABLE}.billing_type ;;
  }

  dimension: hours_worked {
    type: number
    sql: ${TABLE}.hours_worked ;;
  }

  dimension: current_est_labor_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.current_est_labor_cost ;;
  }

  dimension: current_parts_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.current_parts_cost ;;
  }

  dimension: est_total_cost {
    type: number
    value_format_name: usd_0
    sql: ${TABLE}.est_total_cost ;;
  }
}
