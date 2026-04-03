view: part_inventory_transactions_b {
  sql_table_name: "INTACCT_MODELS"."PART_INVENTORY_TRANSACTIONS" ;;

  dimension: pk_part_inventory_transactions_id {
    primary_key: yes
    type: string
    sql: ${TABLE}."PK_PART_INVENTORY_TRANSACTIONS_ID" ;;
  }

  dimension: amount {
    type: number
    value_format_name: usd
    sql: ${TABLE}."AMOUNT" ;;
  }

  dimension: cost {
    type: number
    sql: ${TABLE}."COST" ;;
  }

  dimension: cost_per_item {
    type: number
    sql: ${TABLE}."COST_PER_ITEM" ;;
  }

  dimension: created_by_user_id {
    type: number
    sql: ${TABLE}."CREATED_BY_USER_ID" ;;
  }

  dimension: created_by_username {
    type: string
    sql: ${TABLE}."CREATED_BY_USERNAME" ;;
  }

  dimension: custom_id {
    type: string
    sql: ${TABLE}."CUSTOM_ID" ;;
  }

  dimension_group: date_cancelled {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CANCELLED" ;;
  }

  dimension_group: date_completed {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_COMPLETED" ;;
  }

  dimension_group: date_created {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: from_id {
    type: number
    sql: ${TABLE}."FROM_ID" ;;
  }

  dimension: from_uuid_id {
    type: string
    sql: ${TABLE}."FROM_UUID_ID" ;;
  }

  dimension: invoice_id {
    type: number
    sql: ${TABLE}."INVOICE_ID" ;;
  }

  dimension: manual_adjustment_id {
    type: number
    sql: ${TABLE}."MANUAL_ADJUSTMENT_ID" ;;
  }

  dimension: manual_adjustment_reason {
    type: string
    sql: ${TABLE}."MANUAL_ADJUSTMENT_REASON" ;;
  }

  dimension: manual_adjustment_reason_id {
    type: number
    sql: ${TABLE}."MANUAL_ADJUSTMENT_REASON_ID" ;;
  }

  dimension: market_id {
    type: string
    sql: ${TABLE}."MARKET_ID" ;;
  }

  dimension: market_name {
    type: string
    sql: ${TABLE}."MARKET_NAME" ;;
  }

  dimension: memo {
    type: string
    sql: ${TABLE}."MEMO" ;;
  }

  dimension_group: month_ {
    type: time
    timeframes: [raw, time, date, week, month, quarter, year]
    sql: ${TABLE}."MONTH_" ;;
  }

  dimension: part_id {
    type: number
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: purchase_order_id {
    type: string
    sql: ${TABLE}."PURCHASE_ORDER_ID" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension: quantity_ordered {
    type: number
    sql: ${TABLE}."QUANTITY_ORDERED" ;;
  }

  dimension: rental_id {
    type: number
    sql: ${TABLE}."RENTAL_ID" ;;
  }

  dimension: root_part_description {
    type: string
    sql: ${TABLE}."ROOT_PART_DESCRIPTION" ;;
  }

  dimension: root_part_id {
    type: number
    sql: ${TABLE}."ROOT_PART_ID" ;;
  }

  dimension: root_part_number {
    type: string
    sql: ${TABLE}."ROOT_PART_NUMBER" ;;
  }

  dimension: split_from {
    type: number
    sql: ${TABLE}."SPLIT_FROM" ;;
  }

  dimension: src {
    type: string
    sql: ${TABLE}."SRC" ;;
  }

  dimension: store_id {
    type: number
    sql: ${TABLE}."STORE_ID" ;;
  }

  dimension: store_name {
    type: string
    case_sensitive: no
    sql: ${TABLE}."STORE_NAME" ;;
  }

  dimension: store_part_cost_id {
    type: number
    sql: ${TABLE}."STORE_PART_COST_ID" ;;
  }

  dimension: store_part_id {
    type: number
    sql: ${TABLE}."STORE_PART_ID" ;;
  }

  dimension: to_id {
    type: number
    sql: ${TABLE}."TO_ID" ;;
  }

  dimension: to_uuid_id {
    type: string
    sql: ${TABLE}."TO_UUID_ID" ;;
  }

  dimension: transaction_group_id {
    type: number
    sql: ${TABLE}."TRANSACTION_GROUP_ID" ;;
    value_format_name: id
  }

  dimension: transaction_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: transaction_item_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ITEM_ID" ;;
  }

  dimension: transaction_status {
    type: string
    sql: ${TABLE}."TRANSACTION_STATUS" ;;
  }

  dimension: transaction_type {
    type: string
    sql: ${TABLE}."TRANSACTION_TYPE" ;;
  }

  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
  }

  dimension: updated_by_user_id {
    type: number
    sql: ${TABLE}."UPDATED_BY_USER_ID" ;;
  }

  dimension: updated_by_user_name {
    type: string
    sql: ${TABLE}."UPDATED_BY_USER_NAME" ;;
  }

  dimension: url_admin {
    type: string
    sql: ${TABLE}."URL_ADMIN" ;;
  }

  dimension: url_t3 {
    type: string
    sql: ${TABLE}."URL_T3" ;;
  }

  dimension: wac_extended_amount {
    type: number
    sql: ${TABLE}."WAC_EXTENDED_AMOUNT" ;;
  }

  dimension: wac_snapshot_id {
    type: number
    sql: ${TABLE}."WAC_SNAPSHOT_ID" ;;
  }

  dimension: weighted_average_cost {
    type: number
    sql: ${TABLE}."WEIGHTED_AVERAGE_COST" ;;
  }
  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }
  measure: count {
    type: count
    drill_fields: [pk_part_inventory_transactions_id, updated_by_user_name, market_name, store_name, created_by_username]
  }
  measure: count_distinct_transactions {
    label: "Count of Transactions"
    type: count_distinct
    drill_fields: [transaction_detail_market*]
    sql: ${pk_part_inventory_transactions_id} ;;
  }
  measure: number_of_items {
    type: sum
    sql: ${quantity} ;;
    drill_fields: [transaction_details*]
  }
  measure: total_value {
    type: sum
    value_format_name: usd
    sql: ${cost_per_item}*${quantity};;
  }
  #Used for an absolute value on Corporate Parts Dashboard - Inventory Adjustments - Outgoing transactions.
  measure: abs_total_value {
    type: sum
    value_format_name: usd
    sql: abs(${cost_per_item}*${quantity});;
  }
  # measure: number_of_transfers { ## specific to DC transfers, needs work
    # type: count
    # sql: ${pk_part_inventory_transactions_id} ;;
    # drill_fields: [transaction_id, part_number, quantity]
  # }

  set: transaction_detail_region {
    fields: [
            market_region_xwalk.market_name,
            count_distinct_transactions,
            total_value
            ]
  }
  set: transaction_detail_market {
    fields: [
            market_name,
            transaction_id,
            transaction_type,
            part_number,
            description,
            date_completed_date,
            quantity,
            amount,
            created_by_username,
            work_order_id
            ]
  }
  set: transaction_details {
    fields: [
            market_name,
            transaction_id,
            transaction_type,
            part_number,
            description,
            date_completed_date,
            quantity,
            cost_per_item,
            created_by_username,
            work_order_id
            ]
  }
}
