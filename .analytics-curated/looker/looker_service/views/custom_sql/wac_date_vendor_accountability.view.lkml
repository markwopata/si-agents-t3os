view: wac_date_vendor_accountability {
  derived_table: {
    sql: with wac_prep as (
    select
        wacs.*
    from es_warehouse.inventory.weighted_average_cost_snapshots wacs
    where wacs.date_applied::date <= '2024-03-31'
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
    and tran.SNAPSHOT_DATE::date <= '2024-03-31'
    group by
        p.master_part_id
)

,wac_prep_date as (
    select
        wacs.*
    from es_warehouse.inventory.weighted_average_cost_snapshots wacs
    where wacs.date_applied::date <= {% parameter wac_dated %}
    qualify row_number()
        over (partition by wacs.inventory_location_id, wacs.product_id, date_applied order by wacs.date_created desc) = 1
    and max(date_applied)
        over (partition by wacs.PRODUCT_ID, INVENTORY_LOCATION_ID order by wacs.date_applied desc) = date_applied
    order by
        wacs.product_id,
        wacs.INVENTORY_LOCATION_ID,
        wacs.date_applied desc
)

,wac_final_date as (
    select
        k.MASTER_PART_ID as part_id,
        avg(wp.WEIGHTED_AVERAGE_COST) avg_cost_master_cw
    from wac_prep_date wp
    join ANALYTICS.PARTS_INVENTORY.PARTS k -- superceded loop logic
        on wp.PRODUCT_ID = k.PART_ID
    join ES_WAREHOUSE.INVENTORY.PARTS p
        on wp.PRODUCT_ID = p.PART_ID
    where wp.WEIGHTED_AVERAGE_COST not in (0, 0.01)
    group by
        k.MASTER_PART_ID
)

,parts_ordered as (
    select
        mp.master_part_id as part_id,
        ven.vendorid as vendor_id,
        ven.name as vendor_name,
        sum(poli.quantity) as purchase_quantity
    from procurement.public.purchase_orders po
    join procurement.public.purchase_order_line_items poli
        on po.purchase_order_id = poli.purchase_order_id
  join ES_WAREHOUSE.INVENTORY.PARTS p
  on poli.item_id = p.item_id
    join analytics.parts_inventory.parts mp
        on p.part_id=mp.part_id
    left JOIN ES_WAREHOUSE.PURCHASES.ENTITIES e
        on po.vendor_ID = e.entity_ID
    left join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs --to get vendor id formatted like Vxxx
        on e.entity_ID = evs.entity_ID
    left join analytics.intacct.vendor ven
        on evs.EXTERNAL_ERP_VENDOR_REF = ven.vendorid
    where  date(po.date_created) between {% date_start date_filter %} and {% date_end date_filter %}
    and po.date_archived is null
    and poli.date_archived is null
    group by
        mp.master_part_id,
        ven.vendorid,
        ven.name
)

select
    p.part_id,
    po.vendor_id,
    po.vendor_name,
    p.part_id||po.vendor_id pkey,
    po.purchase_quantity,
    to_number(coalesce(wf.avg_cost_master_cw,acpp.avg_cost_snap),10,2) as wac3_31,
    to_number(wd.avg_cost_master_cw,10,2) as wac_date
from  ES_WAREHOUSE.INVENTORY.PARTS p
left join wac_final wf
on p.part_id=wf.part_id
left join avg_cost_per_part acpp
    on p.part_id = acpp.part_id
left join wac_final_date wd
    on p.part_id = wd.part_id
//left join avg_cost_per_part_date acppd
//    on wf.part_id = acppd.part_id
left join parts_ordered po
    on p.part_id = po.part_id;;
  }
  dimension: pkey {
    type: string
    primary_key: yes
    sql: ${TABLE}."PKEY";;
  }
  parameter: wac_dated {
    type: date
  }
  filter: date_filter {
    type: date
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format: "0"
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_name {
    type: string
    sql: ${TABLE}."VENDOR_NAME" ;;
  }
  dimension: wac3_31 {
    type: number
    sql: ${TABLE}."WAC3_31" ;;
    value_format: "$0.00"
  }
  dimension: wac_date {
    type: number
    sql: ${TABLE}."WAC_DATE" ;;
    value_format: "$0.00"
  }
  dimension: wac_changed {
    type: yesno
    sql: ${wac3_31} != ${wac_date} ;;
  }
  dimension: purchase_quantity {
    type: number
    sql: ${TABLE}."PURCHASE_QUANTITY" ;;
  }
  dimension: net_price_savings {
    type: number
    sql: ${purchase_quantity} * (${wac3_31} - ${net_price.net_price}) ;;
    value_format: "$0.00"
  }
  # dimension: part_mapping_savings {
  #   type: number
  #   sql: ${purchase_quantity} * (coalesce(${net_price_map.net_price},${wac_date_vendor_accountability_map.wac_date}) - coalesce(${net_price.net_price},${wac_date})) ;;
  #   value_format: "$0.00"
  # }
  measure: total_net_price_savings {
    type: sum
    sql: ${net_price_savings} ;;
    value_format: "$0.00"
  }
  # measure: total_part_mapping_savings {
  #   type: sum
  #   sql: ${part_mapping_savings} ;;
  #   value_format: "$0.00"
  # }
}
