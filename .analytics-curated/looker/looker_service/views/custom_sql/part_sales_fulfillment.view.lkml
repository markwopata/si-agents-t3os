view: part_sales_fulfillment {
  derived_table: {
    sql: with invoices as (
select
    i.invoice_id,
    i.invoice_no,
    i.invoice_date,
    i.date_created,
    to_number(li.number_of_units) as number_of_units,
    li.extended_data:part_id as the_part_id,
    u.branch_id
from es_warehouse.public.invoices i
join es_warehouse.public.line_items li
    on i.invoice_id = li.invoice_id
join es_warehouse.public.users u
    on i.created_by_user_id = u.user_id
where the_part_id is not null
and (i.billing_approved_date is null or i.sent ='FALSE')
and i.invoice_no not ilike '%deleted%'
)

,reservation_parts as (
select
    r.part_id,
    sp.store_part_id,
    iff(r.target_type_id = 1,r.quantity,0) as reserved_wo,
    iff(r.target_type_id = 2,r.quantity,0) as reserved_invoice,
    iff(r.target_type_id = 1,target_id,null) as work_order_id,
    iff(r.target_type_id = 2,target_id,null) as invoice_id,
    r.quantity as reserved
from es_warehouse.inventory.reservations r
join es_warehouse.inventory.store_parts sp
    on r.part_id = sp.part_id = r.store_id = sp.store_id
where date_completed is null
and date_cancelled is null
)

,on_order as (
select
    po.deliver_to_id as branch_id,
    p.part_id,
    sum(poli.quantity - total_accepted) as quantity_on_order
from procurement.public.purchase_orders po
join procurement.public.purchase_order_line_items poli
    on po.purchase_order_id = poli.purchase_order_id
join es_warehouse.inventory.parts p
    on poli.item_id = p.item_id
group by
    po.deliver_to_id,
    p.part_id
having quantity_on_order > 0
)

, last_vendor as (select
    po.deliver_to_id as branch_id,
    v.name last_vendor,
    p.part_id,
    max(po.date_created) over (partition by po.deliver_to_id,v.name,p.part_id) recent_po,
   -- sum(poli.quantity - total_accepted) as quantity_on_order
from procurement.public.purchase_orders po
join procurement.public.purchase_order_line_items poli
    on po.purchase_order_id = poli.purchase_order_id
join es_warehouse.inventory.parts p
    on poli.item_id = p.item_id
join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs --to get vendor id formatted like Vxxx
    on po.vendor_id = evs.entity_ID
join ANALYTICS.INTACCT.VENDOR v
on evs.EXTERNAL_ERP_VENDOR_REF=v.vendorid
where po.date_archived is null
and poli.date_archived is null
qualify recent_po=po.date_created)

,parts_in_stock as (
select
    sp.part_id,
    s.branch_id,
    sum(available_quantity) as quantity_in_stock
from es_warehouse.inventory.store_parts sp
join es_warehouse.inventory.stores s
    on sp.store_id = s.store_id
group by
    sp.part_id,
    s.branch_id
)
,current_wac as (select l.branch_id
, product_id part_id
, avg(weighted_average_cost) current_wac
from ES_WAREHOUSE.INVENTORY.WEIGHTED_AVERAGE_COST_SNAPSHOTS w
join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS l
on w.inventory_location_id=l.inventory_location_id
where w.is_current and l.date_archived is null
group by 1,2)
, sales_ids as (select --secondary
 s.invoice_id
, FALSE as primary_salesperson
, value as salesperson_id
from ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS s
, lateral flatten(INPUT => secondary_salesperson_ids)
union
select --primary
 invoice_id
 , TRUE as primary_salesperson
, primary_salesperson_id as salesperson_id
from ES_WAREHOUSE.PUBLIC.APPROVED_INVOICE_SALESPERSONS
order by invoice_id)
, salespeople as( select s.invoice_id, s.primary_salesperson, listagg(u.first_name||' '||u.last_name,', ') sales_people
from sales_ids s
join es_warehouse.public.users u
on salesperson_id=user_id
where u.company_id=1854
group by 1,2)
select
    i.invoice_id,
    i.invoice_no,
    i.invoice_date,
    i.date_created,
    i.branch_id,
    s1.sales_people primary_salesperson,
    s2.sales_people secondary_salesperson,
    i.the_part_id as part_id,
    w.current_wac,
    i.number_of_units,
    coalesce(rp.reserved_invoice,0) as reserved_invoice,
    rp.store_part_id,
    coalesce(pis.quantity_in_stock,0) as quantity_in_stock,
    coalesce(oo.quantity_on_order,0) as quantity_on_order,
    last_vendor --last vendor we purchased that part from at that branch
from invoices i
left join salespeople s1
on i.invoice_id=s1.invoice_id and s1.primary_salesperson='TRUE'
left join salespeople s2
on i.invoice_id=s2.invoice_id and s2.primary_salesperson='FALSE'
left join current_wac w
on i.branch_id=w.branch_id and i.the_part_id=w.part_id
left join reservation_parts rp
    on i.invoice_id = rp.invoice_id and i.the_part_id = rp.part_id
left join on_order oo
    on i.the_part_id = oo.part_id and i.branch_id = oo.branch_id
left join parts_in_stock pis
    on i.branch_id = pis.branch_id and i.the_part_id = pis.part_id
left join last_vendor lv
on i.the_part_id=lv.part_id and i.branch_id=lv.branch_id;;
  }
  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id }}" target="_blank"> {{rendered_value}} </a></font></u> ;;
  }
  dimension: invoice_number {
    type: string
    sql: ${TABLE}."INVOICE_NO" ;;
    html: <font color="blue "><u><a href="https://admin.equipmentshare.com/#/home/transactions/invoices/{{ invoice_id }}" target="_blank"> {{rendered_value}} </a></font></u> ;;
  }
  dimension_group: invoice_date {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."INVOICE_DATE" ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }
  dimension: primary_salesperson {
    type: string
    sql: ${TABLE}."PRIMARY_SALESPERSON" ;;
  }
  dimension: secondary_salesperson {
    type: string
    sql: ${TABLE}."SECONDARY_SALESPERSON" ;;
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }
  dimension: location_wac{
    type: number
    sql: ${TABLE}."CURRENT_WAC" ;;
    value_format_name: usd
  }
  dimension: units_on_invoice {
    type: number
    sql: ${TABLE}."NUMBER_OF_UNITS" ;;
  }
  dimension: units_reserved_for_invoice {
    type: number
    sql: ${TABLE}."RESERVED_INVOICE" ;;
  }
  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
    value_format_name: id
  }
  dimension: store_part_id_with_link_to_inventory {
    label: "Inventory"
    type: string
    sql: 'T3 Inventory' ;;
    html: <font color="blue "><u><a href="https://inventory.estrack.com/item/{{ store_part_id }}" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: units_in_stock {
    type: number
    sql: ${TABLE}."QUANTITY_IN_STOCK" ;;
  }
  dimension: units_on_order {
    type: number
    sql: ${TABLE}."QUANTITY_ON_ORDER" ;;
  }
  dimension: last_vendor {
    type: string
    sql: ${TABLE}."LAST_VENDOR" ;;
  }
}

view: parts_ordered_pos {
  derived_table: {
    sql: select
    po.purchase_order_id,
    po.purchase_order_number,
    po.date_created,
    evs.EXTERNAL_ERP_VENDOR_REF as vendor_id,
    po.deliver_to_id as branch_id,
    p.part_id,
    poli.quantity,
    poli.total_accepted,
    po.status po_status
from procurement.public.purchase_orders po
join procurement.public.purchase_order_line_items poli
    on po.purchase_order_id = poli.purchase_order_id
join es_warehouse.inventory.parts p
    on poli.item_id = p.item_id
left JOIN ES_WAREHOUSE.PURCHASES.ENTITIES e
    on po.vendor_ID = e.entity_ID
left join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs --to get vendor id formatted like Vxxx
    on e.entity_ID = evs.entity_ID
    where po.date_archived is null and poli.date_archived is null
    and po.status in ('OPEN','NEEDS_APPROVAL');;
}
  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
    primary_key: yes
    html: <font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id }}/detail" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    value_format_name: id
    html: <font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id }}/detail" target="_blank">{{rendered_value}}</a></font></u> ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw,date,month,quarter,year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }
  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: market_id {
    type: number
    sql: ${TABLE}."BRANCH_ID" ;;
    value_format_name: id
  }
  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
    value_format_name: id
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: quantity_accepted {
    type: number
    sql: ${TABLE}."TOTAL_ACCEPTED" ;;
  }
  dimension: quantity_on_order {
    type: number
    sql: ${quantity} - ${quantity_accepted} ;;
  }
  dimension: po_status {
    type: string
    sql: ${TABLE}."PO_STATUS" ;;
  }
  measure: units_on_order {
    type: sum
    sql: ${quantity_on_order} ;;
    filters: [quantity_on_order: ">0"]
    drill_fields: [purchase_order_id,
                  purchase_order_number,
                  po_status,
                  date_created_date,
                  vendor.name,
                  part_id,
                  parts.part_number,
                  providers.name,
                  quantity,
                  quantity_accepted,
                  quantity_on_order]
  }
}
