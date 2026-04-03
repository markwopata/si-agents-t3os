view: external_labor_on_warranty_work_orders {
  derived_table: {
    sql:
  select distinct po.purchase_order_number
    , po.purchase_order_id
    , iff(po.reference ilike '%W%O%'
        , regexp_replace(UPPER(po.reference), '[^a-zA-Z0-9]+', '')
        , null)  as formatted_reference --PO Reference
    , regexp_replace(iff(formatted_reference ilike '%WO%' and formatted_reference not ilike '%WORK%'
        , substr(formatted_reference, position('WO', formatted_reference), 9)
        , substr(formatted_reference, position('WORKORDER', formatted_reference), 16)), '[A-Z]') as reference_work_order_id

    , iff(poli.memo ilike '%W%O%'
        , regexp_replace(UPPER(poli.memo), '[^a-zA-Z0-9]+', '')
        , null)  as formatted_memo --Line Item Memo
    , regexp_replace(iff(formatted_memo ilike '%WO%' and formatted_memo not ilike '%WORK%'
        , substr(formatted_memo, position('WO', formatted_memo), 9)
        , substr(formatted_memo, position('WORKORDER', formatted_memo), 16)), '[A-Z]') as memo_work_order_id

    , coalesce(iff(reference_work_order_id = '', null, reference_work_order_id), memo_work_order_id) as po_work_order_id
    , m.market_id --join to xwalk
    , po.date_created
    , po.vendor_id
    , e.name as vendor
    , inv.invoice_number
    , inv.invoice_state
    , inv.url_invoice
    , inv.url_concur as bill_image_url
from PROCUREMENT.PUBLIC.PURCHASE_ORDERS po
join PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS poli
    on poli.purchase_order_id = po.purchase_order_id
join (
        select item_id --External labor!
        from PROCUREMENT.PUBLIC.NON_INVENTORY_ITEMS
        where item_id = 'd6fd484c-da57-4e62-a2c5-9a2d0202ffdb'
    ) nii
    on nii.item_id = poli.item_id
join (
        select work_order_id
        from ES_WAREHOUSE.WORK_ORDERS.WORK_ORDERS
        join ANALYTICS.PUBLIC.MARKET_REGION_XWALK m
            on m.market_id = branch_id
        where archived_date is null
            and billing_type_id = 1 --warranty
    ) wo
    on wo.work_order_id::STRING = po_work_order_id
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
left join ES_WAREHOUSE.PURCHASES.ENTITIES e
    on e.entity_id = po.vendor_id
where po.reference ilike '%W%O%' or poli.memo ilike '%W%O%' ;;
}

dimension: purchase_order_number {
  type: string
  sql: ${TABLE}.purchase_order_number  ;;
}

dimension: link_to_purchase_order {
  type: string
  sql: ${TABLE}.purchase_order_id ;;
  html: <font color="blue "><u><a href="https://costcapture.estrack.com/purchase-orders/{{ rendered_value }}/detail" target="_blank">Purchase Order</a></font></u> ;;
}

dimension: work_order_id {
  type: string
  sql: ${TABLE}.po_work_order_id ;;
}

dimension: market_id {
  type: number
  value_format_name: id
  sql: ${TABLE}.market_id ;;
}

dimension: date_created {
  type: date
  sql: ${TABLE}.date_created ;;
}

dimension: vendor {
  type: string
  sql: ${TABLE}.vendor ;;
}

dimension: invoice_number {
  type: string
  sql: ${TABLE}.invoice_number ;;
}

dimension: invoice_state {
  type: string
  sql: ${TABLE}.invoice_state ;;
}

dimension: link_to_invoice {
  type: string
  sql: ${TABLE}.BILL_IMAGE_URL ;;
  html: <font color="blue "><u><a href="{{ rendered_value }}" target="_blank">Invoice Link</a></font></u> ;;
}
}
