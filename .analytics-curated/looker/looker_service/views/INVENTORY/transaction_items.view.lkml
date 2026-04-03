view: transaction_items {
  derived_table: {
    sql: select ti.*, weighted_average_cost,
    transaction_type_id,
         IFF(TRANSACTION_TYPE_ID = 9, COST_PER_ITEM * -1, COST_PER_ITEM) * QUANTITY_RECEIVED as total_cost
         ,  IFF(TRANSACTION_TYPE_ID = 9, weighted_average_cost * -1, weighted_average_cost) * QUANTITY_RECEIVED as wac_total_cost
        , tel.part_id telematics_part
        from ES_WAREHOUSE.INVENTORY.transaction_items ti
        inner join es_warehouse.inventory.transactions t
        on ti.transaction_id = t.transaction_id
        left join ANALYTICS.PARTS_INVENTORY.TELEMATICS_PART_IDS tel
        on ti.part_id=tel.part_id
        left join es_warehouse.inventory.weighted_average_cost_snapshots w
        on w.product_id =ti.part_id
        and w.inventory_location_id =  IFF(TRANSACTION_TYPE_ID = 9, to_id,from_id)
        where (w.is_current
and weighted_average_cost>.01) or weighted_average_cost is null


      ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension_group: _es_update_timestamp {
    type: time
    sql: ${TABLE}."_ES_UPDATE_TIMESTAMP" ;;
  }

  dimension_group: date_created {
    type: time
    sql: ${TABLE}."DATE_CREATED" ;;
  }

  dimension_group: date_updated {
    type: time
    sql: ${TABLE}."DATE_UPDATED" ;;
  }

  dimension: transaction_item_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ITEM_ID" ;;
    primary_key: yes
  }

  dimension: transaction_id {
    type: number
    sql: ${TABLE}."TRANSACTION_ID" ;;
  }

  dimension: part_id {
    type: string
    sql: ${TABLE}."PART_ID" ;;
  }

  dimension: quantity_ordered {
    type: number
    sql: ${TABLE}."QUANTITY_ORDERED" ;;
  }

  dimension: quantity_received {
    type: number
    sql: ${TABLE}."QUANTITY_RECEIVED" ;;
  }

  dimension: cost_per_item {
    type: number
    sql: ${TABLE}."COST_PER_ITEM" ;;
  }

  dimension: item_status_id {
    type: number
    sql: ${TABLE}."ITEM_STATUS_ID" ;;
  }

  dimension: created_by {
    type: number
    sql: ${TABLE}."CREATED_BY" ;;
  }

  dimension: modified_by {
    type: number
    sql: ${TABLE}."MODIFIED_BY" ;;
  }

  dimension: total_cost {
    type: number
    sql: ${TABLE}."TOTAL_COST" ;;
  }

  measure: parts_total_cost {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
    drill_fields: [market_region_xwalk.market_name,
      part_types.description,
      parts.part_number,
      quantity_ordered,
      parts_total_cost]
    # drill_fields: [work_order_detail*]
    link: {
      label: "Parts by Market Name and Manufacturer"
      url: "{{ link }}&sorts=market_region_xwalk.market_name,parts.part_number"
    }
  }

  measure: total_part_cost{
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
    # drill_fields: [work_order_detail*]
  }

  measure: parts_total_cost_hierarchy_drill {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
    drill_fields: [market_region_xwalk.selected_hierarchy_dimension,
      parts.part_number,
      part_types.description,
      quantity_ordered,
      total_part_cost]
    # link: {
    #   label: "Parts by Market Name and Manufacturer"
    #   url: "{{ link }}&sorts=market_region_xwalk.market_name,parts.part_number"
    # }
  }

  measure: parts_total_cost_wo_drill {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
    drill_fields: [work_order_detail*]
    link: {
      label: "Parts by Market Name and Manufacturer"
      url: "{{ link }}&sorts=market_region_xwalk.market_name,parts.part_number"
    }
  }

  measure: parts_total_cost_monthly {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
    drill_fields: [date_created_month, parts_total_cost_monthly]
  }

  measure: total_parts_quantity {
    type: sum
    sql: ${quantity_ordered} ;;
    drill_fields: [work_order_detail*]
  }

  measure: parts_warranty_cost {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
    filters: [work_orders.billing_type_id: "1"]
    drill_fields: [work_order_detail*]
  }

  measure: parts_customer_cost {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
    filters: [billing_types.billing_type_id: "2"]
    drill_fields: [work_order_detail*]
  }

  measure: parts_internal_cost {
    type: sum
    sql: ${total_cost} ;;
    value_format_name: usd_0
    filters: [billing_types.billing_type_id: "3"]
    drill_fields: [work_order_detail*]
  }

  # Defined by Shayne as a 10% markup. https://app.shortcut.com/businessanalytics/story/107149/add-estimated-dollar-amount-to-total-of-all-closed-customer-damages-not-billed
  measure: estimated_parts_cost {
    type: sum
    sql: ${total_cost} * 1.1;;
    value_format_name: usd
    drill_fields: [work_order_detail*]
  }

  set: work_order_detail {
    fields: [
      market_region_xwalk.market_name,
      work_orders.work_order_id_with_link_to_work_order,
      billing_types.name,
      parts.part_number,
      part_types.description,
      quantity_ordered,
      parts_total_cost
    ]
  }

  set: detail {
    fields: [
      _es_update_timestamp_time,
      date_created_time,
      date_updated_time,
      transaction_item_id,
      transaction_id,
      part_id,
      quantity_ordered,
      quantity_received,
      cost_per_item,
      item_status_id,
      created_by,
      modified_by,
      total_cost
    ]
  }

  set: work_order_detail_2 {
    fields: [
      market_region_xwalk.market_name,
      work_orders.work_order_id_with_link_to_work_order,
      billing_types.name,
      parts.part_number,
      part_types.description,
      quantity_received,
      to_wo_cost
    ]
  }

set: wo_detail_3 {  fields: [
    market_region_xwalk.market_name,
    work_orders.work_order_id_with_link_to_work_order,
    billing_types.name,
    parts.part_number,
    part_types.description,
    current_wac,
    parts_to_wo,
    parts_wo_cost
  ]}
  dimension: transaction_type_id {
    type: number
    sql: ${TABLE}."TRANSACTION_TYPE_ID" ;;
    value_format:"$#,##0.00"
  }
 dimension: wac_total_cost {
   type: number
  sql: ${TABLE}."WAC_TOTAL_COST" ;;
 }
measure: parts_wo_cost {
  type: sum
  sql: ${current_wac} *iff(${transaction_type_id} = 7, ${quantity_received}, 1-${quantity_received}) ;;
  value_format:"$#,##0.00"
  drill_fields: [wo_detail_3*]
}
#multiple can come through since this is store level
dimension: current_wac {
  type: number
  sql: ${TABLE}."WEIGHTED_AVERAGE_COST" ;;
  value_format:"$#,##0.00"
}
# doing an avg of what is coming through
measure: average_wac {
  type:average
  sql: ${current_wac};;
  value_format:"$#,##0.00"
  }

  measure: parts_to_wo {
    type: sum
    sql: iff(${transaction_type_id} = 7, ${quantity_received}, 1-${quantity_received}) ;;
    drill_fields: [work_order_detail_2*]
  }

  measure: to_wo_cost {
    label: "Part Cost"
    type: sum
    sql: ${cost_per_item} * iff(${transaction_type_id} = 7, ${quantity_received}, 0) ;;
    value_format:"$#,##0.00"
    drill_fields: [work_order_detail_2*]
  }
 # adding to be able to filter out
  dimension: telematics_part {
    type: string
    sql: ${TABLE}."TELEMATICS_PART" ;;
  }
}
