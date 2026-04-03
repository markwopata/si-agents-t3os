
view: outside_hauling_po_no_delivery {
  derived_table: {
    sql: select
          po.purchase_order_id,
          po.purchase_order_number,
          po.search as po_description,
          po.date_created as po_date_created,
          po.vendor_id,
          v.vendorid as sage_vendor_id,
          v.name as vendor,
          po.created_by_id,
          po.requesting_branch_id as market_id,
          po.promise_date,
          po.amount_approved,
          mrx.region_name,
          mrx.district,
          mrx.market_name as market,
          listagg(poli.description, ' | ') line_descriptions
      from
          procurement.public.purchase_orders po
          join procurement.public.purchase_order_line_items poli
              on po.purchase_order_id = poli.purchase_order_id
          left join es_warehouse.public.deliveries d
              on po.purchase_order_id = d.purchase_order_id
          left join ( select
                          v.name,
                          e.entity_id,
                          v.vendorid
                      from ES_WAREHOUSE.PURCHASES.ENTITIES e
                      left join ES_WAREHOUSE.PURCHASES.ENTITY_VENDOR_SETTINGS evs
                          on e.entity_ID = evs.entity_ID
                      left join analytics.intacct.vendor v
                          on evs.EXTERNAL_ERP_VENDOR_REF = v.vendorid
                          ) v
              on po.vendor_id = v.entity_id
          left join analytics.public.market_region_xwalk mrx on mrx.market_id = po.requesting_branch_id
      where
          po.company_id = 1854
          and d.delivery_id is null
          and year(po.date_created) = year(current_date)
          and po.date_archived is null
          and poli.item_id in ('b417da8d-86f7-4907-83a5-db7b01d076c7','134cd1b9-b3da-45fd-a719-5da99496f4ed') -- outside hauling pos
          and amount_approved>0
      group by
          1,2,3,4,5,6,7,8,9,10,11,12,13,14
          ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
    value_format_name: id
  }

  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    value_format_name: id
  }

  dimension: po_description {
    label: "Purchase Order Description"
    type: string
    sql: ${TABLE}."PO_DESCRIPTION" ;;
  }

  dimension_group: po_date_created {
    type: time
    sql: ${TABLE}."PO_DATE_CREATED" ;;
  }

  dimension: vendor_id {
    type: number
    sql: ${TABLE}."VENDOR_ID" ;;
    value_format_name: id
  }

  dimension: sage_vendor_id {
    type: string
    sql: ${TABLE}."SAGE_VENDOR_ID" ;;
    value_format_name: id
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }

  dimension: market_id {
    type: number
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension_group: promise_date {
    type: time
    sql: ${TABLE}."PROMISE_DATE" ;;
  }

  dimension: amount_approved {
    type: number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
  }

  dimension: region_name {
    type: string
    sql: ${TABLE}."REGION_NAME" ;;
  }

  dimension: district {
    type: string
    sql: ${TABLE}."DISTRICT" ;;
  }

  dimension: market {
    type: string
    sql: ${TABLE}."MARKET" ;;
  }

  dimension: line_descriptions {
    type: string
    sql: ${TABLE}."LINE_DESCRIPTIONS" ;;
  }

  dimension: formatted_po_date_created {
    group_label: "HTML Formatted Date"
    label: "Purchase Order Date Created"
    type: date
    sql: ${po_date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  dimension: formatted_promise_date {
    group_label: "HTML Formatted Date"
    label: "Promise Date"
    type: date
    sql: ${promise_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y"  }};;
  }

  measure: total_amount_approved {
    type: sum
    sql: ${amount_approved} ;;
    value_format_name: usd
  }

  dimension: view_purchase_order {
    group_label: "Link to T3"
    label: "Purchase Order Number"
    type: string
    sql: ${purchase_order_number} ;;
    html: <font color="#0063f3 "><a href="https://costcapture.estrack.com/purchase-orders/{{purchase_order_id._value}}/detail"target="_blank">{{rendered_value}} ➔ </a></font> ;;
  }


  set: detail {
    fields: [
        purchase_order_id,
  purchase_order_number,
  po_description,
  po_date_created_time,
  vendor_id,
  sage_vendor_id,
  vendor,
  created_by_id,
  market_id,
  promise_date_time,
  amount_approved,
  line_descriptions
    ]
  }
}
