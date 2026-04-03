view: part_purchase_order_lookup {
  derived_table: {
    sql: select distinct il.name as store_name
    , m.market_name
    , m.district
    , m.region_name
    , po.purchase_order_number
    , po.purchase_order_id
    , po.date_created
    , po.vendor_id
    , e.name as vendor
    , p.PART_NUMBER
    , p.PART_ID
    , inv.invoice_number
    , inv.invoice_state
    , inv.url_invoice
    , inv.url_concur as bill_image_url
    , count(purchase_order_number, part_number) over (partition by purchase_order_number, part_number) as dupes
from ES_WAREHOUSE.INVENTORY.PARTS p -- get item_id
join PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS poli -- points me to correct receiver info
    on p.ITEM_ID = poli.ITEM_ID
left join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
    on po.purchase_order_id = poli.purchase_order_id
left join ES_WAREHOUSE.PURCHASES.ENTITIES e
    on e.entity_id = po.vendor_id
join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS pori -- needed to match t3_line_item_id
    on poli.PURCHASE_ORDER_LINE_ITEM_ID = pori.PURCHASE_ORDER_LINE_ITEM_ID
left join ES_WAREHOUSE.INVENTORY.INVENTORY_LOCATIONS il
    ON IL.INVENTORY_LOCATION_ID = po.store_id
join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
    on m.market_id = il.branch_id
left join (
    select distinct document_number
        , vendor_name
        , vendor_id
        , invoice_number
        , invoice_state
        , url_invoice
        , url_concur
    from "ANALYTICS"."INTACCT_MODELS"."AP_DETAIL"
    where account_number not in ('2008')
        and AP_HEADER_TYPE = 'apbill'
    ) inv
    on inv.document_number = po.purchase_order_number::STRING
qualify dupes = 1
 ;;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}.purchase_order_number ;;
  }

  dimension: link_to_purchase_order {
    type: string
    sql: ${TABLE}.purchase_order_id ;;
    html: <font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ rendered_value }}/detail" target="_blank">Purchase Order</a></font></u> ;;
  }

  dimension: vendor_id {
    type: number
    value_format_name: id
    sql: ${TABLE}.vendor_id ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}.vendor ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}.part_number ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}.part_id ;;
  }

dimension: invoice_number {
  type: string
  sql: ${TABLE}.invoice_number ;;
}

  dimension: invoice_state {
    type: string
    sql: ${TABLE}.invoice_state;;
  }

  dimension: link_to_invoice {
    type: string
    sql: ${TABLE}.BILL_IMAGE_URL ;;
    html: <font color="blue "><u><a href="{{ rendered_value }}" target="_blank">Invoice Link</a></font></u> ;;
  }

  dimension: store_name {
    type: string
    sql: ${TABLE}.store_name ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}.market_name ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}.region_name ;;
  }

  dimension: district_name {
    type: string
    sql: ${TABLE}.district ;;
  }

  dimension: date_created {
    type: date
    sql: ${TABLE}.date_created ;;
  }
}
