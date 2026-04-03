view: closed_pos_by_date_received {
  derived_table: {
    sql: SELECT
      po.purchase_order_number,
      po.date_created,
      r.date_received,
      po.promise_date,
      concat(u.first_name,' ',u.last_name) as created_by,
      concat(u2.first_name,' ',u2.last_name) as received_by,
      m.name as store,
      e.name as vendor,
      po.status,
      concat(ifnull(sum(ri.accepted_quantity),0),' of ',sum(li.quantity)) as quantity_recieved,
      sum (li.quantity*li.price_per_unit) as total_po_cost,
      po.search

      FROM PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS li
      join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po on po.purchase_order_id = li.purchase_order_id
      left join markets m on m.market_id = po.requesting_branch_id
      left join purchases.entities e on po.vendor_id = e.entity_id
      left join users u on u.user_id = po.created_by_id
      left join procurement.public.items it on it.item_id = li.item_id
      left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS ri on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
      left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS r on r.purchase_order_receiver_id = ri.purchase_order_receiver_id
      left join users u2 on u2.user_id = r.created_by_id


      where po.company_id = 60574
      AND r.date_received >= DATEADD('day', -59, CURRENT_DATE())
      AND po.status='CLOSED'
      AND po.date_archived is null
      AND it.date_archived is null
      AND po.PURCHASE_ORDER_NUMBER is not null

      GROUP BY
      po.company_id,
      po.purchase_order_number,
      po.date_created,
      r.date_received,
      po.promise_date,
      concat(u.first_name,' ',u.last_name),
      concat(u2.first_name,' ',u2.last_name),
      m.name,
      e.name,
      po.status,
      po.search
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

  dimension_group: date_created {
    label: "Date Created"
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_received {
    label: "Date Received"
    type: time
    sql: ${TABLE}."DATE_RECEIVED" ;;
  }

  dimension_group: promise_date {
    type: time
    sql: ${TABLE}."PROMISE_DATE" ;;
  }

  dimension: created_by {
    type: string
    sql: ${TABLE}."CREATED_BY" ;;
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

  dimension: quantity_recieved {
    type: string
    sql: ${TABLE}."QUANTITY_RECIEVED" ;;
  }

  dimension: total_po_cost {
    label: "Total Amount"
    type: number
    sql: ${TABLE}."TOTAL_PO_COST" ;;
    value_format_name: usd
  }

  dimension: search {
    label: "Notes"
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }

  set: detail {
    fields: [
      purchase_order_number,
      date_received_time,
      promise_date_time,
      created_by,
      store,
      vendor,
      status,
      quantity_recieved,
      total_po_cost,
      search
    ]
  }
}
