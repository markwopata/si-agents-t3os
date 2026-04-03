connection: "es_warehouse"

include: "/views/po_reporting/*.view.lkml"                # include all views in the views/ folder in this project


explore: closed_pos_by_date_received {
  group_label: "Cost Capture"
  label: "Closed PO's By Date Recieved"
  case_sensitive: no
  persist_for: "10 minutes"
}

explore: opens_pos_by_delivery_date {
  group_label: "Cost Capture"
  label: "Open POs By Delivery Date"
  case_sensitive: no
  persist_for: "10 minutes"
}

explore: po_items_by_receipt_date {
  group_label: "Cost Capture"
  label: "PO Items By Receipt Date"
  case_sensitive: no
  persist_for: "10 minutes"
}
