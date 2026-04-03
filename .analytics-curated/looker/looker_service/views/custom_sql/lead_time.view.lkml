view: lead_time {
  derived_table: {
    sql: select po.purchase_order_number
, po.date_created
, r.date_received
, datediff(days,po.date_created,coalesce(r.date_received,current_date())) as lead_time
, li.price_per_unit
, li.quantity
, li.TOTAL_ACCEPTED
, ri.accepted_quantity
, p.part_id
, p.part_number
, pt.description
, pr.name as provider
, pr.provider_id
, e.name as vendor
, po.vendor_id
, po.REQUESTING_BRANCH_ID
from PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS li
left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS ri
on li.purchase_order_line_item_id = ri.purchase_order_line_item_id
left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS r
on ri.purchase_order_receiver_id = r.purchase_order_receiver_id
join ES_WAREHOUSE.INVENTORY.PARTS p
on li.item_id = p.item_id
left join ES_WAREHOUSE.INVENTORY.PROVIDERS pr
on p.provider_id=pr.provider_id
join ES_WAREHOUSE.INVENTORY.PART_TYPES pt
on p.PART_TYPE_ID = pt.PART_TYPE_ID
join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
on r.purchase_order_id=po.purchase_order_id
left JOIN ES_WAREHOUSE.PURCHASES.ENTITIES e
on po.vendor_ID = e.entity_ID
where po.purchase_order_number != 321858 --obvious mistake
and po.date_archived is null
and ri.created_by_id not in (21758,125944)
;;
}

dimension: back_ordered {
  type: yesno
  sql: ${TABLE}."LEAD_TIME" >= 14 and ${received} = 'no' ;;
}

dimension: cost_per_part {
  type: number
  sql: ${TABLE}."PRICE_PER_UNIT" ;;
}

dimension: lead_time_in_days {
  type: number
  sql: ${TABLE}."LEAD_TIME" ;;
}

  dimension: market_id {
    type: number
    sql: ${TABLE}."REQUESTING_BRANCH_ID" ;;
  }

dimension: part_id {
  type: number
  sql: ${TABLE}."PART_ID" ;;
}

dimension: part_manufacturer {
  type: string
  sql: ${TABLE}."PROVIDER" ;;
}

dimension: part_manufacturer_id {
  type: number
  sql: ${TABLE}."PROVIDER_ID" ;;
}

dimension: part_number {
  type: string
  sql: ${TABLE}."PART_NUMBER" ;;
}

dimension: po_number {
  type: number
  value_format_name: id
  sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
}

dimension: quantity_ordered {
  type: number
  sql: ${TABLE}."QUANTITY" ;;
}

dimension: received {
  type: yesno
  sql: ${TABLE}."TOTAL_ACCEPTED" = ${TABLE}."QUANTITY" ;;
}

dimension: total_accepted {
  type: number
  sql: ${TABLE}."TOTAL_ACCEPTED" ;;
}

dimension: vendor {
  type: string
  sql: ${TABLE}."VENDOR" ;;
}

dimension: vendor_id {
  type: number
  sql: ${TABLE}."VENDOR_ID" ;;
}

dimension_group: date_ordered {
  type: time
  timeframes: [raw, date, week, month, quarter, year]
  sql: ${TABLE}."DATE_CREATED" ;;
}

measure: average_lead_time {
  type: average
  value_format_name: decimal_0
  sql: ${TABLE}."LEAD_TIME" ;;
}

}
