view: v_wo_parts {
  sql_table_name: "ANALYTICS"."SERVICE"."V_WO_PARTS"
    ;;

  parameter: asset_branch_type {
    type: unquoted
    default_value: "Rental"
    allowed_value: {
      label: "Rental Branch"
      value: "rental"
    }
    allowed_value: {
      label: "Service Branch"
      value: "service"
    }
    allowed_value: {
      label: "Inventory Branch"
      value: "inventory"
    }
  }

  dimension: asset_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."ASSET_ID" ;;
  }

  dimension: asset_parent_category {
    type: string
    sql: ${TABLE}."ASSET_PARENT_CATEGORY" ;;
  }

  dimension: asset_sub_category {
    type: string
    sql: ${TABLE}."ASSET_SUB_CATEGORY" ;;
  }

  dimension: asset_class {
    type: string
    sql: ${TABLE}."ASSET_CLASS" ;;
  }

  dimension: avg_cost {
    type: number
    sql: ${TABLE}."AVG_COST" ;;
  }

  dimension: part_category {
    type: string
    sql: ${TABLE}."PART_CATEGORY" ;;
  }

  dimension: part_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: part_name {
    type: string
    case_sensitive: no
    sql: ${TABLE}."PART_NAME" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: provider_name {
    type: string
    sql: ${TABLE}."PROVIDER_NAME" ;;
  }

  dimension: quantity {
    type: number
    sql: ${TABLE}."QUANTITY" ;;
  }

  dimension_group: transaction_date {
    type: time
    timeframes: [date, time, week, month, year]
    sql: ${TABLE}."TRANSACTION_DATE" ;;
  }

  dimension: rental_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."RENTAL_BRANCH_ID" ;;
  }

  dimension: service_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."SERVICE_BRANCH_ID" ;;
  }

  dimension: inventory_branch_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."INVENTORY_BRANCH_ID" ;;
  }

  dimension: transaction_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: cost_per_item {
    type: number
    sql: ${TABLE}."COST_PER_ITEM" ;;
  }

  dimension: work_order_id {
    type: number
    value_format_name: id
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  # - - - - - MEASURES - - - - -

  measure: total_cost {
    type: sum
    sql: ${quantity} * ${cost_per_item} ;;
  }

  measure: total_quantity {
    type: sum
    sql: ${quantity} ;;
    drill_fields: [work_orders.work_order_id_with_link_to_work_order, billing_types.name ,transaction_id, transaction_date_time, asset_id, part_name, quantity, cost_per_item]
  }

  measure: count_work_orders {
    type: count_distinct
    sql: ${work_order_id} ;;
    drill_fields: [work_orders.work_order_id_with_link_to_work_order
      , billing_types.name
        , work_orders.date_created_date
        , work_orders.date_completed_date
        , work_orders.description
        , work_orders.severity_level_name
        , asset_id
        , work_orders.hours_at_service
        , work_orders.mileage_at_service
        , part_name
        , quantity
        , cost_per_item]
  }

  measure: count {
    type: count
    drill_fields: [part_name]
  }
}
