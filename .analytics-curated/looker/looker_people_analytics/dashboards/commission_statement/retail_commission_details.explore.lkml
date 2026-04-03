include: "/_standard/analytics/commission/retail_commission_details.layer.lkml"
include: "/dashboards/commission_statement/salesperson_type_invoice.view.lkml"

explore: retail_commission_details {
  label: "Retail Commissions"

  join: salesperson_type_invoice {
    type: left_outer
    relationship: one_to_many
    sql_on: ${retail_commission_details.invoice_id} = ${salesperson_type_invoice.invoice_id} ;;
  }
}
