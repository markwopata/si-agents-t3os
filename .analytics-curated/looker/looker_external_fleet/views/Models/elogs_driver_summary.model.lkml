connection: "es_warehouse"

include: "/views/*.view.lkml"                # include all views in the views/ folder in this project

explore: elogs_driver_summary {
  group_label: "Fleet"
  label: "ELogs Driver Summary"
  case_sensitive: no
  persist_for: "10 minutes"

}
