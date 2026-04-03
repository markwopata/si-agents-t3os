connection: "reportingc_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: mileage_state_summary {
  group_label: "Fleet"
  label: "Mileage Report (State)"
  case_sensitive: no
  persist_for: "10 minutes"
}
