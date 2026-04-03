view: inventory_allocation {
  derived_table: {
    sql: select
    r.reservation_id,
    r.part_id,
    p.part_number,
    p.name as description,
    pr.provider_id,
    pr.name as provider,
    sp.store_part_id,
    s.branch_id as market_id,
    iff(r.target_type_id = 1,'Work Order','Invoice') as target_type,
    iff(r.target_type_id = 1,target_id,null) as work_order_id,
    iff(r.target_type_id = 2,target_id,null) as invoice_id,
    wacs.weighted_average_cost,
    iff(r.target_type_id = 1,r.quantity,0) as reserved_wo,
    iff(r.target_type_id = 2,r.quantity,0) as reserved_invoice,
    reserved_wo * wacs.weighted_average_cost as value_wo,
    reserved_invoice * wacs.weighted_average_cost as value_invoice
from es_warehouse.inventory.reservations r
join es_warehouse.inventory.stores s
    on r.store_id = s.store_id
join es_warehouse.inventory.inventory_locations il
    on il.branch_id = s.branch_id and default_location
join es_warehouse.inventory.weighted_average_cost_snapshots wacs
    on il.inventory_location_id = wacs.inventory_location_id and r.part_id = wacs.product_id and is_current
join es_warehouse.inventory.parts p
    on r.part_id = p.part_id
join es_warehouse.inventory.providers pr
    on p.provider_id = pr.provider_id
join es_warehouse.inventory.store_parts sp
    on r.part_id = sp.part_id and r.store_id = sp.store_id
where r.date_completed is null
and r.date_cancelled is null;;
  }
  dimension: reservation_id {
    type: number
    sql: ${TABLE}."RESERVATION_ID" ;;
    value_format: "0"
  }
  dimension: target_type {
    type: string
    sql: ${TABLE}."TARGET_TYPE" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
    value_format: "0"
  }
  dimension: work_order_id_with_link_to_work_order {
    label: "Work Order ID"
    type: string
    sql: ${work_order_id} ;;
    # html: <font color="blue "><u><a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="_blank">{{ work_order_id._value }}</a></font></u> ;;
    html: <a href="https://app.estrack.com/#/service/work-orders/{{ work_order_id._value }}" target="new" style="color: #0063f3; text-decoration: underline;">{{ work_order_id._value }}</a> ;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format: "0"
  }
  dimension: invoice_id_with_link_to_invoice {
    label: "Invoice ID"
    type: string
    sql: ${invoice_id} ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id._value }}" target="_blank">{{ invoice_id._value }}</a></font></u> ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format: "0"
  }
  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }
  dimension: provider_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.provider_id ;;
  }
  dimension: provider {
    type: string
    sql: ${TABLE}."PROVIDER" ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
    value_format: "0"
  }
  dimension: store_part_id_with_link_to_inventory {
    label: "Inventory"
    type: string
    sql: 'T3 Inventory' ;;
    html: <font color="blue "><u><a href="https://inventory.estrack.com/item/{{ store_part_id }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
    value_format: "0"
  }
  dimension: wac {
    type: number
    sql: ${TABLE}."WEIGHTED_AVERAGE_COST" ;;
    value_format_name: usd
  }
  dimension: reserved_for_wo {
    type: number
    sql: ${TABLE}."RESERVED_WO" ;;
    value_format: "0"
  }
  dimension: reserved_for_invoice {
    type: number
    sql: ${TABLE}."RESERVED_INVOICE" ;;
    value_format: "0"
  }
  dimension: value_wo {
    type: number
    sql: ${TABLE}."VALUE_WO" ;;
    value_format_name: usd_0
  }
  dimension: value_invoice {
    type: number
    sql: ${TABLE}."VALUE_INVOICE" ;;
    value_format_name: usd_0
  }
  measure: reserve_for_work_order {
    type: sum
    sql: ${reserved_for_wo} ;;
  }
  measure: reserve_for_invoice {
    type: sum
    sql: ${reserved_for_invoice} ;;
  }
  measure: reserve_for_work_order_value_market {
    type: sum
    sql: ${value_wo} ;;
    value_format_name: usd_0
  }
  measure: reserve_for_invoice_value_market {
    type: sum
    sql: ${value_invoice} ;;
    value_format_name: usd_0
  }
  measure: reserve_for_work_order_value {
    type: sum
    sql: ${value_wo} ;;
    value_format_name: usd_0
    drill_fields: [wo_drill*]
  }
  measure: reserve_for_invoice_value {
    type: sum
    sql: ${value_invoice} ;;
    value_format_name: usd_0
    drill_fields: [invoice_drill*]
  }
  measure: avg_cost {
    type: average
    sql: ${wac} ;;
    value_format_name: usd
  }
  set: wo_drill {
    fields: [
      total_inventory_allocation.selected_hierarchy_dimension,
      part_number,
      description,
      provider,
      reserve_for_work_order,
      reserve_for_work_order_value_market,
      avg_cost,
      work_order_id_with_link_to_work_order,
      store_part_id_with_link_to_inventory
      ]
  }
  set: invoice_drill {
    fields: [
      total_inventory_allocation.selected_hierarchy_dimension,
      part_number,
      description,
      provider,
      reserve_for_invoice,
      reserve_for_invoice_value_market,
      avg_cost,
      invoice_id_with_link_to_invoice,
      store_part_id_with_link_to_inventory
    ]
  }
}
