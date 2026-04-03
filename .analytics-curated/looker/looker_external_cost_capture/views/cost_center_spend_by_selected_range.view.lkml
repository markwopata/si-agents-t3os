view: cost_center_spend_by_selected_range {
  derived_table: {
    sql: select
        m.name as cost_center,
        sum(li.quantity*li.price_per_unit) as total_po_cost
      from
          PROCUREMENT.PUBLIC.PURCHASE_ORDER_LINE_ITEMS li
          join PROCUREMENT.PUBLIC.PURCHASE_ORDERS po on po.purchase_order_id = li.purchase_order_id
          left join markets m on m.market_id = po.requesting_branch_id
          left join districts d on d.district_id = m.district_id
          left join regions r on r.region_id = d.region_id
          left join purchases.entities e on po.vendor_id = e.entity_id
          left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVER_ITEMS ri on ri.purchase_order_line_item_id = li.purchase_order_line_item_id
          left join PROCUREMENT.PUBLIC.PURCHASE_ORDER_RECEIVERS r on r.purchase_order_receiver_id = ri.purchase_order_receiver_id
      where
          {% if view_by._parameter_value == "'Date Created'" %}
          po.date_created BETWEEN convert_timezone('UTC', {% date_start date_filter %}::timestamp_ntz) AND convert_timezone('UTC', {% date_end date_filter %}::timestamp_ntz)
          {% else %}
          r.date_received BETWEEN convert_timezone('UTC', {% date_start date_filter %}::timestamp_ntz) AND convert_timezone('UTC', {% date_end date_filter %}::timestamp_ntz)
          {% endif %}
          AND po.date_archived is null
          AND li.date_archived is null
          AND {% condition cost_center_filter %} m.name {% endcondition %}
          AND {% condition region_filter %} r.name {% endcondition %}
          AND {% condition district_filter %} d.name {% endcondition %}
          AND {% condition status_filter %} po.status {% endcondition %}
          AND {% condition vendor_filter %} e.name {% endcondition %}
          AND m.company_id = {{ _user_attributes['company_id'] }}
      group by
          m.name
       ;;
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  dimension: cost_center {
    type: string
    sql: ${TABLE}."COST_CENTER" ;;
  }

  dimension: total_po_cost {
    label: "Total Amount"
    type: number
    sql: ${TABLE}."TOTAL_PO_COST" ;;
  }

  measure: total_spend {
    type: sum
    sql: ${total_po_cost} ;;
    value_format_name: usd
  }

  filter: cost_center_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.cost_center
  }

  filter: region_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.region_name
  }

  filter: district_filter {
    suggest_explore: cost_center
    suggest_dimension: cost_center.district_name
  }

  filter: status_filter {
  }

  filter: vendor_filter {
  }

  filter: date_filter {
    type: date_time
  }

  parameter: view_by {
    type: string
    allowed_value: { value: "Date Created"}
    allowed_value: { value: "Date Received"}
  }

  set: detail {
    fields: [cost_center, total_spend]
  }
}
