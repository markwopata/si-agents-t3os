view: part_demand_wac {
  derived_table: {
    sql: with wac_prep as (
select
    wacs.*,
    k.master_part_id as part_id
from es_warehouse.inventory.weighted_average_cost_snapshots wacs
join ANALYTICS.PARTS_INVENTORY.PARTS k -- superceded loop logic
    on wacs.PRODUCT_ID = k.PART_ID
-- where wacs.date_applied::date <= '2024-03-31'
qualify row_number()
    over (partition by wacs.inventory_location_id, wacs.product_id, date_applied order by wacs.date_created desc) = 1
and max(date_applied)
    over (partition by wacs.PRODUCT_ID, INVENTORY_LOCATION_ID order by wacs.date_applied desc) = date_applied
order by
    wacs.product_id,
    wacs.INVENTORY_LOCATION_ID,
    wacs.date_applied desc
)

,wac_final as (
select
    k.MASTER_PART_ID as part_id,
    avg(wp.WEIGHTED_AVERAGE_COST) avg_cost_master_cw
from wac_prep wp
join ANALYTICS.PARTS_INVENTORY.PARTS k -- superceded loop logic
    on wp.PRODUCT_ID = k.PART_ID
join ES_WAREHOUSE.INVENTORY.PARTS p
    on wp.PRODUCT_ID = p.PART_ID
where wp.WEIGHTED_AVERAGE_COST not in (0, 0.01)
group by
    k.MASTER_PART_ID
)

,avg_cost_per_part as (
select
    p.master_part_id as part_id,
    sum(tran.amount) / sum(tran.quantity) as avg_cost_snap
from ANALYTICS.PUBLIC.AVERAGE_COST_TRANSACTIONS tran
join analytics.parts_inventory.parts p
    on tran.CURRENT_PART_ID = p.part_id
where tran.contribute_to_avg_flag = true --only want transaction types that are considered valid
and tran.cost > 0--no part costs nothing, suppressing data entry errors
and tran.cost is not null--no part costs nothing, suppressing data entry errors
and tran.quantity > 0--if there's no quantity, there shouldn't be a transaction; i cannot divide by zero
-- and tran.SNAPSHOT_DATE::date <= '2024-03-31'
group by
    p.master_part_id
)

-- ,final_wac as (
select
    wf.part_id,
    coalesce(wf.avg_cost_master_cw,acpp.avg_cost_snap) as wac
from wac_final wf
left join avg_cost_per_part acpp
    on wf.part_id = acpp.part_id
order by wf.part_id;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format: "0"
  }
  dimension: wac {
    type: number
    sql: ${TABLE}."WAC" ;;
    value_format: "$0.00"
  }
}

view: recent_po_info {
  derived_table: {
    sql: with parts_ordered as (
select
    po.requesting_branch_id as market_id,
    p.master_part_id as part_id,
    sum(poli.quantity - (poli.total_accepted + poli.total_rejected)) as quantity_in_route
from procurement.public.purchase_orders po
left join procurement.public.purchase_order_line_items poli
    on po.purchase_order_id = poli.purchase_order_id
      left join es_warehouse.inventory.parts og
  on poli.item_id=og.item_id
  left join analytics.parts_inventory.parts p
    on og.part_id = p.part_id
where po.status = 'OPEN'
and poli.date_archived is null
and p.master_part_id is not null
group by
    po.requesting_branch_id,
    p.master_part_id
)

,most_recent_price as (
select
    p.master_part_id as part_id,
    po.requesting_branch_id as market_id,
    po.date_created,
    poli.price_per_unit
from procurement.public.purchase_orders po
left join procurement.public.purchase_order_line_items poli
    on po.purchase_order_id = poli.purchase_order_id
  left join es_warehouse.inventory.parts og
  on poli.item_id=og.item_id
  left join analytics.parts_inventory.parts p
    on og.part_id = p.part_id
qualify row_number() over (partition by p.master_part_id,po.requesting_branch_id order by po.date_created desc) = 1
)

select
    mrp.*,
    po.quantity_in_route,
    row_number() over (partition by mrp.part_id order by mrp.date_created desc) as recent_order,
    iff(mrp.market_id=38653,true,false) fc_order
from most_recent_price mrp
left join parts_ordered po
    on mrp.part_id = po.part_id
    and mrp.market_id = po.market_id
    left join es_warehouse.public.markets m
    on mrp.market_id=m.market_id
    where m.company_id=1854
;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format: "0"
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }
  dimension: part_market_id {
    type: string
    sql: concat(${part_id},'-',${market_id}) ;;
    primary_key: yes
  }
  dimension: quantity_on_order {
    type: number
    sql: ${TABLE}."QUANTITY_IN_ROUTE" ;;
  }
  measure: sum_quantity_on_order {
    type: sum
    sql: ${quantity_on_order} ;;
  }
  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
    value_format: "$0.00"
  }
  dimension: recent_order {
    type: number
    sql: ${TABLE}."RECENT_ORDER" ;;
  }

  measure: recent_purchase_price {
    type: sum
    sql: ${price_per_unit} ;;
    value_format: "$0.00"
    filters: [recent_order: "1"]
  }
  dimension: part_transactions {
    type: string
    sql: 'Transactions' ;;
    link: {
      label: "Parts Transactions"
      url: "https://equipmentshare.looker.com/dashboards/540?Status=&Part+Number={{ parts.part_number }}&Date+Created={{ _filters['part_demand.date_completed_date'] | url_encode }}&Part+Category=&Transaction+Type=&To+ID=&From+ID=&Transaction+ID=&Manufacturer={{ providers.name._filterable_value }}&District={{ _filters['part_demand.district_name'] | url_encode }}&Region={{ _filters['part_demand.region_name'] | url_encode }}&Market={{ _filters['part_demand.market_name'] | url_encode }}&Part+Description=&Store+Name=&Part+ID=&Transaction+Group+ID=&Created+by+User=&Modified+by+User=&Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}"
    }
  }
  dimension: parts_sales {
    type: string
    sql: 'Sales' ;;
    link: {
      label: "Parts Sales"
      url: "https://equipmentshare.looker.com/dashboards/1117?Market+Name={{ _filters['part_demand.market_name'] | url_encode }}&Part+Number={{ parts.part_number }}&Line+Item+Type=&Salesperson+Employee+ID=&Salesperson+Name=&Customer=&Selected+Period={{ _filters['part_demand.date_completed_date'] | url_encode }}&Market+Type={{ _filters['market_region_xwalk.market_type'] | url_encode }}"
    }
  }
  # dimension: parts_pos {
  #   type: string
  #   sql: 'POs' ;;
  #   link: {
  #     label: "CostCapture POs"
  #     url: "https://equipmentshare.looker.com/dashboards/525?Vendor+ID=&Po+Date={{ _filters['part_demand.date_completed_date'] | url_encode }}&Part+Number={{ parts.part_number }}&Deliver+to+Branch=&Requesting+Branch={{ _filters['market_region_xwalk.market_name_and_id'] | url_encode }}&Name=&Created+By=&Price+per+Unit=&Po+Number=&Po+Status=&Item+Name=&Amount=&Item+Type=&Accepted+Quantity=&Memo=&Description=&Date+Archived=null"
  #   }
  # }
}

view: fc_open_po_info {
  derived_table: {
    sql:select *
    from ${recent_po_info.SQL_TABLE_NAME}
    where fc_order;;
    }
  dimension: part_id {
    type: number
    primary_key: yes
    sql: ${TABLE}."PART_ID" ;;
    value_format: "0"
  }
  measure: fc_sum_quantity_on_order {
    type: sum
    sql: ${TABLE}."QUANTITY_IN_ROUTE" ;;
  }
  }
