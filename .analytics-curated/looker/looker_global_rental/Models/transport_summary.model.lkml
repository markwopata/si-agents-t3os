connection: "es_warehouse"

include: "/views/transport_summary/*.view.lkml"

explore: transport_report_summary {
  group_label: "RentOps"
  label: "Transport Summary"
  description: "Explore used for Transport Summary"
  case_sensitive: no
  persist_for: "30 minutes"
}
