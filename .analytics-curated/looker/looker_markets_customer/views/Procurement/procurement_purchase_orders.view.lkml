
view: procurement_purchase_orders {
  sql_table_name: procurement.public__silver.procurement_purchase_orders ;;


  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: amount_approved {
    type: number
    sql: ${TABLE}."AMOUNT_APPROVED" ;;
    value_format_name: usd_0
  }

  dimension: company_id {
    type: string
    sql: ${TABLE}."COMPANY_ID" ;;
  }

  dimension: cost_center_snapshot_id {
    type: string
    sql: ${TABLE}."COST_CENTER_SNAPSHOT_ID" ;;
  }

  dimension: created_by_id {
    type: string
    sql: ${TABLE}."CREATED_BY_ID" ;;
  }

  dimension_group: date_archived {
    type: time
    sql: ${TABLE}."DATE_ARCHIVED" ;;
  }

  dimension: html_date_archived {
    group_label: "HTML Formatted Date"
    label: "Date Archived"
    sql: ${date_archived_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: html_date_created {
    group_label: "HTML Formatted Date"
    label: "Date Created"
    sql: ${date_created_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: html_date_updated {
    group_label: "HTML Formatted Date"
    label: "Date Updated"
    sql: ${date_updated_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: deliver_to_id {
    type: string
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
    type: string
    sql: ${TABLE}."MODIFIED_BY_ID" ;;
  }

  dimension_group: promise_date {
    type: time
    sql: ${TABLE}."PROMISE_DATE" ;;
  }

  dimension: html_promise_date {
    group_label: "HTML Formatted Date"
    label: "Promise Date"
    sql: ${promise_date_date} ;;
    html: {{ rendered_value | date: "%b %d, %Y" }};;
  }

  dimension: purchase_order_number {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_NUMBER" ;;
  }

  dimension: purchase_order_number_link {
    group_label: "Purchase Order Number - Link"
    label: "PO Number"
    type: string
    sql: ${purchase_order_number} ;;
    html:<font color="#0063f3"><a href="//costcapture.estrack.com/purchase-orders/{{purchase_order_id._value}}/detail "target="_blank">
    {{rendered_value}} ➔</a>;;
  }

  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
  }

  dimension: requesting_branch_id {
    type: string
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
    type: string
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: vendor_id {
    type: string
    sql: ${TABLE}."VENDOR_ID" ;;
  }

  dimension: vendor_snapshot_id {
    type: string
    sql: ${TABLE}."VENDOR_SNAPSHOT_ID" ;;
  }

  dimension_group: _purchase_orders_effective_start_utc_datetime {
    type: time
    sql: ${TABLE}."_PURCHASE_ORDERS_EFFECTIVE_START_UTC_DATETIME" ;;
  }

  dimension_group: _purchase_orders_effective_delete_utc_datetime {
    type: time
    sql: ${TABLE}."_PURCHASE_ORDERS_EFFECTIVE_DELETE_UTC_DATETIME" ;;
  }

  set: detail {
    fields: [
        purchase_order_id,
  amount_approved,
  company_id,
  cost_center_snapshot_id,
  created_by_id,
  date_archived_time,
  date_created_time,
  date_updated_time,
  deliver_to_id,
  deliver_to_snapshot_id,
  external_po_id,
  is_external,
  modified_by_id,
  promise_date_time,
  purchase_order_number,
  reference,
  requesting_branch_id,
  search,
  status,
  store_id,
  vendor_id,
  vendor_snapshot_id,
  _purchase_orders_effective_start_utc_datetime_time,
  _purchase_orders_effective_delete_utc_datetime_time
    ]
  }
}
