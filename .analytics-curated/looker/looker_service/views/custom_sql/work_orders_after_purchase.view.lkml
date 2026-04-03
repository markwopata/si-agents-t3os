view: work_orders_after_purchase {
    derived_table: {
      sql: with es_own_co as (
    select COMPANY_ID
    FROM ES_WAREHOUSE.public.companies
    WHERE name regexp 'IES\d+ .*' -- captures all IES# company_ids
        OR COMPANY_ID = 420 -- Demo Units
        OR COMPANY_ID = 62875 -- ES Owned special events - still owned by us
        OR COMPANY_ID in (1854, 1855) -- ES Owned
        OR COMPANY_ID = 61036 -- ES Owned - Trekker Temporary Holding
)

, wo as (
    select wo.branch_id
        , m.name as market_name
        , wo.work_order_id
        , wo.asset_id
        , wo.date_completed
        , datediff(day, aa.purchase_date, wo.date_completed) as days_since_bought
        , aa.make
        , aa.model
        , aa.class
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    join ES_WAREHOUSE.PUBLIC.ASSETS_AGGREGATE aa
        on wo.asset_id = aa.asset_id
    join es_own_co es
        on es.company_id = aa.company_id
    left join ES_WAREHOUSE.PUBLIC.MARKETS m
        on m.market_id = wo.branch_id
    join es_own_co es2
        on es2.company_id = m.company_id
    where days_since_bought <= 365
        and wo.archived_date is null
)

, wo_trans AS (
    SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) AS wo_id
        , coalesce(p2.part_id, p1.part_id) as the_part
        , IFF(transaction_type_id = 7, ti.quantity_received, 0-ti.quantity_received) AS qty
    FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
    LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
        ON t.TRANSACTION_ID = ti.TRANSACTION_ID
    join ES_WAREHOUSE.INVENTORY.PARTS p1
        on p1.part_id = ti.part_id
    join ES_WAREHOUSE.INVENTORY.PARTS p2
        on p2.part_id = p1.duplicate_of_id
    join wo
        on wo.work_order_id = wo_id
    WHERE TRANSACTION_TYPE_ID IN (7, 9)
        and qty is not null
        and t.date_cancelled is null
        and t.date_completed is not null
    order by ti.part_id
)

, company_wac as (
    select product_id as part_id
        , avg(weighted_average_cost) as avg_cost
    from ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS
    where is_current = true
        and weighted_average_cost <> 0
        and weighted_average_cost <> 0.01
    group by part_id
)

, max_snapshot as (
    select current_part_id
        , max(snapshot_date) max_snap
    from ANALYTICS.PUBLIC.AVERAGE_COST_SNAPSHOT
    group by current_part_id
)

, snap as (
    select snap.current_part_id
        , avg(snap.avg_cost) as avg_cost
    from ANALYTICS.PUBLIC.AVERAGE_COST_SNAPSHOT snap
    join max_snapshot ms
        on ms.max_snap = snap.snapshot_date
            and ms.current_part_id = snap.current_part_id
    group by snap.current_part_id
)

, parts_on_wo as (
    select wo.wo_id
        , wo.the_part as part_id
        , concat(wo.wo_id,wo.the_part) as base_unique
        , sum(wo.qty) as part_quantity
        , coalesce(wac.avg_cost, snap.avg_cost) as average_cost
        , part_quantity * average_cost as total_part_cost
    from wo_trans wo
    left join company_wac wac
        on wac.part_id = wo.the_part
    left join snap
        on snap.current_part_id = wo.the_part
    group by wo_id, the_part, average_cost
    having part_quantity > 0
)

, part_cost_on_wo as (
    select wo_id
        , sum(total_part_cost) as part_cost
    from parts_on_wo
    group by wo_id
)

--select count(base_unique), count(distinct base_unique) from parts_on_wo --no dupes

, time as (
    select wo.work_order_id
        , sum(regular_hours) as reg_hours
        , sum(overtime_hours) as ot_hours
        , reg_hours * 29.42 as reg_wages --Using average tech wages from Jan 2024
        , ot_hours * 44.14 as ot_wages
        , reg_wages + ot_wages as labor_cost
    from wo
    join ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
        on te.work_order_id = wo.work_order_id
    where te.approval_status = 'Approved'
        and te.archived_date is null
        and te.EVENT_TYPE_ID = 1
        and te.APPROVAL_STATUS like 'Approved'
        and datediff('day', te.START_DATE, te.END_DATE) <= 1 -- historical time entry has instances where it exceed 24 consecutive hours
        and datediff('hour', te.START_DATE, te.END_DATE) < 24
    group by wo.work_order_id
)

select wo.branch_id
    , wo.market_name
    , wo.work_order_id
    , wo.asset_id
    , wo.date_completed
    , wo.days_since_bought
    , wo.make
    , wo.model
    , wo.class
    , coalesce(t.reg_hours, 0) as regular_hours
    , coalesce(t.ot_hours, 0) as overtime_hours
    , coalesce(t.labor_cost, 0) as labor_cost1
    , coalesce(pcwo.part_cost, 0) as part_cost1
    , labor_cost1 + part_cost1 as wo_cost

from wo
left join time t
    on t.work_order_id = wo.work_order_id
left join part_cost_on_wo pcwo
    on pcwo.wo_id = wo.work_order_id;;
  }

  dimension: branch_id {
    type:  number
    value_format_name: id
    sql: ${TABLE}."BRANCH_ID" ;;
  }

  dimension: market_name  {
    type:  string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: work_order_id {
    type:  number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: asset_id  {
    type:  string
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension_group: date_completed {
      type: time
      timeframes: [
        raw,
        time,
        date,
        week,
        month,
        quarter,
        year
      ]
      sql: CAST(${TABLE}."DATE_COMPLETED" AS TIMESTAMP_NTZ) ;;
    }

  dimension: days_since_bought {
    type:  number
    sql: ${TABLE}."DAYS_SINCE_BOUGHT" ;;
  }

  dimension: make  {
    type:  string
    sql: ${TABLE}."MAKE" ;;
  }

  dimension: model  {
    type:  string
    sql: ${TABLE}."MODEL" ;;
  }

  dimension: class {
    type:  string
    sql: ${TABLE}."CLASS" ;;
  }

  dimension: regular_hours {
    type:  number
    sql: ${TABLE}."REGULAR_HOURS" ;;
  }

  dimension: overtime_hours {
    type:  number
    sql: ${TABLE}."OVERTIME_HOURS" ;;
  }

  dimension: labor_cost {
    type:  number
    sql: ${TABLE}."LABOR_COST1" ;;
  }

  dimension: part_cost {
    type:  number
    sql: ${TABLE}."PART_COST1" ;;
  }

  dimension: wo_cost {
    type:  number
    sql: ${TABLE}."WO_COST" ;;
  }

  measure: wo_count {
    type: count_distinct
    sql: ${work_order_id} ;;
  }

  measure: total_labor_cost {
    type: sum
    value_format_name: usd_0
    sql: ${labor_cost} ;;
  }

  measure: total_part_cost {
    type: sum
    value_format_name: usd_0
    sql: ${part_cost} ;;
  }

  measure: total_regular_hours {
    type: sum
    sql: ${regular_hours};;
  }

  measure: total_overtime_hours {
    type: sum

    sql: ${overtime_hours};;
  }

  measure: total_wo_cost {
    type: sum
    value_format_name: usd_0
    sql: ${wo_cost} ;;
  }

  measure: assets {
    type: count_distinct
    sql: ${asset_id} ;;
  }
  }
