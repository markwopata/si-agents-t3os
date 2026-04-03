view: parts_to_work_order {
  derived_table: {
    sql: with items_for_wo as (
      select
          wo.work_order_id,
          p.part_number,
          pt.description,
          sum(ti.quantity_ordered) as quantity_ordered,
          max(ti.cost_per_item) as cost_per_item
      from
          inventory.transactions t
          join inventory.transaction_items ti on t.transaction_id = ti.transaction_id
          left join inventory.parts p on p.part_id = ti.part_id
          left join inventory.part_types pt on p.part_type_id = pt.part_type_id
          join work_orders.work_orders wo on wo.work_order_id = t.to_id
      where
          t.transaction_status_id = 5 AND t.transaction_type_id = 7 AND t.date_cancelled is null AND {% condition work_order_filter %} wo.work_order_id {% endcondition %}
          --AND p.part_id = 106272
      group by
          wo.work_order_id,
          p.part_number,
          pt.description
      )
      , items_sent_back_to_store as (
      ------
      select
          wo.work_order_id,
          p.part_number,
          pt.description,
          sum(ti.quantity_ordered) as quantity_sent_back,
          max(ti.cost_per_item) as cost_per_item
      from
          inventory.transactions t
          join inventory.transaction_items ti on t.transaction_id = ti.transaction_id
          left join inventory.parts p on p.part_id = ti.part_id
          left join inventory.part_types pt on p.part_type_id = pt.part_type_id
          join work_orders.work_orders wo on wo.work_order_id = t.from_id
      where
          t.transaction_status_id = 5 AND t.transaction_type_id = 9 AND t.date_cancelled is null AND {% condition work_order_filter %} wo.work_order_id {% endcondition %}
          --AND p.part_id = 106272
      group by
          wo.work_order_id,
          p.part_number,
          pt.description
      )
      select
          ifw.work_order_id,
          ifw.part_number,
          ifw.description,
          (ifw.quantity_ordered - coalesce(isb.quantity_sent_back,0)) as quantity_ordered,
          ifw.cost_per_item,
          ((ifw.quantity_ordered - coalesce(isb.quantity_sent_back,0)) * ifw.cost_per_item) as parts_total_cost
      from
          items_for_wo ifw
          left join items_sent_back_to_store isb on ifw.work_order_id and isb.work_order_id and ifw.part_number = isb.part_number
      where
          parts_total_cost > 0
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: work_order_id {
    type: number
    sql: ${TABLE}."WORK_ORDER_ID" ;;
  }

  dimension: part_number {
    type: string
    sql: ${TABLE}."PART_NUMBER" ;;
  }

  dimension: description {
    type: string
    sql: ${TABLE}."DESCRIPTION" ;;
  }

  dimension: quantity_ordered {
    type: number
    sql: ${TABLE}."QUANTITY_ORDERED" ;;
  }

  dimension: cost_per_item {
    type: number
    sql: ${TABLE}."COST_PER_ITEM" ;;
    value_format_name: usd
  }

  dimension: parts_total_cost {
    type: number
    sql: ${TABLE}."PARTS_TOTAL_COST" ;;
  }

  measure: total_parts_cost {
    label: "Total Parts Cost"
    type: sum
    sql: ${parts_total_cost} ;;
    value_format_name: usd
  }

  filter: work_order_filter {
  }

  set: detail {
    fields: [part_number, description, quantity_ordered, cost_per_item, parts_total_cost]
  }
}
