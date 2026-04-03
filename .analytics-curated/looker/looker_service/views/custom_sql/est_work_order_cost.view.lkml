view: est_work_order_cost {
  derived_table: {
    sql: with est_labor_hours as (
    select distinct wo.work_order_id
        , max(te.created_date) last_time_entry
        , sum(coalesce(te.REGULAR_HOURS,0)) as regular
        , sum(coalesce(te.overtime_hours,0)) as overtime
    from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    left join ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
        on wo.WORK_ORDER_ID = te.WORK_ORDER_ID
            and te.APPROVAL_STATUS like 'Approved'
            and te.NEEDS_REVISION = false
            and te.ARCHIVED = false
            and te.event_type_id = 1
    group by wo.work_order_id
)

, wo_trans AS
        (SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) AS wo_id
              , IFF(TRANSACTION_TYPE_ID = 7, t.FROM_ID, t.TO_ID) as store_id
              , wo.BRANCH_ID
              , ti.PART_ID                                       AS part_id
              , t.transaction_type_id                            AS transaction_type_id
              , t.TRANSACTION_ID
              , IFF(transaction_type_id = 7, ti.quantity_received, 0-ti.quantity_received)                  AS qty
              , ti.COST_PER_ITEM
          FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
          LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
              ON t.TRANSACTION_ID = ti.TRANSACTION_ID
          JOIN es_warehouse.WORK_ORDERS.WORK_ORDERS wo
              ON IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) = wo.WORK_ORDER_ID
          JOIN ES_WAREHOUSE.PUBLIC.MARKETS m
            on wo.BRANCH_ID = m.MARKET_ID
          LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c
            on m.COMPANY_ID = c.COMPANY_ID
          WHERE TRANSACTION_TYPE_ID IN (7, 9)
            AND qty is not null
            and date_cancelled is null
            AND qty > 0
            AND c.COMPANY_ID in (SELECT COMPANY_ID FROM ANALYTICS.PUBLIC.ES_COMPANIES)
)

, wo_trans_non_es AS
        (SELECT IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) AS wo_id
              , IFF(TRANSACTION_TYPE_ID = 7, t.FROM_ID, t.TO_ID) as store_id
              , wo.BRANCH_ID
              , ti.PART_ID                                       AS part_id
              , t.transaction_type_id                            AS transaction_type_id
              , t.TRANSACTION_ID
              , IFF(transaction_type_id = 7, ti.quantity_received, 0-ti.quantity_received)                  AS qty
              , ti.COST_PER_ITEM
          FROM ES_WAREHOUSE.INVENTORY.TRANSACTIONS t
          LEFT JOIN ES_WAREHOUSE.INVENTORY.TRANSACTION_ITEMS ti
              ON t.TRANSACTION_ID = ti.TRANSACTION_ID
          JOIN es_warehouse.WORK_ORDERS.WORK_ORDERS wo
              ON IFF(TRANSACTION_TYPE_ID = 7, t.TO_ID, t.FROM_ID) = wo.WORK_ORDER_ID
          JOIN ES_WAREHOUSE.PUBLIC.MARKETS m
            on wo.BRANCH_ID = m.MARKET_ID
          LEFT JOIN ES_WAREHOUSE.PUBLIC.COMPANIES c
            on m.COMPANY_ID = c.COMPANY_ID
          WHERE TRANSACTION_TYPE_ID IN (7, 9)
            AND qty is not null
            and date_cancelled is null
            AND qty > 0
)

, non_wac_wo_parts_cost AS (
    select wo_id
        ,  sum(qty * cost_per_item) as non_wac_parts_cost
    from wo_trans_non_es
    group by wo_id
)

, all_wo_parts AS (
    select wt.wo_id
        , wt.store_id
        , wt.part_id
        , sum(wt.qty) AS QTY
    from wo_trans wt
    group by wt.wo_id, wt.store_id, wt.part_id
)

, avg_cost_per_part_company_wide as (
    select product_id as part_id
        , round(avg(weighted_average_cost), 2) as average_cost_co
    from ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS
    where is_current = true
    group by part_id
)

, snap as (
    select current_part_id
        , round(avg(avg_cost), 2) as snap_avg_cost
    from ANALYTICS.PUBLIC.AVERAGE_COST_SNAPSHOT
    where snapshot_date = '2023-11-30'
    group by current_part_id
)

, avg_cost_wac as (
    select distinct aw.part_id
        , aw.store_id
        , snap.weighted_average_cost
        , snap.is_current
    from all_wo_parts aw
    left join ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS snap
        on aw.part_id = snap.product_id and aw.store_id = snap.inventory_location_id
    where is_current = true
)

, wo_part_cost_combo as (
    select aw.wo_id
        , aw.part_id
        , aw.QTY
        , coalesce(coalesce(v.weighted_average_cost, acppcw.average_cost_co), snap.snap_avg_cost) as average_cost
        , coalesce(aw.QTY * average_cost,0) as part_id_on_wo_cost
    from all_wo_parts aw
    left join avg_cost_wac v
        on aw.part_id = v.part_id and aw.store_id = v.store_id
    left join avg_cost_per_part_company_wide acppcw
        on acppcw.part_id = aw.part_id
    left join snap
        on snap.current_part_id = aw.part_id
)

, part_cost as (
    select wo_id, sum(coalesce(part_id_on_wo_cost,0)) as part_cost
    from wo_part_cost_combo
    group by wo_id
)

select wo.work_order_id
    , pc.part_cost
    , regular as regular_hours
    , overtime as overtime_hours
    , regular + overtime as total_hours
    , total_hours * 100 as labor_cost
    , zeroifnull(labor_cost) + zeroifnull(pc.part_cost) as work_order_cost
    , nwwpc.non_wac_parts_cost
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
left join part_cost pc
    on pc.wo_id = wo.work_order_id
left join est_labor_hours elh
    on elh.work_order_id = wo.work_order_id
left join non_wac_wo_parts_cost nwwpc
    on wo.work_order_id = nwwpc.wo_id;;
  }

dimension: work_order_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.work_order_id ;;
}

dimension: part_cost {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.part_cost ;;
}

  measure: total_part_cost {
    type: sum
    value_format_name: usd_0
    sql: ${part_cost};;
  }

dimension: non_wac_part_cost {
  type: number
  sql: ${TABLE}.non_wac_parts_cost ;;
  value_format_name: usd_0
}

measure: total_non_wac_part_cost {
  type: sum
  sql: ${non_wac_part_cost};;
  value_format_name: usd_0
}

dimension: regular_hours {
  type: number
  sql: ${TABLE}.regular_hours ;;
}

measure: total_regular_hours {
  type: sum
  sql: ${regular_hours} ;;
}

dimension: overtime_hours {
  type: number
  sql: ${TABLE}.overtime_hours ;;
}

measure: total_overtime_hours {
  type: sum
  sql: ${overtime_hours} ;;
}

dimension: hours {
  type: number
  sql: ${TABLE}.total_hours ;;
}

measure: total_hours {
  type: sum
  sql: ${hours} ;;
}

dimension: labor_cost {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.labor_cost ;;
}

  measure: total_labor_cost {
    type: sum
    value_format_name: usd_0
    sql: ${labor_cost} ;;
  }

dimension: work_order_cost {
  type: number
  value_format_name: usd_0
  sql: ${TABLE}.work_order_cost;;
}

  measure: total_cost {
    type: sum
    value_format_name: usd_0
    sql: ${work_order_cost} ;;
    drill_fields: [
      work_orders.date_completed_date,
      work_orders.work_order_id_with_link_to_work_order,
      work_orders.work_order_status_name,
      billing_types.name,
      markets.name,
      assets.make,
      work_orders.hours_at_service,
      time_entries.total_time_formatted,
      time_entries.estimated_labor,
      wo_parts_cost.est_parts_charge,
      assets.asset_id_wo_link,
      work_orders.work_order_url_text]
  }

  measure: mg_total_cost {
    type: sum
    value_format_name: usd_0
    sql: ${work_order_cost} ;;
    drill_fields: [mg_company.name,total_cost]
  }

  measure: mg_total_hours {
    type: sum
    sql: ${hours} ;;
    drill_fields: [mg_company.name,total_hours]
  }

  measure: mg_total_part_cost {
    type: sum
    value_format_name: usd_0
    sql: ${non_wac_part_cost};;
    drill_fields: [mg_company.name,total_non_wac_part_cost]
  }
}
