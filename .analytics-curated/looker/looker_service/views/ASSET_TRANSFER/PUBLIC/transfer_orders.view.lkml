view: transfer_orders {
  sql_table_name: "ASSET_TRANSFER"."PUBLIC"."TRANSFER_ORDERS" ;;
  drill_fields: [transfer_order_id]

  dimension: transfer_order_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."TRANSFER_ORDER_ID" ;;
  }
  dimension: transfer_order_id_link {
    label: "Transfer Order Number"
    type: string
    sql: ${transfer_order_id} ;;
    html: <a href=https://asset-transfers.estrack.com/transfer-details/{{transfer_order_id._value}}" target="new" style="color: #0063f3; text-decoration: underline;">{{transfer_order_number._value}}</a> ;;
  }
  dimension_group: _es_load_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_LOAD_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: _es_update_timestamp {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."_ES_UPDATE_TIMESTAMP" AS TIMESTAMP_NTZ) ;;
  }
  dimension: approver_id {
    type: number
    sql: ${TABLE}."APPROVER_ID" ;;
  }
  dimension: approver_note {
    type: string
    sql: ${TABLE}."APPROVER_NOTE" ;;
  }
  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }
  dimension: cancellation_note {
    type: string
    sql: ${TABLE}."CANCELLATION_NOTE" ;;
  }
  dimension: cancelled_by_id {
    type: number
    sql: ${TABLE}."CANCELLED_BY_ID" ;;
  }
  dimension: company_id {
    type: number
    sql: ${TABLE}."COMPANY_ID" ;;
  }
  dimension_group: date_approved {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_APPROVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_CREATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_received {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_RECEIVED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_rejected {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_REJECTED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_request_cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_REQUEST_CANCELLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_transfer_cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_TRANSFER_CANCELLED" AS TIMESTAMP_NTZ) ;;
  }
  dimension_group: date_updated {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: CAST(${TABLE}."DATE_UPDATED" AS TIMESTAMP_NTZ) ;;
  }
  dimension: from_branch_id {
    type: number
    sql: ${TABLE}."FROM_BRANCH_ID" ;;
  }
  dimension: is_closed {
    type: yesno
    sql: ${TABLE}."IS_CLOSED" ;;
  }
  dimension: is_rental_transfer {
    type: yesno
    sql: ${TABLE}."IS_RENTAL_TRANSFER" ;;
  }
  dimension: received_by_id {
    type: number
    sql: ${TABLE}."RECEIVED_BY_ID" ;;
  }
  dimension: requester_id {
    type: number
    sql: ${TABLE}."REQUESTER_ID" ;;
  }
  dimension: requester_note {
    type: string
    sql: ${TABLE}."REQUESTER_NOTE" ;;
  }
  dimension: status {
    type: string
    sql: ${TABLE}."STATUS" ;;
  }
  dimension: to_branch_id {
    type: number
    sql: ${TABLE}."TO_BRANCH_ID" ;;
  }
  dimension: transfer_order_number {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRANSFER_ORDER_NUMBER" ;;
  }
  dimension: transfer_type_id {
    type: number
    sql: ${TABLE}."TRANSFER_TYPE_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [transfer_order_id]
  }
  measure: distinct_count {
    type: count_distinct
    sql: ${TABLE}."TRANSFER_ORDER_ID" ;;
    drill_fields: [transfer_order_number,date_created_date,date_received_date,asset_id,dim_assets_fleet_opt.asset_equipment_make, dim_assets_fleet_opt.asset_equipment_model_name, dim_assets_fleet_opt.asset_year, dim_assets_fleet_opt.asset_current_oec, dim_assets_fleet_opt.asset_current_net_book_value, all_equipment_rouse_estimates.predicted_auction,asset_scoring.score ]
  }
}
