include: "/_base/fleet_optimization/dim_work_orders_fleet_opt.view.lkml"
#fields referencing other views, fields: [ALL_FIELDS*,-work_order_expense_100hr,-work_order_expense_175hr]
view: +dim_work_orders_fleet_opt {
  label:"Work Orders With Cost"
  #if using fact_work_order_lines for time entries and parts, this view is not necessary. note fact_work_order_lines only includes approved time.
  measure: work_order_expense_100hr { #this is using 100/hr labor rate, minimum that should be charged to warranty
    type: number
    sql: ${time_entries.warranty_total_labor_cost}+${fact_work_order_lines.parts_amount} ;;
    value_format_name: usd_0
    drill_fields: [work_order_id,work_order_completed_date,work_order_status_name,work_order_billing_type_name,dim_markets_fleet_opt.market_name, work_order_asset_id,dim_assets_fleet_opt.asset_equipment_make,company_tags.tags_on_work_order,time_entries.total_total_hours,time_entries.warranty_total_labor_cost,fact_work_order_lines.parts_amount,work_order_expense_100hr]
  }
  measure: work_order_expense_175hr { #this is using 175/hr labor rate, minimum that should be charged to customers
    type: number
    sql: ${time_entries.total_labor_cost}+${fact_work_order_lines.parts_amount} ;;
    value_format_name: usd_0
  }

}
