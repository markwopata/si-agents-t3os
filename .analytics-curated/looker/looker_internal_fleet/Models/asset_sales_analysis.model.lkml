connection: "es_snowflake"

include: "/views/Platform/*.view.lkml"
include: "/views/Business_Intelligence/*.view.lkml"
include: "/views/ES_Warehouse/*.view.lkml"

explore: fact_invoice_line_details {
  label: "Asset Sales Analysis"
  join: dim_invoices {
    type: left_outer
    sql_on: ${fact_invoice_line_details.invoice_line_details_invoice_key} = ${dim_invoices.invoice_key} ;;
    relationship: many_to_one
  }

  join: dim_orders {
    type: left_outer
    sql_on: ${fact_invoice_line_details.invoice_line_details_order_key} = ${dim_orders.order_key} ;;
    relationship: many_to_one
  }

  join: dim_assets {
    type: left_outer
    sql_on: ${fact_invoice_line_details.invoice_line_details_asset_key} = ${dim_assets.asset_key} ;;
    relationship: many_to_one
  }

  join: dim_line_items {
    type: left_outer
    sql_on: ${fact_invoice_line_details.invoice_line_details_line_item_key} = ${dim_line_items.line_item_key} ;;
    relationship: many_to_one
  }

  join: dim_companies {
    type: left_outer
    sql_on: ${fact_invoice_line_details.invoice_line_details_company_key} = ${dim_companies.company_key} ;;
    relationship: many_to_one
  }

  join: dim_users {
    type: left_outer
    sql_on: ${fact_invoice_line_details.invoice_line_details_salesperson_key} = ${dim_users.user_key} ;;
    relationship: many_to_one
  }

  join: dim_markets {
    type: left_outer
    sql_on: ${fact_invoice_line_details.invoice_line_details_market_key} = ${dim_markets.market_key} ;;
    relationship: many_to_one
  }

  join: v_dim_salesperson_enhanced {
    type: full_outer
    sql_on: ${dim_users.user_id} = ${v_dim_salesperson_enhanced.user_id}
    and ${v_dim_salesperson_enhanced._is_current} = true ;;
    relationship: many_to_one
  }

  join: v_dim_dates_bi {
    view_label: "Billing Approved Date"
    type: left_outer
    sql_on: ${fact_invoice_line_details.invoice_line_details_gl_billing_approved_date_key} = ${v_dim_dates_bi.date_key} ;;
    relationship: many_to_one
  }

  join: scd_asset_hours {
    type: left_outer
    view_label: "Hours @ Transaction Date"
    sql_on: ${dim_assets.asset_id} = ${scd_asset_hours.asset_id}
      and ${v_dim_dates_bi.date_date} between ${scd_asset_hours.date_start_date} and ${scd_asset_hours.date_end_date}
       ;;
    relationship: many_to_one
  }
}
