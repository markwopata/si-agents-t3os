connection: "es_warehouse"

include: "/views/*.view.lkml"

explore: po_summary {
  group_label: "Cost Capture"
  label: "PO Summary"
  case_sensitive: no
  persist_for: "10 minutes"


}
