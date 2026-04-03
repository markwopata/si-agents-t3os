view: purchase_orders {
  sql_table_name: "PROCUREMENT"."PUBLIC"."PURCHASE_ORDERS" ;;
  drill_fields: [purchase_order_id]

  dimension: purchase_order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: amount_approved {
    type: number
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
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
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
  }
  dimension: reference {
    type: string
    sql: ${TABLE}."REFERENCE" ;;
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
    sql: ${TABLE}."VENDOR_ID" ;;
  }
  dimension: vendor_snapshot_id {
    type: string
    sql: ${TABLE}."VENDOR_SNAPSHOT_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [purchase_order_id]
  }
}
