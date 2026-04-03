view: po_items_by_receipt_date {
  derived_table: {
    sql: SELECT
      po.purchase_order_number,
      r.date_received,
      concat(u.first_name,' ',u.last_name) as received_by,
      m.name as store,
      e.name as vendor,
      po.status,
      li.description as line_item_description,
      li.quantity as quantity_ordered,
      sum(ri.accepted_quantity) as accepted_quantity,
      sum(ri.rejected_quantity) as rejected_quantity,
      sum(li.quantity * li.price_per_unit) as total_amount,
      li.memo

      FROM PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS li
      join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po on po.purchase_order_id = li.purchase_order_id
      left join markets m on m.market_id = po.requesting_branch_id
      left join purchases.entities e on po.vendor_id = e.entity_id
      left join procurement.public.items it on it.item_id = li.item_id
      left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS ri on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
      left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS r on r.purchase_order_receiver_id = ri.purchase_order_receiver_id
      left join users u on u.user_id = r.created_by_id

      where po.company_id = 60574
      AND r.date_received >= DATEADD('day', -59, CURRENT_DATE())
      --AND po.status='CLOSED'
      AND po.date_archived is null
      AND it.date_archived is null
      AND po.PURCHASE_ORDER_NUMBER is not null

      GROUP BY
      po.company_id,
      po.purchase_order_number,
      r.date_received,
      concat(u.first_name,' ',u.last_name),
      m.name,
      e.name,
      po.status,
      po.search,
      li.quantity,
      li.description,
      li.memo
      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_number {
    label: "PO Number"
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension_group: date_received {
    type: time
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension: received_by {
    type: string
    sql: ${TABLE}."RECEIVED_BY" ;;
  }

  dimension: store {
    type: string
    sql: ${TABLE}."STORE" ;;
  }

  dimension: vendor {
    type: string
    sql: ${TABLE}."VENDOR" ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }

  dimension: line_item_description {
    label: "Item/Service"
    type: string
    sql: ${TABLE}."LINE_ITEM_DESCRIPTION" ;;
  }

  dimension: quantity_ordered {
    type: number
    sql: ${TABLE}."QUANTITY_ORDERED" ;;
  }

  dimension: accepted_quantity {
    type: number
    sql: ${TABLE}."ACCEPTED_QUANTITY" ;;
  }

  dimension: rejected_quantity {
    type: number
    sql: ${TABLE}."REJECTED_QUANTITY" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension: total_amount {
    type: number
    sql: ${TABLE}."TOTAL_AMOUNT" ;;
    value_format_name: usd
  }

  set: detail {
    fields: [
      purchase_order_number,
      date_received_time,
      received_by,
      store,
      vendor,
      status,
      line_item_description,
      quantity_ordered,
      accepted_quantity,
      rejected_quantity,
      memo
    ]
  }
}
