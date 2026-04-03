connection: "snowflake_platform"

include: "/Platform/Views/*.view.lkml"

# Commented out due to low usage on 2026-03-27
# explore: invoice_line_details {
#   from: v_invoice_line_details
#   view_label: "Invoice Line Details"
#
#   join: v_assets {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_asset_key} = ${v_assets.asset_key} ;;
#   }
#
#   join: v_companies {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_asset_key} = ${v_companies.company_key} ;;
#   }
#
#   join: gl_billing_approved_date {
#     type: inner
#     from: v_dates
#     view_label: "GL Billing Approved Date"
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_gl_billing_approved_date_key} = ${gl_billing_approved_date.date_key} ;;
#   }
#
#   join: invoice_due_date {
#     type: inner
#     from: v_dates
#     view_label: "Invoice Due Date"
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_invoice_due_date_key} = ${invoice_due_date.date_key} ;;
#   }
#
#   join: v_invoices {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_invoice_key} = ${v_invoices.invoice_key} ;;
#   }
#
#   join: v_line_items {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_item_key} = ${v_line_items.line_item_key} ;;
#   }
#
#   join: v_markets {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_market_key} = ${v_markets.market_key} ;;
#   }
#
#   join: v_orders {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_order_key} = ${v_orders.order_key} ;;
#   }
#
#   join: v_parts {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_part_key} = ${v_parts.part_key} ;;
#   }
#
#   join: v_rentals {
#     type: inner
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_rental_key} = ${v_rentals.rental_key} ;;
#   }
#
#   join: v_users {
#     type: inner
#     view_label: "Salesperson"
#     relationship: many_to_one
#     sql_on: ${invoice_line_details.invoice_line_details_salesperson_key} = ${v_users.user_key} ;;
#   }
# }
