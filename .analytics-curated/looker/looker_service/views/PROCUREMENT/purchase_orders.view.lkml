view: purchase_orders {
  sql_table_name: "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" ;;
  drill_fields: [purchase_order_id]

  dimension: purchase_order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension: purchase_order_id_with_link {
    description: "Purchase Order Number with Link"
    label: "Purchase Order Number"
    type: string
    sql: ${purchase_order_id} ;;
    html: <a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id._value }}/detail" target="new" style="color: #0063f3; text-decoration: underline;">{{ purchase_order_number._value }}</a> ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: amount_approved {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension: cost_center_snapshot_id {
    type: string
    sql: ${TABLE}."COST_CENTER_SNAPSHOT_ID" ;;
  }
  dimension: created_by_id {
    type: number
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }
  dimension_group: date_archived {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_ARCHIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, month_name, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: date_created_quarter_label {
    type: string
    # sql: CAST(${date_created_year} AS VARCHAR) +  " Q" + CAST(${date_created_quarter} AS VARCHAR);;
    sql: CONCAT(${date_created_year}, 'Q', ${date_created_quarter}) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, month_name, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: deliver_to_id {
    type: number
    sql: ${TABLE}."DELIVER_TO_ID" ;;
  }
  dimension: deliver_to_snapshot_id {
    type: string
    sql: ${TABLE}."DELIVER_TO_SNAPSHOT_ID" ;;
  }
  dimension: external_po_id {
    type: string
    sql: ${TABLE}."EXTERNAL_PO_ID" ;;
  }
  dimension: is_external {
    type: yesno
    sql: ${TABLE}."IS_EXTERNAL" ;;
  }
  dimension: modified_by_id {
    type: number
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }
  dimension_group: promise {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."PROMISE_DATE" AS TIMESTAMP_NTZ) ;;
  }
  dimension: purchase_order_number {
    type: number
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
    value_format: "0"
    html:<a href="https://costcapture.estrack.com/purchase-orders/{{ purchase_order_id._value }}/detail" target="new" style="color: #0063f3; text-decoration: underline;">{{ purchase_order_number._value }}</a> ;;
  }
  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }
  dimension: notes {
    type: string
    case_sensitive: yes
    sql: ${TABLE}."REFERENCE" ;;
  }
  dimension: NDA {
    type: yesno
    sql: ${notes} LIKE '%NDA%' ;;
  }
  dimension: requesting_branch_id {
    type: number
    sql: ${TABLE}."REQUESTING_BRANCH_ID" ;;
  }
  dimension: search {
    type: string
    sql: ${TABLE}."SEARCH" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }
  dimension: vendor_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_snapshot_id {
    type: string
    sql: ${TABLE}."VENDOR_SNAPSHOT_ID" ;;
  }

  measure: sum_amount_approved_distinct {
    label: "Total Amount Approved"
    type: sum_distinct
    value_format_name: usd_0
    sql: ${amount_approved} ;;
  }

  measure: count {
    type: count
    drill_fields: [purchase_order_id, purchase_order_line_items.count, purchase_order_receivers.count]
  }

  measure: count_purchase_orders {
    label: "Count of Distinct Purchase Orders"
    type: count_distinct
    sql: ${purchase_order_id} ;;
    drill_fields: [po_detail_region*]
  }

  measure: count_distinct_vendor_id {
    label: "Number of Vendors"
    type: count_distinct
    sql: ${vendor_id} ;;
  }

  measure: count_purchase_orders_markets {
    type: count_distinct
    sql: ${purchase_order_id} ;;
    drill_fields: [po_detail_market*]
  }

  set: po_detail_region {
    fields: [
      market_region_xwalk.market_id,
      market_region_xwalk.market_name,
      ## fulfillment_center_markets.date_added_date,  This is causing more limited fields on the drills
      count_purchase_orders_markets
      ]
  }

  set: po_detail_market {
    fields: [
      purchase_order_number,
      users.full_name,
      purchase_order_line_items.quantity,
      purchase_order_line_items.price_per_unit,
      parts.part_id,
      parts.part_number,
      parts.part_name,
      providers.name,
      parts.msrp,
      date_created_date,
      purchase_order_line_items.allocation_type,
      market_region_xwalk.market_id,
      market_region_xwalk.market_name
    ]
  }
}
