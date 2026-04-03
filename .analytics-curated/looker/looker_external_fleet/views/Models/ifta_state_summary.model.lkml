connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: ifta_state_summary {
  group_label: "Fleet"
  label: "IFTA State Summary"
  case_sensitive: no
  persist_for: "10 minutes"
}
