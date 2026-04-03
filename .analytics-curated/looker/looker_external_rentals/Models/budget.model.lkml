connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: budget_amount_remaining_by_day {
  group_label: "Budget"
  label: "Budget Amount Remaing By Date"
  case_sensitive: no
  # persist_for: "10 minutes"

  # join: purchase_orders {
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${purchase_orders.purchase_order_id} = ${budget_amount_remaining_by_day.purchase_order_id} ;;
  # }
}

explore: budget_remaining_by_invoice {
  group_label: "Budget"
  label: "Budget Remaing By Invoice"
  case_sensitive: no
  # persist_for: "10 minutes"

  # join: purchase_orders {
  #   type: inner
  #   relationship: many_to_one
  #   sql_on: ${purchase_orders.purchase_order_id} = ${budget_remaining_by_invoice.purchase_order_id} ;;
  # }

  join: invoices {
    type: inner
    relationship: one_to_one
    sql_on: ${invoices.invoice_id} = ${budget_remaining_by_invoice.invoice_id} ;;
  }
}

explore: multiple_budgets_amount_remaining_by_day {
  group_label: "Budget"
  label: "Multiple Budgets Amount Remaing By Date"
  case_sensitive: no
  # persist_for: "10 minutes"
}

explore: multiple_budgets_remaining_by_invoice {
  group_label: "Budget"
  label: "Multiple Budgets Remaing By Invoice"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: invoices {
    type: inner
    relationship: one_to_one
    sql_on: ${invoices.invoice_id} = ${multiple_budgets_remaining_by_invoice.invoice_id} ;;
  }
}

explore: company_po {
  group_label: "Budget"
  label: "Company Created Purchase Orders"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: spend_by_po {
    type: inner
    relationship: one_to_one
    sql_on: ${company_po.name} = ${spend_by_po.name} ;;
  }
}

explore: po_spend_date_filter {
  group_label: "Budget"
  label: "Company PO Spend and Budget"
  case_sensitive: no
  # persist_for: "10 minutes"

  join: po_spend_by_invoice_date_filter {
    type: left_outer
    relationship: many_to_one
    sql_on: ${po_spend_date_filter.po_name} = ${po_spend_by_invoice_date_filter.po_name} ;;
  }

}
