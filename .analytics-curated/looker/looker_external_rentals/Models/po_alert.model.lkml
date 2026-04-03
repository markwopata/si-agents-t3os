connection: "es_warehouse"

include: "/views/*.view.lkml"


explore: po_alert_reporting {
  group_label: "Budget"
  label: "PO Alert Reporting"
  case_sensitive: no
  persist_for: "10 minutes"
  # sql_always_where: ${pcnt_budget_remaining} <= ${dynamic_percentage_left_value} AND ${invoiced_in_last_two_weeks} = true ;;
}
