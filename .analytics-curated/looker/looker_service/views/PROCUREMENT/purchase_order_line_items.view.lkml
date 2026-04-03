view: purchase_order_line_items {
  sql_table_name: "PROCUREMENT"."PUBLIC"."PURCHASE_ORDER_LINE_ITEMS" ;;
  drill_fields: [purchase_order_line_item_id]

  dimension: purchase_order_line_item_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_LINE_ITEM_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: allocation_id {
    type: string
    sql: ${TABLE}."ALLOCATION_ID" ;;
  }
  dimension: allocation_snapshot_id {
    type: string
    sql: ${TABLE}."ALLOCATION_SNAPSHOT_ID" ;;
  }
  dimension: allocation_type {
    type: string
    sql: ${TABLE}."ALLOCATION_TYPE" ;;
  }
  dimension_group: date_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }
  dimension: item_id {
    type: string
    sql: ${TABLE}."ITEM_ID" ;;
  }
  dimension: item_snapshot_id {
    type: string
    sql: ${TABLE}."ITEM_SNAPSHOT_ID" ;;
  }
  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }
  dimension: price_per_unit {
    type: number
    sql: ${TABLE}."PRICE_PER_UNIT" ;;
  }
  dimension: purchase_order_id {
    type: string
    # hidden: yes
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }
  dimension: total_accepted {
    type: number
    sql: ${TABLE}."TOTAL_ACCEPTED" ;;
  }
  dimension: total_rejected {
    type: number
    sql: ${TABLE}."TOTAL_REJECTED" ;;
  }
  measure: sum_quantity {
    type: sum
    label: "Total Number of Parts"
    sql: ${quantity};;
  }
  measure: sum_accepted {
    type: sum
    label: "Number of Parts Accepted"
    sql: ${total_accepted} ;;
  }
  measure: sum_rejected {
    type: sum
    label: "Number of Parts Rejected"
    sql: ${total_rejected} ;;
  }
  measure: price_per_order {
    hidden: yes
    type: sum
    label: "Cost"
    value_format_name: usd
    sql: ${price_per_unit}*${quantity} ;;
    drill_fields: [po_line_item_detail_region*]
  }
  measure: cost_detail_drill {
    type: sum
    label: "Cost"
    value_format_name: usd
    sql: ${price_per_unit}*${quantity} ;;
    drill_fields: [po_line_item_detail_market*]
  }
  measure: count_allocated_line_items {
    description: "Count of Allocated Line Items."
    type: count
    # sql: ${allocation_type} ;;
    filters: [allocation_type: "-STOCK"]
  }
  measure: count_line_items {
    type: count
  }
  measure: allocated_percentage {
    description: "Percentage of Total Parts Ordered."
    type: number
    value_format_name: percent_1
    html: {{count_allocated_line_items._rendered_value}} Allocated Parts | {{sum_quantity._rendered_value}} of Total Parts Ordered;;
    sql: ${count_allocated_line_items} / ${count_line_items} ;;
  }

  measure: count_region_drills {
    type: count
    label: "Number of parts ordered" #this is not number of parts ordered, this is a count of POLI. taking this out of drills - HL 2.25.25
    drill_fields: [po_line_item_detail_region*]
  }
  measure: count_market_drills {
    hidden: yes
    type: count
    drill_fields: [po_line_item_detail_market*]
  }
  set: po_line_item_detail_region {
    fields: [
            market_region_xwalk.market_name,
            cost_detail_drill
            ]
  }
  set: po_line_item_detail_market {
    fields: [
            market_region_xwalk.market_name,
            parts.part_number,
            parts.part_name,
            purchase_orders.purchase_order_number,
            purchase_orders.date_created_date,
            price_per_unit,
            quantity,
            price_per_order
            ]
  }

  # Service Outside Labor Joins


}
view: allocated_po_lines { #adding view to avoid causing issues in other explores from referencing pit join
  extends: [purchase_order_line_items]
  measure: count_line_items_to_transaction {
    type: count_distinct
    sql: ${purchase_order_line_item_id} ;;
    filters: [part_inventory_transactions_b.transaction_id:"NOT NULL"]
  }
  measure: perc_allocated_reaching_destination {
    type: number
    html: {{perc_allocated_reaching_destination._rendered_value}} of Allocated Lines seen on WO or Invoice;;
    sql: ${count_line_items_to_transaction}/nullifzero(${count_allocated_line_items}) ;;
    value_format_name: percent_2
  }
}
view: parts_ordered_on_deadstock {
  extends: [purchase_order_line_items]
  dimension: deadstock_status_flag {
    sql:
    case
      when ${parts.part_id} in (select part_id from ${deadstock_status_aggregate.SQL_TABLE_NAME} where ${purchase_orders.date_created_date} = ${deadstock_status_aggregate.snapdate_date} and ${quantity}<=${deadstock_status_aggregate.total_in_inventory} and ${deadstock_status_aggregate.part_id} = ${parts.part_id} ) then 'dead'
      else null
      end ;;
  }
  measure: dead_spent_amount {
    label: "$ Spent On Items In Dead Stock"
    type: sum
    value_format_name: usd_0
    html: {{dead_spent_amount._rendered_value}} | {{percentage_of_deadstock._rendered_value}} of Total Spend;;
    filters: [deadstock_status_flag: "dead"]
    sql: ${price_per_unit}*${quantity} ;;
    drill_fields: [po_line_item_detail_region*]
  }
  measure: percentage_of_deadstock {
    type: number
    value_format_name: percent_1
    # what we've spent on the purchase orders that is in deadstock / total purchase orders spent
    sql:${dead_spent_amount} / ${price_per_order};;
  }
}
