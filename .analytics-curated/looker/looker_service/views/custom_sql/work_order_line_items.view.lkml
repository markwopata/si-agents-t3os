view: work_order_line_items {
  derived_table: {
    sql: select pit.work_order_id
    , 'Parts' as work_order_line_type
    , pit.root_part_id as part_id
    , pit.part_number
    , sum(-pit.quantity) as number_of_units
    , number_of_units * coalesce(pit.weighted_average_cost, pit.cost_per_item) as Amount
from ANALYTICS.INTACCT_MODELS.PART_INVENTORY_TRANSACTIONS pit
join ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
    on pit.work_order_id = wo.work_order_id
join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
    on m.market_id = wo.branch_id
group by pit.work_order_id, pit.part_number, coalesce(pit.weighted_average_cost, pit.cost_per_item), pit.root_part_id
having number_of_units > 0

union

select distinct wo.work_order_id
    , 'Labor' as work_order_line_type
    , null as part_id
    , null as part_number
    , sum(coalesce(te.REGULAR_HOURS,0) + coalesce(te.overtime_hours,0)) as number_of_units
    , number_of_units * 100 as Amount
from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS wo
join ES_WAREHOUSE.TIME_TRACKING.TIME_ENTRIES te
    on wo.WORK_ORDER_ID = te.WORK_ORDER_ID
        and te.APPROVAL_STATUS like 'Approved'
        and te.NEEDS_REVISION = false
        and te.ARCHIVED = false
        and te.event_type_id = 1
join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
    on m.market_id = wo.branch_id
where wo.asset_id is not null
group by wo.work_order_id ;;
  }

 dimension: work_order_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.work_order_id ;;
 }

dimension: work_order_line_type {
  type: string
  sql: ${TABLE}.work_order_line_type ;;
}

dimension: part_number {
  type: string
  sql: ${TABLE}.part_number ;;
}

dimension: part_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.part_id ;;
}

dimension: number_of_units {
  type: number
  sql: ${TABLE}.number_of_units ;;
}

dimension: amount {
  type: number
  sql: ${TABLE}.amount ;;
  value_format_name: usd
}
}
