include: "/_base/es_warehouse/public/line_items.view.lkml"

view: +line_items {
  label: "Line Items"

  measure: total_service_labor_revenue {
    type: sum
    sql: iff(${line_item_type_id} in (13,26),${amount},null) ;;
    value_format_name: usd
    drill_fields: [dealership_service_drill*]
  }
  measure: total_service_parts_revenue {
    type: sum
    sql: iff(${line_item_type_id} in (11,25),${amount},null) ;;
    value_format_name: usd
    drill_fields: [dealership_service_drill*]
  }
  measure: total_outside_labor_revenue {
    type: sum
    sql: iff(${line_item_type_id} = 20,${amount},null) ;;
    value_format_name: usd
    drill_fields: [dealership_service_drill*]
  }
  set: dealership_service_drill {
    fields: [
      dim_work_orders_fleet_opt.work_order_id,
      dim_work_orders_fleet_opt.asset_id,
      invoice_id,
      dim_markets_flet_opt.market_name,
      line_item_types.line_item_type_name,
      total_service_labor_revenue,
      total_service_parts_revenue,
      total_outside_labor_revenue
    ]
  }
}
